use crate::context::DbtContext;
use airform_core::{RefCall, SourceCall};
use jinja2::add_jinja2_compat;
use minijinja::{Environment, Error as JinjaError, ErrorKind, Value};
use std::cell::RefCell;
use std::fmt;
use std::sync::Arc;

thread_local! {
    /// Captures the most recent value passed to `return()` in a Jinja macro.
    /// Used by `fill_staging_columns` to receive structured column lists
    /// (since Jinja macros render to text, losing structured data).
    ///
    /// SAFETY INVARIANT: `_fill_staging_columns_impl()` must be called immediately
    /// after the `return()` that sets this value. Any intervening `return()` call
    /// will overwrite it. This is safe because Jinja rendering is single-threaded
    /// and `fill_staging_columns` calls `return()` then `_fill_staging_columns_impl()`
    /// in the same macro expansion with no other `return()` calls in between.
    static LAST_RETURN_VALUE: RefCell<Option<Value>> = RefCell::new(None);
}

/// A custom macro loaded from a macro file.
#[derive(Debug, Clone)]
pub struct LoadedMacro {
    pub name: String,
    pub args: Vec<String>,
    pub body: String,
}

/// A namespace of macros (e.g. dbt, dbt_utils, fivetran_utils).
#[derive(Debug, Clone)]
struct BuiltinNamespace {
    name: &'static str,
    macros: Vec<LoadedMacro>,
}

/// The Jinja rendering engine, wrapping minijinja with dbt-compatible functions.
pub struct JinjaEngine {
    env: Environment<'static>,
    custom_macros: Vec<LoadedMacro>,
    builtin_namespaces: Vec<BuiltinNamespace>,
    /// Package macros keyed by package name (e.g., "fivetran_utils" -> [...])
    package_macros: std::collections::HashMap<String, Vec<LoadedMacro>>,
}

impl JinjaEngine {
    pub fn new() -> Self {
        let mut env = Environment::new();

        // Add full Jinja2 compatibility (all filters, methods, tests, globals)
        add_jinja2_compat(&mut env);

        // Lenient undefined handling (dbt is permissive with undefined vars)
        env.set_undefined_behavior(minijinja::UndefinedBehavior::Chainable);

        // jinja2::add_jinja2_compat() already provides:
        // - Full Python method compatibility (items, keys, values, get, strip, replace, etc.)
        // - as_bool filter
        // - All 51 Jinja2 filters, 33 tests, 7 globals

        // Override length filter to handle non-iterable types gracefully
        env.add_filter("length", |val: Value| -> Value {
            if val.is_undefined() || val.is_none() {
                Value::from(0)
            } else if let Some(s) = val.as_str() {
                Value::from(s.len())
            } else if let Some(len) = val.len() {
                Value::from(len)
            } else {
                // For numbers, booleans, etc., return 0 instead of erroring
                Value::from(0)
            }
        });

        let mut engine = Self {
            env,
            custom_macros: Vec::new(),
            builtin_namespaces: Vec::new(),
            package_macros: std::collections::HashMap::new(),
        };
        engine.register_builtins();
        engine
    }

    /// Register built-in dbt and dbt_utils macros so projects that depend on
    /// them can compile without needing to install packages.
    fn register_builtins(&mut self) {
        // ── Bare macros (available without namespace prefix) ──────────────
        let bare: &[(&str, &[&str], &str)] = &[
            ("date_trunc", &["datepart", "field"],
             "DATE_TRUNC('{{ datepart }}', {{ field }})"),
            ("dateadd", &["datepart", "interval", "from_date_or_timestamp"],
             "{% if target.type == 'snowflake' %}DATEADD({{ datepart }}, {{ interval }}, {{ from_date_or_timestamp }}){% else %}{{ from_date_or_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}{% endif %}"),
            ("datediff", &["first_date", "second_date", "datepart"],
             "{% if target.type == 'snowflake' %}DATEDIFF({{ datepart }}, {{ first_date }}, {{ second_date }}){% elif target.type == 'bigquery' %}DATE_DIFF({{ second_date }}, {{ first_date }}, {{ datepart }}){% else %}DATE_DIFF('{{ datepart }}', {{ first_date }}, {{ second_date }}){% endif %}"),
            ("safe_cast", &["field", "type"],
             "CAST({{ field }} AS {{ type }})"),
            ("type_string", &[], "VARCHAR"),
            ("type_timestamp", &[], "TIMESTAMP"),
            ("type_int", &[], "INTEGER"),
            ("type_bigint", &[], "BIGINT"),
            ("type_float", &[], "DOUBLE"),
            ("type_numeric", &[], "NUMERIC"),
            ("type_boolean", &[], "BOOLEAN"),
            ("bool_or", &["val"], "BOOL_OR({{ val }})"),
            ("any_value", &["val"], "ANY_VALUE({{ val }})"),
            ("listagg", &["measure", "delimiter_text=none", "order_by_clause=none", "limit_num=none"],
             "{% if target.type == 'snowflake' %}LISTAGG({{ measure }}, {% if delimiter_text is not none %}{{ delimiter_text }}{% else %}', '{% endif %}){% if order_by_clause is not none %} WITHIN GROUP ({{ order_by_clause }}){% endif %}{% else %}STRING_AGG({{ measure }}, {% if delimiter_text is not none %}{{ delimiter_text }}{% else %}', '{% endif %}){% endif %}"),
            ("concat", &["fields"], "CONCAT({{ fields | join(', ') }})"),
            ("length", &["expression"], "LENGTH({{ expression }})"),
            ("right", &["string_text", "length_expression"],
             "RIGHT({{ string_text }}, {{ length_expression }})"),
            ("cast_bool_to_text", &["field"], "CAST({{ field }} AS VARCHAR)"),
            ("except", &[], "EXCEPT"),
            ("current_timestamp", &[], "CURRENT_TIMESTAMP"),
            ("current_timestamp_backcompat", &[], "CURRENT_TIMESTAMP"),
            ("generate_surrogate_key", &["field_list", "_b=none", "_c=none", "_d=none", "_e=none", "_f=none", "_g=none", "_h=none"],
             "{% set fields = [field_list, _b, _c, _d, _e, _f, _g, _h] if _b is not none else field_list %}MD5({% for f in fields %}{% if f is not none %}{% if not loop.first %} || '-' || {% endif %}COALESCE(CAST({{ f }} AS VARCHAR), '_dbt_utils_surrogate_key_null_'){% endif %}{% endfor %})"),
            ("surrogate_key", &["field_list", "_b=none", "_c=none", "_d=none", "_e=none", "_f=none", "_g=none", "_h=none"],
             "{% set fields = [field_list, _b, _c, _d, _e, _f, _g, _h] if _b is not none else field_list %}MD5({% for f in fields %}{% if f is not none %}{% if not loop.first %} || '-' || {% endif %}COALESCE(CAST({{ f }} AS VARCHAR), '_dbt_utils_surrogate_key_null_'){% endif %}{% endfor %})"),
            ("star", &["from", "relation_alias=none", "except=[]", "suffix=''", "prefix=''", "quote_identifiers=true"],
             "{% if relation_alias is not none %}{{ relation_alias }}.*{% else %}*{% endif %}"),
            ("date_spine", &["datepart", "start_date", "end_date", "first_date=none", "last_date=none"],
             "{% if target.type == 'snowflake' %}SELECT date_{{ datepart }} FROM (SELECT DATEADD({{ datepart }}, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, CAST({{ start_date }} AS DATE)) AS date_{{ datepart }} FROM TABLE(GENERATOR(ROWCOUNT => 100000))) WHERE date_{{ datepart }} <= CAST({{ end_date }} AS DATE){% else %}SELECT UNNEST(GENERATE_SERIES(CAST({{ start_date }} AS DATE), CAST({{ end_date }} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}{% endif %}"),
            ("pivot", &["column", "values", "alias=true", "agg='sum'", "cmp='='", "prefix=''", "suffix=''", "then_value='1'", "else_value='0'", "quote_identifiers=true", "distinct=false", "field_to_agg=none", "aliases=none"],
             "{% for v in values %}{{ agg }}({% if distinct %}DISTINCT {% endif %}CASE WHEN {{ column }} {{ cmp }} '{{ v }}' THEN {{ then_value }} ELSE {{ else_value }} END) AS {{ prefix }}{{ v }}{{ suffix }}{% if not loop.last %},\n{% endif %}{% endfor %}"),
            ("unpivot", &["relation=none", "cast_to='varchar'", "exclude=[]", "remove=[]", "field_name='field_name'", "value_name='value'"],
             "/* unpivot not supported in airform */ SELECT * FROM {{ relation }}"),
            ("union_data", &["table_identifier=none", "database_variable=none", "schema_variable=none", "default_database=none", "default_schema=none", "default_variable=none", "union_schema_variable=none", "union_database_variable=none"],
             "SELECT * FROM {{ var(schema_variable, default_schema) }}.{{ table_identifier }}"),
            ("enabled_vars", &["vars=[]"], "true"),
            ("fill_staging_columns", &["source_columns", "staging_columns"],
             "{{ _fill_staging_columns_impl(source_columns, staging_columns) }}"),
            ("string_agg", &["field=none", "delimiter=','", "field_to_agg=none"],
             "{% if target.type == 'snowflake' %}LISTAGG({{ field if field else field_to_agg }}, {{ delimiter }}){% else %}STRING_AGG({{ field if field else field_to_agg }}, {{ delimiter }}){% endif %}"),
            ("json_parse", &["string", "string_path"],
             "{% if target.type == 'snowflake' %}{% if string_path is iterable and string_path is not string %}PARSE_JSON({{ string }}){% for p in string_path %}['{{ p }}']{% endfor %}{% else %}PARSE_JSON({{ string }}):{{ string_path }}{% endif %}{% elif target.type == 'bigquery' %}{% if string_path is iterable and string_path is not string %}JSON_EXTRACT({{ string }}, '$.{{ string_path | join(\".\") }}'){% else %}JSON_EXTRACT({{ string }}, '$.{{ string_path }}'){% endif %}{% else %}{% if string_path is iterable and string_path is not string %}JSON_EXTRACT({{ string }}, '$.{{ string_path | join(\".\") }}'){% else %}JSON_EXTRACT({{ string }}, '$.{{ string_path }}'){% endif %}{% endif %}"),
            ("array_agg", &["field"], "ARRAY_AGG({{ field }})"),
            ("timestamp_add", &["datepart", "interval", "from_timestamp"],
             "{% if target.type == 'snowflake' %}DATEADD({{ datepart }}, {{ interval }}, {{ from_timestamp }}){% else %}{{ from_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}{% endif %}"),
            ("timestamp_diff", &["first_timestamp=none", "second_timestamp=none", "datepart='day'", "first_date=none", "second_date=none"],
             "{% if target.type == 'snowflake' %}DATEDIFF({{ datepart }}, {{ first_timestamp if first_timestamp else first_date }}, {{ second_timestamp if second_timestamp else second_date }}){% elif target.type == 'bigquery' %}TIMESTAMP_DIFF({{ second_timestamp if second_timestamp else second_date }}, {{ first_timestamp if first_timestamp else first_date }}, {{ datepart }}){% else %}DATE_DIFF('{{ datepart }}', {{ first_timestamp if first_timestamp else first_date }}, {{ second_timestamp if second_timestamp else second_date }}){% endif %}"),
            ("ceiling", &["val"], "CEIL({{ val }})"),
            ("percentile", &["field_name=none", "partition_field=none", "percentile_value=none", "field=none", "percentile_val=none", "percent=none", "percentile_field=none"],
             "PERCENTILE_CONT({{ percentile_value if percentile_value else (percentile_val if percentile_val else percent) }}) WITHIN GROUP (ORDER BY {{ field_name if field_name else (field if field else percentile_field) }})"),
            ("hash", &["field"],
             "MD5(CAST({{ field }} AS VARCHAR))"),
            ("position", &["substring_text", "string_text"],
             "POSITION({{ substring_text }} IN {{ string_text }})"),
            ("replace", &["field", "old_chars", "new_chars"],
             "REPLACE({{ field }}, {{ old_chars }}, {{ new_chars }})"),
            ("split_part", &["string_text", "delimiter_text", "part_number"],
             "SPLIT_PART({{ string_text }}, {{ delimiter_text }}, {{ part_number }})"),
            ("last_day", &["date", "datepart='month'"],
             "LAST_DAY({{ date }})"),
            ("now", &[], "CURRENT_TIMESTAMP"),
            ("group_by", &["n"],
             "GROUP BY {% for i in range(1, n + 1) %}{{ i }}{% if not loop.last %}, {% endif %}{% endfor %}"),
            ("get_column_values", &["table", "column", "default=[]", "max_records=none", "order_by='count(*) desc'", "where=none"],
             ""),
            ("get_single_value", &["table", "column", "default=none"],
             "{{ default }}"),
            ("get_url_host", &["field"],
             "SPLIT_PART(SPLIT_PART(REPLACE(REPLACE({{ field }}, 'https://', ''), 'http://', ''), '/', 1), '?', 1)"),
            ("get_url_path", &["field"],
             "SPLIT_PART(SPLIT_PART(REPLACE(REPLACE({{ field }}, 'https://', ''), 'http://', ''), '?', 1), '/', 2)"),
            ("get_url_parameter", &["field", "url_parameter"],
             "NULL"),
            ("safe_add", &["field_list"],
             "{% for f in field_list %}{% if not loop.first %} + {% endif %}COALESCE({{ f }}, 0){% endfor %}"),
            ("safe_divide", &["numerator", "denominator"],
             "CASE WHEN {{ denominator }} = 0 THEN NULL ELSE {{ numerator }} / {{ denominator }} END"),
        ];

        for (name, args, body) in bare {
            self.custom_macros.push(LoadedMacro {
                name: name.to_string(),
                args: args.iter().map(|a| a.to_string()).collect(),
                body: body.to_string(),
            });
        }

        // ── dbt namespace ────────────────────────────────────────────────
        let dbt_macros: &[(&str, &[&str], &str)] = &[
            ("date_trunc", &["datepart", "field"],
             "DATE_TRUNC('{{ datepart }}', {{ field }})"),
            ("dateadd", &["datepart", "interval", "from_date_or_timestamp"],
             "{% if target.type == 'snowflake' %}DATEADD({{ datepart }}, {{ interval }}, {{ from_date_or_timestamp }}){% else %}{{ from_date_or_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}{% endif %}"),
            ("datediff", &["first_date", "second_date", "datepart"],
             "{% if target.type == 'snowflake' %}DATEDIFF({{ datepart }}, {{ first_date }}, {{ second_date }}){% elif target.type == 'bigquery' %}DATE_DIFF({{ second_date }}, {{ first_date }}, {{ datepart }}){% else %}DATE_DIFF('{{ datepart }}', {{ first_date }}, {{ second_date }}){% endif %}"),
            ("safe_cast", &["field", "type"],
             "CAST({{ field }} AS {{ type }})"),
            ("type_string", &[], "VARCHAR"),
            ("type_timestamp", &[], "TIMESTAMP"),
            ("type_int", &[], "INTEGER"),
            ("type_bigint", &[], "BIGINT"),
            ("type_float", &[], "DOUBLE"),
            ("type_numeric", &[], "NUMERIC"),
            ("type_boolean", &[], "BOOLEAN"),
            ("bool_or", &["val"], "BOOL_OR({{ val }})"),
            ("any_value", &["val"], "ANY_VALUE({{ val }})"),
            ("listagg", &["measure", "delimiter_text=none", "order_by_clause=none", "limit_num=none"],
             "{% if target.type == 'snowflake' %}LISTAGG({{ measure }}, {% if delimiter_text is not none %}{{ delimiter_text }}{% else %}', '{% endif %}){% if order_by_clause is not none %} WITHIN GROUP ({{ order_by_clause }}){% endif %}{% else %}STRING_AGG({{ measure }}, {% if delimiter_text is not none %}{{ delimiter_text }}{% else %}', '{% endif %}){% endif %}"),
            ("concat", &["fields"], "CONCAT({{ fields | join(', ') }})"),
            ("length", &["expression"], "LENGTH({{ expression }})"),
            ("right", &["string_text", "length_expression"],
             "RIGHT({{ string_text }}, {{ length_expression }})"),
            ("cast_bool_to_text", &["field"], "CAST({{ field }} AS VARCHAR)"),
            ("except", &[], "EXCEPT"),
            ("current_timestamp", &[], "CURRENT_TIMESTAMP"),
            ("current_timestamp_backcompat", &[], "CURRENT_TIMESTAMP"),
            ("current_timestamp_in_utc_backcompat", &[], "CURRENT_TIMESTAMP"),
            ("current_timestamp_in_utc", &[], "CURRENT_TIMESTAMP"),
            ("replace", &["field", "old_chars", "new_chars"],
             "REPLACE({{ field }}, {{ old_chars }}, {{ new_chars }})"),
            ("split_part", &["string_text", "delimiter_text", "part_number"],
             "SPLIT_PART({{ string_text }}, {{ delimiter_text }}, {{ part_number }})"),
            ("hash", &["field"],
             "MD5(CAST({{ field }} AS VARCHAR))"),
            ("position", &["substring_text", "string_text"],
             "POSITION({{ substring_text }} IN {{ string_text }})"),
            ("last_day", &["date", "datepart='month'"],
             "LAST_DAY({{ date }})"),
            ("now", &[], "CURRENT_TIMESTAMP"),
            ("generate_series", &["start_val=0", "stop_val=none", "step=none", "upper_bound=none"],
             "{% if target.type == 'snowflake' %}SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 + {{ start_val }} AS generate_series FROM TABLE(GENERATOR(ROWCOUNT => {{ stop_val if stop_val else upper_bound }} - {{ start_val }} + 1)){% else %}GENERATE_SERIES({{ start_val }}, {{ stop_val if stop_val else upper_bound }}{% if step %}, {{ step }}{% endif %}){% endif %}"),
            ("escape_single_quotes", &["value"],
             "{{ value | replace(\"'\", \"''\") }}"),
        ];

        // ── dbt_utils namespace ──────────────────────────────────────────
        let dbt_utils_macros: &[(&str, &[&str], &str)] = &[
            ("generate_surrogate_key", &["field_list", "_b=none", "_c=none", "_d=none", "_e=none", "_f=none", "_g=none", "_h=none"],
             "{% set fields = [field_list, _b, _c, _d, _e, _f, _g, _h] if _b is not none else field_list %}MD5({% for f in fields %}{% if f is not none %}{% if not loop.first %} || '-' || {% endif %}COALESCE(CAST({{ f }} AS VARCHAR), '_dbt_utils_surrogate_key_null_'){% endif %}{% endfor %})"),
            ("surrogate_key", &["field_list", "_b=none", "_c=none", "_d=none", "_e=none", "_f=none", "_g=none", "_h=none"],
             "{% set fields = [field_list, _b, _c, _d, _e, _f, _g, _h] if _b is not none else field_list %}MD5({% for f in fields %}{% if f is not none %}{% if not loop.first %} || '-' || {% endif %}COALESCE(CAST({{ f }} AS VARCHAR), '_dbt_utils_surrogate_key_null_'){% endif %}{% endfor %})"),
            ("star", &["from", "relation_alias=none", "except=[]", "suffix=''", "prefix=''", "quote_identifiers=true"],
             "{% if relation_alias is not none %}{{ relation_alias }}.*{% else %}*{% endif %}"),
            ("date_spine", &["datepart", "start_date", "end_date", "first_date=none", "last_date=none"],
             "{% if target.type == 'snowflake' %}SELECT date_{{ datepart }} FROM (SELECT DATEADD({{ datepart }}, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, CAST({{ start_date }} AS DATE)) AS date_{{ datepart }} FROM TABLE(GENERATOR(ROWCOUNT => 100000))) WHERE date_{{ datepart }} <= CAST({{ end_date }} AS DATE){% else %}SELECT UNNEST(GENERATE_SERIES(CAST({{ start_date }} AS DATE), CAST({{ end_date }} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}{% endif %}"),
            ("pivot", &["column", "values", "alias=true", "agg='sum'", "cmp='='", "prefix=''", "suffix=''", "then_value='1'", "else_value='0'", "quote_identifiers=true", "distinct=false", "field_to_agg=none", "aliases=none"],
             "{% for v in values %}{{ agg }}({% if distinct %}DISTINCT {% endif %}CASE WHEN {{ column }} {{ cmp }} '{{ v }}' THEN {{ then_value }} ELSE {{ else_value }} END) AS {{ prefix }}{{ v }}{{ suffix }}{% if not loop.last %},\n{% endif %}{% endfor %}"),
            ("unpivot", &["relation=none", "cast_to='varchar'", "exclude=[]", "remove=[]", "field_name='field_name'", "value_name='value'"],
             "/* unpivot not supported in airform */ SELECT * FROM {{ relation }}"),
            ("safe_add", &["field_list"],
             "{% for f in field_list %}{% if not loop.first %} + {% endif %}COALESCE({{ f }}, 0){% endfor %}"),
            ("safe_divide", &["numerator", "denominator"],
             "CASE WHEN {{ denominator }} = 0 THEN NULL ELSE {{ numerator }} / {{ denominator }} END"),
            ("group_by", &["n"],
             "GROUP BY {% for i in range(1, n + 1) %}{{ i }}{% if not loop.last %}, {% endif %}{% endfor %}"),
            ("get_column_values", &["table", "column", "default=[]", "max_records=none", "order_by='count(*) desc'", "where=none"],
             ""),
            ("get_single_value", &["table", "column", "default=none"],
             "{{ default }}"),
            ("get_url_host", &["field"],
             "SPLIT_PART(SPLIT_PART(REPLACE(REPLACE({{ field }}, 'https://', ''), 'http://', ''), '/', 1), '?', 1)"),
            ("get_url_path", &["field"],
             "SPLIT_PART(SPLIT_PART(REPLACE(REPLACE({{ field }}, 'https://', ''), 'http://', ''), '?', 1), '/', 2)"),
            ("get_url_parameter", &["field", "url_parameter"],
             "NULL"),
            ("generate_series", &["start_val=0", "stop_val=none", "step=none", "upper_bound=none"],
             "{% if target.type == 'snowflake' %}SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 + {{ start_val }} AS generate_series FROM TABLE(GENERATOR(ROWCOUNT => {{ stop_val if stop_val else upper_bound }} - {{ start_val }} + 1)){% else %}GENERATE_SERIES({{ start_val }}, {{ stop_val if stop_val else upper_bound }}{% if step %}, {{ step }}{% endif %}){% endif %}"),
            ("slugify", &["text"], "{{ text }}"),
            ("get_filtered_columns_in_relation", &["from", "except=[]"],
             ""),
            ("union_relations", &["relations", "column_override=none", "include=[]", "exclude=[]", "source_column_name=none", "aliases=none", "where=none"],
             "{% for rel in relations %}{% if not loop.first %}UNION ALL {% endif %}SELECT * FROM {{ rel }}{% endfor %}"),
            ("_is_relation", &["relation", "macro_name=''"], ""),
            ("_is_ephemeral", &["relation", "macro_name=''"], ""),
        ];

        // ── fivetran_utils namespace ─────────────────────────────────────
        let fivetran_utils_macros: &[(&str, &[&str], &str)] = &[
            ("union_data", &["table_identifier=none", "database_variable=none", "schema_variable=none", "default_database=none", "default_schema=none", "default_variable=none", "union_schema_variable=none", "union_database_variable=none"],
             "SELECT * FROM {{ var(schema_variable, default_schema) }}.{{ table_identifier }}"),
            ("enabled_vars", &["vars=[]"], "true"),
            ("enabled_vars_one_true", &["vars=[]"], "true"),
            ("fill_staging_columns", &["source_columns", "staging_columns"],
             "{{ _fill_staging_columns_impl(source_columns, staging_columns) }}"),
            ("string_agg", &["field=none", "delimiter=','", "field_to_agg=none"],
             "{% if target.type == 'snowflake' %}LISTAGG({{ field if field else field_to_agg }}, {{ delimiter }}){% else %}STRING_AGG({{ field if field else field_to_agg }}, {{ delimiter }}){% endif %}"),
            ("json_parse", &["string", "string_path"],
             "{% if target.type == 'snowflake' %}{% if string_path is iterable and string_path is not string %}PARSE_JSON({{ string }}){% for p in string_path %}['{{ p }}']{% endfor %}{% else %}PARSE_JSON({{ string }}):{{ string_path }}{% endif %}{% elif target.type == 'bigquery' %}{% if string_path is iterable and string_path is not string %}JSON_EXTRACT({{ string }}, '$.{{ string_path | join(\".\") }}'){% else %}JSON_EXTRACT({{ string }}, '$.{{ string_path }}'){% endif %}{% else %}{% if string_path is iterable and string_path is not string %}JSON_EXTRACT({{ string }}, '$.{{ string_path | join(\".\") }}'){% else %}JSON_EXTRACT({{ string }}, '$.{{ string_path }}'){% endif %}{% endif %}"),
            ("array_agg", &["field"], "ARRAY_AGG({{ field }})"),
            ("timestamp_add", &["datepart", "interval", "from_timestamp"],
             "{% if target.type == 'snowflake' %}DATEADD({{ datepart }}, {{ interval }}, {{ from_timestamp }}){% else %}{{ from_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}{% endif %}"),
            ("timestamp_diff", &["first_timestamp=none", "second_timestamp=none", "datepart='day'", "first_date=none", "second_date=none"],
             "{% if target.type == 'snowflake' %}DATEDIFF({{ datepart }}, {{ first_timestamp if first_timestamp else first_date }}, {{ second_timestamp if second_timestamp else second_date }}){% elif target.type == 'bigquery' %}TIMESTAMP_DIFF({{ second_timestamp if second_timestamp else second_date }}, {{ first_timestamp if first_timestamp else first_date }}, {{ datepart }}){% else %}DATE_DIFF('{{ datepart }}', {{ first_timestamp if first_timestamp else first_date }}, {{ second_timestamp if second_timestamp else second_date }}){% endif %}"),
            ("ceiling", &["val"], "CEIL({{ val }})"),
            ("percentile", &["field_name=none", "partition_field=none", "percentile_value=none", "field=none", "percentile_val=none", "percent=none", "percentile_field=none"],
             "PERCENTILE_CONT({{ percentile_value if percentile_value else (percentile_val if percentile_val else percent) }}) WITHIN GROUP (ORDER BY {{ field_name if field_name else (field if field else percentile_field) }})"),
            ("source_relation", &["union_schema_variable=none", "union_database_variable=none"],
             ", CAST('' AS VARCHAR) AS source_relation"),
            ("persist_pass_through_columns", &["pass_through_variable=none", "identifier=none", "transform=none"],
             "{% if var(pass_through_variable, []) %}{% for col in var(pass_through_variable, []) %}, {% if col is mapping %}{{ col.alias if col.alias else col.name }}{% else %}{{ col }}{% endif %}{% endfor %}{% endif %}"),
            ("fill_pass_through_columns", &["pass_through_variable=none"],
             "{% if var(pass_through_variable, []) %}{% for col in var(pass_through_variable, []) %}, {% if col is mapping %}{% if col.alias %}{{ col.name }} as {{ col.alias }}{% elif col.transform %}{{ col.transform }}({{ col.name }}){% else %}{{ col.name }}{% endif %}{% else %}{{ col }}{% endif %}{% endfor %}{% endif %}"),
            ("add_pass_through_columns", &["base_columns", "pass_through_var"],
             "{{ base_columns }}{% if var(pass_through_var, []) %}{% for col in var(pass_through_var, []) %}, {% if col is mapping %}{{ col.name }}{% else %}{{ col }}{% endif %}{% endfor %}{% endif %}"),
            ("union_relations", &["relations", "column_override=none", "include=[]", "exclude=[]", "source_column_name=none", "aliases=none"],
             "{% for rel in relations %}{% if not loop.first %}UNION ALL {% endif %}SELECT * FROM {{ rel }}{% endfor %}"),
            ("seed_data_helper", &["seed_name=none", "source_name=none"],
             "SELECT * FROM {{ source(source_name, seed_name) if source_name else ref(seed_name) }}"),
            ("convert_values", &["field", "convert_to=none"],
             "{{ field }}"),
            ("calculated_fields", &["variable=none", "source_name=none"],
             ""),
            ("apply_source_relation", &[],
             ""),
            ("get_base_dates", &["start_date=none", "end_date=none", "n_dateparts=1", "datepart='day'"],
             "{% if target.type == 'snowflake' %}SELECT date_{{ datepart }} FROM (SELECT DATEADD({{ datepart }}, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, CAST({% if start_date %}{{ start_date }}{% else %}CURRENT_DATE - INTERVAL '{{ n_dateparts }} {{ datepart }}'{% endif %} AS DATE)) AS date_{{ datepart }} FROM TABLE(GENERATOR(ROWCOUNT => 100000))) WHERE date_{{ datepart }} <= CAST({% if end_date %}{{ end_date }}{% else %}CURRENT_DATE{% endif %} AS DATE){% else %}SELECT UNNEST(GENERATE_SERIES(CAST({% if start_date %}{{ start_date }}{% else %}CURRENT_DATE - INTERVAL '{{ n_dateparts }}' {{ datepart }}{% endif %} AS DATE), CAST({% if end_date %}{{ end_date }}{% else %}CURRENT_DATE{% endif %} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}{% endif %}"),
            ("get_columns_in_relation", &["relation"],
             ""),
            ("add_renamed_columns", &["source_columns=[]", "renamed_columns=[]"],
             "{% for col in source_columns %}{% if not loop.first %}, {% endif %}{{ col.name }}{% endfor %}"),
            ("max_bool", &["field=none", "boolean_field=none"],
             "MAX({{ field if field else boolean_field }})"),
            ("fivetran_date_spine", &["datepart", "start_date", "end_date"],
             "{% if target.type == 'snowflake' %}SELECT date_{{ datepart }} FROM (SELECT DATEADD({{ datepart }}, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, CAST({{ start_date }} AS DATE)) AS date_{{ datepart }} FROM TABLE(GENERATOR(ROWCOUNT => 100000))) WHERE date_{{ datepart }} <= CAST({{ end_date }} AS DATE){% else %}SELECT UNNEST(GENERATE_SERIES(CAST({{ start_date }} AS DATE), CAST({{ end_date }} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}{% endif %}"),
        ];

        // ── snowplow_utils namespace (stubs) ─────────────────────────────
        let snowplow_utils_macros: &[(&str, &[&str], &str)] = &[
            ("get_value_by_target_type", &["bigquery_val=none", "snowflake_val=none", "databricks_val=none", "default_val=none"],
             "{% if target.type == 'snowflake' and snowflake_val is not none %}{{ snowflake_val }}{% elif target.type == 'bigquery' and bigquery_val is not none %}{{ bigquery_val }}{% elif target.type == 'databricks' and databricks_val is not none %}{{ databricks_val }}{% else %}{{ default_val }}{% endif %}"),
            ("set_query_tag", &["tag=none"], ""),
            ("allow_refresh", &[], ""),
            ("get_split_to_array", &["field", "relation_alias=none", "delimiter=','"],
             "STRING_SPLIT({{ field }}, {{ delimiter }})"),
            ("get_string_agg", &["base_query", "field", "delimiter=','", "sort_numeric=false", "order_by_column=none", "sort_by_suffix=none", "is_distinct=false"],
             "{% if target.type == 'snowflake' %}LISTAGG({{ field }}, {{ delimiter }}){% else %}STRING_AGG({{ field }}, {{ delimiter }}){% endif %}"),
            ("timestamp_add", &["datepart", "interval", "tstamp"],
             "{% if target.type == 'snowflake' %}DATEADD({{ datepart }}, {{ interval }}, {{ tstamp }}){% else %}{{ tstamp }} + INTERVAL '{{ interval }}' {{ datepart }}{% endif %}"),
            ("timestamp_diff", &["first_tstamp", "second_tstamp", "datepart"],
             "{% if target.type == 'snowflake' %}DATEDIFF({{ datepart }}, {{ first_tstamp }}, {{ second_tstamp }}){% else %}DATE_DIFF('{{ datepart }}', {{ first_tstamp }}, {{ second_tstamp }}){% endif %}"),
            ("return_limits_from_model", &["model_name", "lower_limit_col=none", "upper_limit_col=none"],
             ""),
            ("get_enabled_snowplow_models", &["package_name", "graph_object=none", "models_to_run=none", "base_events_table_name=none"],
             ""),
            ("get_incremental_manifest_status", &["incremental_manifest_table", "base_events_table"],
             ""),
            ("get_run_limits", &["min_last_success=none", "max_last_success=none", "models_matched_from_manifest=none", "has_matched_all_models=none", "start_date=none"],
             ""),
            ("base_create_snowplow_incremental_manifest", &[], ""),
            ("base_create_snowplow_sessions_lifecycle_manifest", &["session_identifiers=none", "session_sql=none", "session_timestamp=none", "user_identifiers=none", "user_sql=none", "quarantined_sessions=none", "derived_tstamp_partitioned=none", "days_late_allowed=none", "max_session_days=none", "app_ids=none", "snowplow_events_database=none", "snowplow_events_schema=none", "snowplow_events_table=none", "event_limits_table=none", "incremental_manifest_table=none", "lifecycle_manifest_table=none", "allow_null_dvce_tstamps=none"],
             ""),
            ("is_run_with_new_events", &["package_name=none"],
             "true"),
            ("base_create_snowplow_events_this_run", &["sessions_this_run_table=none", "session_identifiers=none", "session_sql=none", "session_timestamp=none", "derived_tstamp_partitioned=none", "days_late_allowed=none", "max_session_days=none", "app_ids=none", "snowplow_events_database=none", "snowplow_events_schema=none", "snowplow_events_table=none", "entities_or_sdes=none", "custom_sql=none", "allow_null_dvce_tstamps=none"],
             ""),
            ("base_create_snowplow_quarantined_sessions", &[], ""),
            ("base_create_snowplow_sessions_this_run", &["lifecycle_manifest_table=none", "new_event_limits_table=none"],
             ""),
            ("current_timestamp_in_utc", &[], "CURRENT_TIMESTAMP"),
            ("to_unixtstamp", &["tstamp"], "EXTRACT(EPOCH FROM {{ tstamp }})"),
            ("get_optional_fields", &["enabled=false", "fields=none", "col_prefix=none", "relation=none", "relation_alias=none"],
             ""),
            ("get_array_to_string", &["field", "delimiter=','"],
             "ARRAY_TO_STRING({{ field }}, {{ delimiter }})"),
            ("get_cluster_by", &["fields=none"],
             ""),
            ("get_sde_or_context", &["schema=none", "identifier=none", "single_entity=false", "prefix=none"],
             ""),
            ("slugify", &["text"], "{{ text }}"),
            ("app_id_filter", &["app_ids=none"], ""),
            ("unnest", &["id_column", "array_column", "output_column", "source_cte"],
             "SELECT {{ id_column }}, UNNEST({{ array_column }}) AS {{ output_column }} FROM {{ source_cte }}"),
            ("type_max_string", &[], "VARCHAR(65535)"),
            ("print_run_limits", &["model=none", "package_name=none"], ""),
            ("get_column_schema_from_query", &["query=none"], ""),
        ];

        // ── snowplow_web namespace (stubs) ────────────────────────────────
        let snowplow_web_macros: &[(&str, &[&str], &str)] = &[
            ("get_iab_context_fields", &["table_prefix=none"],
             "cast(null as VARCHAR(65535)) as iab_category,\n        cast(null as VARCHAR(65535)) as iab_primary_impact,\n        cast(null as VARCHAR(65535)) as iab_reason,\n        cast(null as boolean) as iab_spider_or_robot"),
            ("get_ua_context_fields", &["table_prefix=none"],
             "cast(null as VARCHAR(65535)) as ua_useragent_family,\n        cast(null as VARCHAR(65535)) as ua_useragent_major,\n        cast(null as VARCHAR(65535)) as ua_useragent_minor,\n        cast(null as VARCHAR(65535)) as ua_useragent_patch,\n        cast(null as VARCHAR(65535)) as ua_useragent_version,\n        cast(null as VARCHAR(65535)) as ua_os_family,\n        cast(null as VARCHAR(65535)) as ua_os_major,\n        cast(null as VARCHAR(65535)) as ua_os_minor,\n        cast(null as VARCHAR(65535)) as ua_os_patch,\n        cast(null as VARCHAR(65535)) as ua_os_patch_minor,\n        cast(null as VARCHAR(65535)) as ua_os_version,\n        cast(null as VARCHAR(65535)) as ua_device_family"),
            ("get_yauaa_context_fields", &["table_prefix=none"],
             "cast(null as VARCHAR(65535)) as yauaa_device_class,\n        cast(null as VARCHAR(65535)) as yauaa_agent_class,\n        cast(null as VARCHAR(65535)) as yauaa_agent_name,\n        cast(null as VARCHAR(65535)) as yauaa_agent_name_version,\n        cast(null as VARCHAR(65535)) as yauaa_agent_name_version_major,\n        cast(null as VARCHAR(65535)) as yauaa_agent_version,\n        cast(null as VARCHAR(65535)) as yauaa_agent_version_major,\n        cast(null as VARCHAR(65535)) as yauaa_device_brand,\n        cast(null as VARCHAR(65535)) as yauaa_device_name,\n        cast(null as VARCHAR(65535)) as yauaa_device_version,\n        cast(null as VARCHAR(65535)) as yauaa_layout_engine_class,\n        cast(null as VARCHAR(65535)) as yauaa_layout_engine_name,\n        cast(null as VARCHAR(65535)) as yauaa_layout_engine_name_version,\n        cast(null as VARCHAR(65535)) as yauaa_layout_engine_name_version_major,\n        cast(null as VARCHAR(65535)) as yauaa_layout_engine_version,\n        cast(null as VARCHAR(65535)) as yauaa_layout_engine_version_major,\n        cast(null as VARCHAR(65535)) as yauaa_operating_system_class,\n        cast(null as VARCHAR(65535)) as yauaa_operating_system_name,\n        cast(null as VARCHAR(65535)) as yauaa_operating_system_name_version,\n        cast(null as VARCHAR(65535)) as yauaa_operating_system_version"),
            ("get_conversion_columns", &["conv_object=none", "names_only=false"], ""),
            ("filter_bots", &["table_alias=none"],
             "and lower({% if table_alias %}{{ table_alias }}.{% endif %}useragent) not similar to '%(bot|crawl|slurp|spider|archiv|spinn|sniff|seo|audit|survey|pingdom|worm|capture|(browser|screen)shots|analyz|index|thumb|check|facebook|pingdombot|phantomjs|yandexbot|twitterbot|a_archiver|facebookexternalhit|bingbot|bingpreview|googlebot|baiduspider|360(spider|user-agent)|semalt)%'"),
            ("channel_group_query", &[], "case\n   when lower(trim(mkt_source)) = '(direct)' and lower(trim(mkt_medium)) in ('(not set)', '(none)') then 'Direct'\n   else 'Unassigned'\nend"),
            ("engaged_session", &[], "page_views >= 2 or engaged_time_in_s / 10 >= 2"),
            ("stitch_user_identifiers", &["enabled=false"], ""),
            ("content_group_query", &[], "''"),
            ("core_web_vital_page_groups", &[], "''"),
            ("core_web_vital_pass_query", &[], "''"),
            ("core_web_vital_results_query", &[], "''"),
        ];

        // ── dbt_date namespace ───────────────────────────────────────────
        let dbt_date_macros: &[(&str, &[&str], &str)] = &[
            ("get_base_dates", &["start_date=none", "end_date=none", "n_dateparts=1", "datepart='day'"],
             "{% if target.type == 'snowflake' %}SELECT date_{{ datepart }} FROM (SELECT DATEADD({{ datepart }}, ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1, CAST({% if start_date %}{{ start_date }}{% else %}CURRENT_DATE - INTERVAL '{{ n_dateparts }} {{ datepart }}'{% endif %} AS DATE)) AS date_{{ datepart }} FROM TABLE(GENERATOR(ROWCOUNT => 100000))) WHERE date_{{ datepart }} <= CAST({% if end_date %}{{ end_date }}{% else %}CURRENT_DATE{% endif %} AS DATE){% else %}SELECT UNNEST(GENERATE_SERIES(CAST({% if start_date %}{{ start_date }}{% else %}CURRENT_DATE - INTERVAL '{{ n_dateparts }}' {{ datepart }}{% endif %} AS DATE), CAST({% if end_date %}{{ end_date }}{% else %}CURRENT_DATE{% endif %} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}{% endif %}"),
            ("day_of_week", &["date=none", "isoweek=true"],
             "EXTRACT(DOW FROM {{ date }})"),
            ("n_days_ago", &["n", "date=none", "tz=none"],
             "CURRENT_DATE - INTERVAL '{{ n }}' DAY"),
            ("n_days_away", &["n", "date=none", "tz=none"],
             "CURRENT_DATE + INTERVAL '{{ n }}' DAY"),
            ("n_months_ago", &["n", "date=none", "tz=none"],
             "CURRENT_DATE - INTERVAL '{{ n }}' MONTH"),
            ("n_months_away", &["n", "date=none", "tz=none"],
             "CURRENT_DATE + INTERVAL '{{ n }}' MONTH"),
            ("n_weeks_ago", &["n", "date=none", "tz=none"],
             "CURRENT_DATE - INTERVAL '{{ n }}' WEEK"),
            ("n_weeks_away", &["n", "date=none", "tz=none"],
             "CURRENT_DATE + INTERVAL '{{ n }}' WEEK"),
            ("now", &["tz=none"],
             "CURRENT_TIMESTAMP"),
            ("today", &["tz=none"],
             "CURRENT_DATE"),
            ("yesterday", &["tz=none"],
             "CURRENT_DATE - INTERVAL '1' DAY"),
            ("tomorrow", &["tz=none"],
             "CURRENT_DATE + INTERVAL '1' DAY"),
            ("date_part", &["datepart", "date"],
             "EXTRACT({{ datepart }} FROM {{ date }})"),
        ];

        // Register namespaces
        for (ns_name, ns_macros) in [
            ("dbt", dbt_macros as &[_]),
            ("dbt_utils", dbt_utils_macros),
            ("dbt_date", dbt_date_macros),
            ("fivetran_utils", fivetran_utils_macros),
            ("snowplow_utils", snowplow_utils_macros),
            ("snowplow_web", snowplow_web_macros),
        ] {
            let macros = ns_macros.iter().map(|(name, args, body)| LoadedMacro {
                name: name.to_string(),
                args: args.iter().map(|a| a.to_string()).collect(),
                body: body.to_string(),
            }).collect();
            self.builtin_namespaces.push(BuiltinNamespace {
                name: ns_name,
                macros,
            });
        }
    }

    /// Register custom macros from macro files.
    /// Each macro is registered as a Jinja template that can be called.
    pub fn load_macros(&mut self, macros: &[(String, Vec<String>, String)]) {
        for (name, args, body) in macros {
            self.custom_macros.push(LoadedMacro {
                name: name.clone(),
                args: args.clone(),
                body: body.clone(),
            });
        }
    }

    /// Register macros with package info. Package macros are registered under
    /// their package namespace (e.g., `fivetran_utils.source_relation`).
    /// Package macros that conflict with builtin namespace macros are only added
    /// to the package namespace, not as bare macros.
    pub fn load_macros_with_packages(&mut self, macros: &[(String, Vec<String>, String, Option<String>)]) {
        // Collect builtin macro names for conflict detection
        let builtin_macro_names: std::collections::HashSet<String> = self.builtin_namespaces.iter()
            .flat_map(|ns| ns.macros.iter().map(|m| m.name.clone()))
            .collect();

        for (name, args, body, package) in macros {
            let loaded = LoadedMacro {
                name: name.clone(),
                args: args.clone(),
                body: body.clone(),
            };
            if let Some(pkg) = package {
                // Package macros go into package_macros for namespace access
                self.package_macros
                    .entry(pkg.clone())
                    .or_default()
                    .push(loaded.clone());
                // Only add as bare macro if it doesn't conflict with builtins
                if !builtin_macro_names.contains(name) {
                    self.custom_macros.push(loaded);
                }
            } else {
                // Project macros always go into custom_macros
                self.custom_macros.push(loaded);
            }
        }
    }

    /// Filter and clean macro args: remove broken entries from multi-line
    /// default value parsing, and fix default values that minijinja can't handle.
    fn clean_args(args: &[String]) -> Vec<String> {
        args.iter()
            .filter_map(|a| {
                let a = a.trim();
                let (name, default) = if let Some((n, d)) = a.split_once('=') {
                    (n.trim(), Some(d.trim()))
                } else {
                    (a, None)
                };
                // Validate name is a valid identifier
                if name.is_empty()
                    || !name.starts_with(|c: char| c.is_ascii_alphabetic() || c == '_')
                    || !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
                {
                    return None;
                }
                match default {
                    None => Some(name.to_string()),
                    Some(d) => {
                        // Fix Python-isms in default values
                        let mut fixed = d.to_string();
                        // None → none
                        if fixed == "None" || fixed == "True" || fixed == "False" {
                            fixed = fixed.to_lowercase();
                        }
                        // Evaluate well-known dbt type functions to their SQL types
                        if fixed.contains('(') && fixed.contains(')') {
                            fixed = match fixed.trim() {
                                s if s.contains("type_string") => "'VARCHAR'".to_string(),
                                s if s.contains("type_varchar") => "'VARCHAR'".to_string(),
                                s if s.contains("type_timestamp") => "'TIMESTAMP'".to_string(),
                                s if s.contains("type_int") => "'INTEGER'".to_string(),
                                s if s.contains("type_bigint") => "'BIGINT'".to_string(),
                                s if s.contains("type_float") => "'DOUBLE'".to_string(),
                                s if s.contains("type_numeric") => "'NUMERIC'".to_string(),
                                s if s.contains("type_boolean") => "'BOOLEAN'".to_string(),
                                _ => "none".to_string(),
                            };
                        }
                        // List literals with dict inside → []
                        if fixed.starts_with('[') && fixed.contains('{') {
                            fixed = "[]".to_string();
                        }
                        Some(format!("{}={}", name, fixed))
                    }
                }
            })
            .collect()
    }

    /// Build a Jinja template string for a namespace, containing all its macro definitions.
    /// Preprocesses macro bodies to handle dict literals and {% do %} statements.
    /// Validates each macro individually and skips those that fail to parse.
    fn build_namespace_template(macros: &[LoadedMacro], target_type: &str, namespace_name: Option<&str>) -> String {
        let mut test_env = Environment::new();
        add_jinja2_compat(&mut test_env);
        // Collect macro names for dispatch resolution
        let macro_names: std::collections::HashSet<String> =
            macros.iter().map(|m| m.name.clone()).collect();

        // First pass: build macro strings and track which ones pass the probe
        struct MacroEntry {
            name: String,
            macro_str: String,
            dispatch_target: Option<String>, // set if this is a dispatcher macro
            passed_probe: bool,
        }
        let mut entries: Vec<MacroEntry> = Vec::new();

        for m in macros {
            let clean = Self::clean_args(&m.args);
            let args_str = clean.join(", ");
            let mut body = preprocess_macro_body(&m.body);
            let mut dispatch_target = None;

            // Strip self-namespace prefix from macro bodies so that macros
            // within the same namespace can call each other without the prefix.
            // e.g., inside "shopify" namespace: shopify.other_macro() → other_macro()
            // Only strip when followed by a known macro name to avoid false positives.
            if let Some(ns) = namespace_name {
                if !ns.is_empty() {
                    let prefix = format!("{}.", ns);
                    for known_macro in &macro_names {
                        let qualified = format!("{}{}", prefix, known_macro);
                        if body.contains(&qualified) {
                            body = body.replace(&qualified, known_macro);
                        }
                    }
                }
            }

            // Detect dispatcher macros: body calls adapter.dispatch('name')(...).
            // Patterns: `{{ return(adapter.dispatch('name')(args)) }}` or
            //           `{{ adapter.dispatch('name', ...)(args) }}`
            // Replace with a direct call to the best available variant.
            if body.contains("adapter.dispatch(") {
                let trimmed = body.trim();
                let is_dispatcher = trimmed.starts_with("{{ return(")
                    || trimmed.starts_with("{{return(")
                    || trimmed.starts_with("{{ adapter.dispatch(")
                    || trimmed.starts_with("{{adapter.dispatch(");
                if is_dispatcher {
                    if let Some(dispatched) = extract_dispatch_name(&body) {
                        // Try prefixes in order based on target type
                        let prefixes: Vec<&str> = match target_type {
                            "snowflake" => vec!["snowflake__", "default__", "postgres__"],
                            "duckdb" => vec!["duckdb__", "postgres__", "default__"],
                            "bigquery" => vec!["bigquery__", "default__", "postgres__"],
                            "redshift" => vec!["redshift__", "postgres__", "default__"],
                            "spark" | "databricks" => vec!["spark__", "default__", "postgres__"],
                            "postgres" => vec!["postgres__", "default__"],
                            _ => vec!["default__", "postgres__"],
                        };
                        let target = prefixes
                            .iter()
                            .map(|prefix| format!("{}{}", prefix, dispatched))
                            .find(|name| macro_names.contains(name))
                            .unwrap_or_else(|| format!("default__{}", dispatched));
                        dispatch_target = Some(target.clone());
                        body = format!("{{{{ {}({}) | trim }}}}", target, args_str);
                    } else {
                        body = String::new();
                    }
                }
            }
            let macro_str = format!(
                "{{% macro {}({}) %}}{}{{% endmacro %}}\n",
                m.name, args_str, body
            );
            // Validate that this macro can be parsed
            let mut probe = test_env.clone();
            let probe_result = probe.add_template_owned(format!("__probe_{}", m.name), macro_str.clone());
            if let Err(ref e) = probe_result {
                tracing::debug!("Macro '{}' failed probe: {}", m.name, e);
            }
            let passed = probe_result.is_ok();
            entries.push(MacroEntry {
                name: m.name.clone(),
                macro_str,
                dispatch_target,
                passed_probe: passed,
            });
        }

        // Collect names of macros that passed the probe
        let included_names: std::collections::HashSet<&str> = entries.iter()
            .filter(|e| e.passed_probe)
            .map(|e| e.name.as_str())
            .collect();

        // Second pass: build the template, fixing dispatchers whose targets were skipped
        let mut s = String::new();
        for entry in &entries {
            if !entry.passed_probe {
                continue;
            }
            if let Some(target) = &entry.dispatch_target {
                if !included_names.contains(target.as_str()) {
                    // Target macro was skipped — make dispatcher body empty
                    // so it doesn't call an undefined macro at render time
                    tracing::debug!(
                        "Dispatch target '{}' not available for '{}', using empty body",
                        target, entry.name
                    );
                    let clean = Self::clean_args(
                        &macros.iter().find(|m| m.name == entry.name)
                            .map(|m| m.args.clone()).unwrap_or_default()
                    );
                    let args_str = clean.join(", ");
                    s.push_str(&format!(
                        "{{% macro {}({}) %}}{{% endmacro %}}\n",
                        entry.name, args_str
                    ));
                    continue;
                }
            }
            s.push_str(&entry.macro_str);
        }
        s
    }

    /// Extract config key=value pairs from raw SQL before preprocessing strips the block.
    /// Parses simple patterns like `config(materialized='table', schema='analytics')`.
    fn extract_config_from_raw(sql: &str, config_values: &std::sync::Arc<std::sync::Mutex<std::collections::HashMap<String, String>>>) {
        // Process ALL config blocks in the SQL, not just the first
        let mut search_from = 0;
        while search_from < sql.len() {
            // Find the earliest config( in a {{ }} block
            let mut best: Option<(usize, usize)> = None; // (block_start, config_start)
            for pat in ["{{ config(", "{{config(", "{{- config(", "{{-config("] {
                if let Some(pos) = sql[search_from..].find(pat) {
                    let abs = search_from + pos;
                    let cs = abs + pat.len();
                    if best.is_none() || abs < best.unwrap().0 {
                        best = Some((abs, cs));
                    }
                }
            }
            let Some((_block_start, config_start)) = best else { break };

            // Find matching ) by tracking depth, handling escaped quotes
            let mut depth = 1i32;
            let mut i = config_start;
            let bytes = sql.as_bytes();
            let mut in_string: Option<u8> = None;
            while i < bytes.len() && depth > 0 {
                if let Some(q) = in_string {
                    if bytes[i] == b'\\' {
                        i += 1; // skip escaped character
                    } else if bytes[i] == q {
                        in_string = None;
                    }
                } else {
                    match bytes[i] {
                        b'\'' | b'"' => in_string = Some(bytes[i]),
                        b'(' => depth += 1,
                        b')' => depth -= 1,
                        _ => {}
                    }
                }
                if depth > 0 { i += 1; }
            }
            if depth == 0 {
                let config_content = &sql[config_start..i];
                let mut cv = config_values.lock().unwrap();
                for part in Self::split_config_args(config_content) {
                    if let Some(eq_pos) = part.find('=') {
                        let key = part[..eq_pos].trim();
                        let val = part[eq_pos + 1..].trim();
                        let val = val.trim_matches('\'').trim_matches('"');
                        cv.insert(key.to_string(), val.to_string());
                    }
                }
                search_from = i + 1;
            } else {
                break;
            }
        }
    }

    /// Split config arguments by comma, respecting parentheses and quotes.
    fn split_config_args(s: &str) -> Vec<String> {
        let mut parts = Vec::new();
        let mut current = String::new();
        let mut depth = 0i32;
        let mut in_string: Option<char> = None;
        for ch in s.chars() {
            if let Some(q) = in_string {
                current.push(ch);
                if ch == q { in_string = None; }
            } else {
                match ch {
                    '\'' | '"' => { current.push(ch); in_string = Some(ch); }
                    '(' | '[' => { depth += 1; current.push(ch); }
                    ')' | ']' => { depth -= 1; current.push(ch); }
                    ',' if depth == 0 => {
                        let trimmed = current.trim().to_string();
                        if !trimmed.is_empty() { parts.push(trimmed); }
                        current.clear();
                    }
                    _ => current.push(ch),
                }
            }
        }
        let trimmed = current.trim().to_string();
        if !trimmed.is_empty() { parts.push(trimmed); }
        parts
    }

    /// Pre-process SQL to handle Jinja patterns that minijinja doesn't support.
    fn preprocess_sql(sql: &str) -> String {
        let mut result = sql.to_string();

        // Strip {{ config(...) }} blocks — they contain complex Python expressions
        // (ternary operators, dict literals) that minijinja can't parse.
        // Config values are not needed for SQL compilation.
        result = strip_config_blocks(&result);

        // Replace {% call(x) statement(...) %} ... {% endcall %} with empty
        // These are dbt-specific and not supported by minijinja
        // Handle all endcall variants: {% endcall %}, {%- endcall -%}, {%- endcall %}, {% endcall -%}
        loop {
            if let Some(start) = result.find("{% call").or_else(|| result.find("{%- call")) {
                // Find any endcall variant
                let endcall_patterns = [
                    "{% endcall %}",
                    "{%- endcall -%}",
                    "{%- endcall %}",
                    "{% endcall -%}",
                ];
                let mut found_end = None;
                for pat in &endcall_patterns {
                    if let Some(pos) = result[start..].find(pat) {
                        let end = start + pos + pat.len();
                        match found_end {
                            None => found_end = Some(end),
                            Some(prev) => if end < prev { found_end = Some(end); }
                        }
                    }
                }
                if let Some(end) = found_end {
                    result.replace_range(start..end, "");
                    continue;
                }
            }
            break;
        }

        // Replace {% snapshot ... %} ... {% endsnapshot %} with empty
        loop {
            if let Some(start) = result.find("{% snapshot").or_else(|| result.find("{%- snapshot")) {
                let endsnap_patterns = [
                    "{% endsnapshot %}",
                    "{%- endsnapshot -%}",
                    "{%- endsnapshot %}",
                    "{% endsnapshot -%}",
                ];
                let mut found_end = None;
                for pat in &endsnap_patterns {
                    if let Some(pos) = result[start..].find(pat) {
                        let end = start + pos + pat.len();
                        match found_end {
                            None => found_end = Some(end),
                            Some(prev) => if end < prev { found_end = Some(end); }
                        }
                    }
                }
                if let Some(end) = found_end {
                    result.replace_range(start..end, "/* snapshot block */");
                    continue;
                }
            }
            break;
        }

        // Rewrite list/dict initializers to mutable variants when mutations are used
        result = rewrite_list_append(&result);
        result = rewrite_dict_mutation(&result);

        // Rewrite {% do expr %} → {% set _do_N = expr %} so minijinja evaluates mutations
        result = rewrite_do_statements(&result);

        // Strip Python .copy() calls — minijinja sequences don't have this method.
        // In dbt/Jinja2, .copy() creates a shallow copy to avoid mutation; safe to remove.
        result = result.replace(".copy()", "");

        // Strip Jinja comments {# ... #} that may confuse minijinja
        result = strip_jinja_comments(&result);

        // Replace multi-assignment `{% set a, b, c = expr %}` with individual sets to none
        result = strip_multi_set(&result);

        // Replace Python-style dict literals with none
        result = preprocess_dicts(&result);

        // Replace ternary expressions in kwargs that minijinja can't parse:
        // `key='val' if cond else 'alt'` → `key='val'`
        // This only affects keyword argument contexts.
        result = strip_ternary_in_kwargs(&result);

        // Rewrite list.append(item) → list = list + [item]
        result = rewrite_list_append(&result);

        // Strip list concatenation with macro calls/variables: `[...] + func()` or `[...] + var`
        // These fail in minijinja because macro calls return text, not lists.
        result = strip_list_concat(&result);

        // Fix unary negation of function calls: minijinja can't handle `-func(...)`.
        // Replace `=-func(` with `=(0 - func(` in Jinja expression contexts.
        result = fix_unary_negation(&result);

        // Wrap macro calls in {% set VAR = func(...) %} with _get_return() so that
        // dbt macros using {{ return(val) }} return structured values, not text.
        result = wrap_set_macro_calls(&result);

        result
    }

    /// Render a SQL template with the given dbt context.
    /// Returns the rendered SQL string.
    pub fn render(&self, sql: &str, ctx: &DbtContext) -> anyhow::Result<String> {
        let mut env = self.env.clone();

        // dbt and adapter globals are added later, after all template registration

        // Register namespace templates so {% import "dbt" as dbt %} works
        // For builtin namespaces that have a package override, merge in package macros
        // that aren't already defined as builtins (builtins take priority)
        let builtin_ns_names: std::collections::HashSet<&str> = self.builtin_namespaces.iter()
            .map(|ns| ns.name)
            .collect();
        for ns in &self.builtin_namespaces {
            let mut merged_macros = ns.macros.clone();
            // Add package macros that aren't already builtin
            if let Some(pkg_macros) = self.package_macros.get(ns.name) {
                let builtin_names: std::collections::HashSet<&str> = ns.macros.iter()
                    .map(|m| m.name.as_str())
                    .collect();
                for m in pkg_macros {
                    if !builtin_names.contains(m.name.as_str()) {
                        merged_macros.push(m.clone());
                    }
                }
            }
            let tmpl = Self::build_namespace_template(&merged_macros, &ctx.target_type, Some(ns.name));
            env.add_template_owned(ns.name.to_string(), tmpl)?;
        }

        // Register package namespaces that aren't already builtin
        let mut package_ns_names = Vec::new();
        for (pkg_name, pkg_macros) in &self.package_macros {
            if !builtin_ns_names.contains(pkg_name.as_str()) {
                let tmpl = Self::build_namespace_template(pkg_macros, &ctx.target_type, Some(pkg_name));
                match env.add_template_owned(pkg_name.clone(), tmpl) {
                    Ok(_) => { package_ns_names.push(pkg_name.clone()); }
                    Err(_) => { /* skip if template fails to parse */ }
                }
            }
        }

        // All custom macros are included — their bodies are preprocessed
        // in build_namespace_template() to handle {% do %}, dict literals, etc.
        let safe_macros: Vec<&LoadedMacro> = self.custom_macros.iter().collect();

        // Register custom macros as a project-level namespace template
        // Auto-import builtin namespaces so macros can call dbt.type_string(), etc.
        let mut project_ns_ok = false;
        if !safe_macros.is_empty() && !ctx.project_name.is_empty() {
            let safe_owned: Vec<LoadedMacro> = safe_macros.iter().map(|m| (*m).clone()).collect();
            let project_tmpl = Self::build_namespace_template(&safe_owned, &ctx.target_type, Some(&ctx.project_name));
            match env.add_template_owned(ctx.project_name.clone(), project_tmpl) {
                Ok(_) => { project_ns_ok = true; }
                Err(_) => { /* skip namespace import if template fails to parse */ }
            }
        }

        // Build macro prefix: prepend namespace imports + custom macro definitions
        let mut macro_prefix = String::new();

        // Auto-import all builtin namespaces
        // Use a prefixed alias for "dbt" to avoid shadowing the dbt global
        // (add_jinja2_compat breaks imported-template macros when an import
        // variable shadows a global of the same name).
        for ns in &self.builtin_namespaces {
            let alias = if ns.name == "dbt" {
                "_dbt_macros".to_string()
            } else {
                ns.name.to_string()
            };
            macro_prefix.push_str(&format!(
                "{{% import \"{}\" as {} %}}\n",
                ns.name, alias
            ));
        }

        // Auto-import package namespaces
        for pkg_name in &package_ns_names {
            macro_prefix.push_str(&format!(
                "{{% import \"{}\" as {} %}}\n",
                pkg_name, pkg_name
            ));
        }

        // Auto-import project namespace if registered successfully
        if project_ns_ok {
            macro_prefix.push_str(&format!(
                "{{% import \"{}\" as {} %}}\n",
                ctx.project_name, ctx.project_name
            ));
        }

        // Add bare macros with preprocessed bodies (only those that parse)
        {
            let mut test_env = Environment::new();
            add_jinja2_compat(&mut test_env);
            let bare_macro_names: std::collections::HashSet<String> =
                safe_macros.iter().map(|m| m.name.clone()).collect();
            for m in &safe_macros {
                let clean = Self::clean_args(&m.args);
                let args_str = clean.join(", ");
                let mut body = preprocess_macro_body(&m.body);
                // Detect dispatcher macros: body calls adapter.dispatch('name')(...).
                if body.contains("adapter.dispatch(") {
                    let trimmed = body.trim();
                    let is_dispatcher = trimmed.starts_with("{{ return(")
                        || trimmed.starts_with("{{return(")
                        || trimmed.starts_with("{{ adapter.dispatch(")
                        || trimmed.starts_with("{{adapter.dispatch(");
                    if is_dispatcher {
                        if let Some(dispatched) = extract_dispatch_name(&body) {
                            let prefixes: Vec<&str> = match ctx.target_type.as_str() {
                                "snowflake" => vec!["snowflake__", "default__", "postgres__"],
                                "duckdb" => vec!["duckdb__", "postgres__", "default__"],
                                "bigquery" => vec!["bigquery__", "default__", "postgres__"],
                                "redshift" => vec!["redshift__", "postgres__", "default__"],
                                "spark" | "databricks" => vec!["spark__", "default__", "postgres__"],
                                "postgres" => vec!["postgres__", "default__"],
                                _ => vec!["default__", "postgres__"],
                            };
                            let target = prefixes
                                .iter()
                                .map(|prefix| format!("{}{}", prefix, dispatched))
                                .find(|name| bare_macro_names.contains(name))
                                .unwrap_or_else(|| format!("default__{}", dispatched));
                            body = format!("{{{{ {}({}) | trim }}}}", target, args_str);
                        } else {
                            body = String::new();
                        }
                    }
                }
                let macro_str = format!(
                    "{{% macro {}({}) %}}{}{{% endmacro %}}\n",
                    m.name, args_str, body
                );
                let mut probe = test_env.clone();
                if probe.add_template_owned(format!("__probe_{}", m.name), macro_str.clone()).is_ok() {
                    macro_prefix.push_str(&macro_str);
                }
            }
        }

        // Pre-process SQL for unsupported Jinja patterns
        let processed_sql = Self::preprocess_sql(sql);
        let full_template = format!("{macro_prefix}{processed_sql}");



        // Register the template; fall back to import-only prefix on parse errors
        if env.add_template_owned("__model__".to_string(), full_template).is_err() {
            let mut fallback_prefix = String::new();
            for ns in &self.builtin_namespaces {
                let alias = if ns.name == "dbt" {
                    "_dbt_macros".to_string()
                } else {
                    ns.name.to_string()
                };
                fallback_prefix.push_str(&format!(
                    "{{% import \"{}\" as {} %}}\n",
                    ns.name, alias
                ));
            }
            if project_ns_ok {
                fallback_prefix.push_str(&format!(
                    "{{% import \"{}\" as {} %}}\n",
                    ctx.project_name, ctx.project_name
                ));
            }
            let fallback_template = format!("{fallback_prefix}{processed_sql}");
            env.add_template_owned("__model__".to_string(), fallback_template)?;
        }

        // Build the context variables
        let refs = ctx.refs.clone();
        let sources = ctx.sources.clone();
        let config_values = ctx.config_values.clone();

        // Extract config values from raw SQL before preprocessing strips the config block.
        Self::extract_config_from_raw(sql, &config_values);

        let execute = ctx.execute;
        let ref_resolutions = ctx.ref_resolutions.clone();
        let source_resolutions = ctx.source_resolutions.clone();
        let vars = ctx.vars.clone();
        let target_name = ctx.target_name.clone();
        let target_schema = ctx.target_schema.clone();
        let target_database = ctx.target_database.clone();
        let target_type = ctx.target_type.clone();
        let project_name = ctx.project_name.clone();
        let is_incremental = ctx.is_incremental;
        let this_relation = ctx.this_relation.clone();

        // Register ref() function
        let refs_clone = refs.clone();
        let ref_resolutions_clone = ref_resolutions.clone();
        env.add_function("ref", move |args: &[Value]| -> Result<Value, JinjaError> {
            let (model_name, package) = parse_ref_args(args)?;

            refs_clone.lock().unwrap().push(RefCall {
                model_name: model_name.clone(),
                package: package.clone(),
                version: None,
            });

            if execute {
                if let Some(relation) = ref_resolutions_clone.get(&model_name) {
                    Ok(Value::from(relation.as_str()))
                } else {
                    Ok(Value::from(model_name))
                }
            } else {
                Ok(Value::from(format!("__dbt__cte__{model_name}")))
            }
        });

        // Register source() function — returns a RelationObject with .database/.schema/.identifier
        let sources_clone = sources.clone();
        let source_resolutions_clone = source_resolutions.clone();
        env.add_function(
            "source",
            move |args: &[Value]| -> Result<Value, JinjaError> {
                if args.len() < 2 {
                    return Err(JinjaError::new(
                        ErrorKind::MissingArgument,
                        "source() requires two arguments: source_name, table_name",
                    ));
                }
                let source_name = args[0].to_string();
                let table_name = args[1].to_string();

                sources_clone.lock().unwrap().push(SourceCall {
                    source_name: source_name.clone(),
                    table_name: table_name.clone(),
                });

                let key = (source_name.clone(), table_name.clone());
                if let Some(info) = source_resolutions_clone.get(&key) {
                    Ok(Value::from_object(RelationObject::with_rendered(
                        &info.database,
                        &info.schema,
                        &info.identifier,
                        info.rendered.clone(),
                    )))
                } else {
                    // Fallback: construct a basic relation from the args
                    Ok(Value::from_object(RelationObject::new(
                        "",
                        &source_name,
                        &table_name,
                    )))
                }
            },
        );

        // Register config() function
        let config_values_clone = config_values.clone();
        env.add_function(
            "config",
            move |args: &[Value]| -> Result<Value, JinjaError> {
                let mut cv = config_values_clone.lock().unwrap();
                for arg in args {
                    if let Some(obj) = arg.as_object() {
                        if let Some(iter) = obj.try_iter() {
                            for key in iter {
                                let key_str = key.to_string();
                                if let Some(val) = obj.get_value(&Value::from(key_str.as_str())) {
                                    cv.insert(key_str, val.to_string());
                                }
                            }
                        }
                    }
                }
                Ok(Value::from(""))
            },
        );

        // Register var() function
        let vars_clone = vars.clone();
        env.add_function("var", move |args: &[Value]| -> Result<Value, JinjaError> {
            let var_name = args
                .first()
                .ok_or_else(|| {
                    JinjaError::new(ErrorKind::MissingArgument, "var() requires a name argument")
                })?
                .to_string();

            let default = args.get(1);

            if let Some(val) = vars_clone.get(&var_name) {
                Ok(yaml_to_minijinja(val))
            } else if let Some(default) = default {
                Ok(default.clone())
            } else {
                // Return UNDEFINED for vars with no default and no value.
                Ok(Value::UNDEFINED)
            }
        });

        // Register env_var() function
        env.add_function(
            "env_var",
            |args: &[Value]| -> Result<Value, JinjaError> {
                let var_name = args
                    .first()
                    .ok_or_else(|| {
                        JinjaError::new(
                            ErrorKind::MissingArgument,
                            "env_var() requires a name argument",
                        )
                    })?
                    .to_string();

                let default = args.get(1);

                match std::env::var(&var_name) {
                    Ok(val) => Ok(Value::from(val)),
                    Err(_) => {
                        if let Some(d) = default {
                            Ok(d.clone())
                        } else {
                            Err(JinjaError::new(
                                ErrorKind::InvalidOperation,
                                format!("Environment variable '{var_name}' not set"),
                            ))
                        }
                    }
                }
            },
        );

        // Register is_incremental() function
        env.add_function(
            "is_incremental",
            move || -> Result<Value, JinjaError> {
                Ok(Value::from(is_incremental))
            },
        );

        // Register return() function (dbt macro helper — stores value in thread-local
        // so _get_return() can recover the structured value after a macro call,
        // AND returns the value directly so {{ return(val) }} renders val as text)
        env.add_function(
            "return",
            |args: &[Value]| -> Result<Value, JinjaError> {
                let val = args.first().cloned().unwrap_or(Value::UNDEFINED);
                LAST_RETURN_VALUE.with(|v| *v.borrow_mut() = Some(val.clone()));
                Ok(val)
            },
        );

        // Register _get_return(text_output) — recovers structured return values from macro calls.
        // In dbt, macros can use {{ return(val) }} to return structured data (lists, dicts).
        // In minijinja, macros return text. This function bridges the gap:
        // - If return() was called during the macro, drain the stored value and return it
        // - Otherwise, return the text output as-is
        env.add_function(
            "_get_return",
            |args: &[Value]| -> Result<Value, JinjaError> {
                let fallback = args.first().cloned().unwrap_or(Value::UNDEFINED);
                let stored = LAST_RETURN_VALUE.with(|v| v.borrow_mut().take());
                Ok(stored.unwrap_or(fallback))
            },
        );

        // Register load_result() stub — dbt internal for operation results (not supported)
        env.add_function(
            "load_result",
            |_: &[Value]| -> Result<Value, JinjaError> {
                Ok(Value::UNDEFINED)
            },
        );

        // Register _fill_staging_columns_impl(source_columns, staging_columns)
        // Implements dbt's fill_staging_columns: for each expected staging column,
        // output the column if it exists in source, or CAST(NULL AS type) if missing.
        env.add_function(
            "_fill_staging_columns_impl",
            |args: &[Value]| -> Result<Value, JinjaError> {
                let source_columns = args.first().cloned().unwrap_or_else(|| Value::from(Vec::<Value>::new()));
                // staging_columns may be an empty string when the caller is a
                // Jinja macro that used return() — the structured value lives in
                // LAST_RETURN_VALUE.  Fall back to it when the arg is not a list.
                let staging_columns_val = args.get(1).cloned()
                    .filter(|v| v.kind() == minijinja::value::ValueKind::Seq)
                    .or_else(|| LAST_RETURN_VALUE.with(|v| v.borrow_mut().take()))
                    .unwrap_or_else(|| Value::from(Vec::<Value>::new()));

                // Build set of source column names (uppercase for case-insensitive matching)
                let mut source_names = std::collections::HashSet::new();
                if let Ok(iter) = source_columns.try_iter() {
                    for item in iter {
                        let name = item.get_attr("name")
                            .ok()
                            .map(|v: Value| v.to_string())
                            .unwrap_or_default();
                        if !name.is_empty() {
                            source_names.insert(name.to_uppercase());
                        }
                    }
                }

                // If no source columns known, use staging columns and cast all as NULL
                if source_names.is_empty() {
                    let mut parts = Vec::new();
                    if let Ok(iter) = staging_columns_val.try_iter() {
                        for item in iter {
                            let name = item.get_attr("name")
                                .ok()
                                .map(|v: Value| v.to_string())
                                .unwrap_or_default();
                            if name.is_empty() {
                                continue;
                            }
                            let datatype = item.get_attr("datatype")
                                .ok()
                                .map(|v: Value| {
                                    let s = v.to_string();
                                    if s.is_empty() || s == "undefined" || s == "none" || s == "None" {
                                        "VARCHAR".to_string()
                                    } else {
                                        s
                                    }
                                })
                                .unwrap_or_else(|| "VARCHAR".to_string());
                            let alias = item.get_attr("alias")
                                .ok()
                                .and_then(|v: Value| {
                                    let s = v.to_string();
                                    if s.is_empty() || s == "undefined" || s == "none" || s == "None" {
                                        None
                                    } else {
                                        Some(s)
                                    }
                                });
                            let output_name = alias.as_deref().unwrap_or(&name);
                            parts.push(format!("cast(null as {}) as {}", datatype, output_name));
                        }
                    }
                    if parts.is_empty() {
                        return Ok(Value::from("*"));
                    }
                    return Ok(Value::from(format!("\n    {}", parts.join(",\n    "))));
                }

                // Build output: for each staging column, emit source col or CAST(NULL)
                let mut parts = Vec::new();
                if let Ok(iter) = staging_columns_val.try_iter() {
                    for item in iter {
                        let name = item.get_attr("name")
                            .ok()
                            .map(|v: Value| v.to_string())
                            .unwrap_or_default();
                        if name.is_empty() {
                            continue;
                        }
                        let datatype = item.get_attr("datatype")
                            .ok()
                            .map(|v: Value| {
                                let s = v.to_string();
                                if s.is_empty() || s == "undefined" || s == "none" || s == "None" {
                                    "VARCHAR".to_string()
                                } else {
                                    s
                                }
                            })
                            .unwrap_or_else(|| "VARCHAR".to_string());
                        let alias = item.get_attr("alias")
                            .ok()
                            .and_then(|v: Value| {
                                let s = v.to_string();
                                if s.is_empty() || s == "undefined" || s == "none" || s == "None" {
                                    None
                                } else {
                                    Some(s)
                                }
                            });
                        let output_name = alias.as_deref().unwrap_or(&name);

                        if source_names.contains(&name.to_uppercase()) {
                            // Column exists in source — select it, with alias if needed
                            if alias.is_some() {
                                parts.push(format!("{} as {}", name, output_name));
                            } else {
                                parts.push(name);
                            }
                        } else {
                            // Column missing — output CAST(NULL AS type)
                            parts.push(format!("cast(null as {}) as {}", datatype, output_name));
                        }
                    }
                }

                if parts.is_empty() {
                    return Ok(Value::from("*"));
                }

                Ok(Value::from(format!("\n    {}", parts.join(",\n    "))))
            },
        );

        // Register log() function (no-op in airform)
        env.add_function(
            "log",
            |_args: &[Value]| -> Result<Value, JinjaError> {
                Ok(Value::from(""))
            },
        );

        // Register set() function
        env.add_function(
            "set",
            |args: &[Value]| -> Result<Value, JinjaError> {
                Ok(args.first().cloned().unwrap_or(Value::from(Vec::<Value>::new())))
            },
        );

        // Register run_query() — stub that returns empty result
        env.add_function(
            "run_query",
            |_args: &[Value]| -> Result<Value, JinjaError> {
                Ok(Value::from(Vec::<Value>::new()))
            },
        );

        // Register fromjson helper
        env.add_function(
            "fromjson",
            |args: &[Value]| -> Result<Value, JinjaError> {
                Ok(args.first().cloned().unwrap_or(Value::UNDEFINED))
            },
        );

        // Register modules as empty
        env.add_function(
            "modules",
            || -> Result<Value, JinjaError> {
                Ok(Value::UNDEFINED)
            },
        );

        // Register statement() — used in {% call statement(...) %} blocks
        // Now that we strip call blocks, this shouldn't be needed but keep as safety net
        env.add_function(
            "statement",
            |_args: &[Value]| -> Result<Value, JinjaError> {
                Ok(Value::from(""))
            },
        );

        // Stub for get_column_schema_from_query — runtime database introspection
        // Returns empty list; compile-only so no actual DB access
        env.add_function(
            "get_column_schema_from_query",
            |_args: &[Value]| -> Result<Value, JinjaError> {
                Ok(Value::from(Vec::<Value>::new()))
            },
        );

        // Build target context object
        let target_obj = Value::from_serialize(&TargetObj {
            name: target_name,
            schema: target_schema,
            database: target_database,
            r#type: target_type,
            profile_name: project_name,
        });

        // Build adapter object with column info from context
        let adapter_obj = Value::from_object(AdapterObject {
            relation_columns: ctx.relation_columns.clone(),
            target_type: ctx.target_type.clone(),
        });

        // Build dbt namespace object — accessible from inside macros (unlike {% import %})
        let dbt_obj = Value::from_object(DbtNamespaceObject {});

        // Add dbt and adapter as globals so they're accessible in ALL templates,
        // including namespace templates where macros call dbt.type_string() etc.
        env.add_global("dbt", dbt_obj.clone());
        env.add_global("adapter", adapter_obj.clone());

        // First render attempt
        let first_err = {
            let tmpl = env.get_template("__model__")?;
            match tmpl.render(minijinja::context! {
                execute => execute,
                target => &target_obj,
                adapter => &adapter_obj,
                dbt => &dbt_obj,
                this => this_relation.as_ref().map(|r| Value::from(r.as_str())).unwrap_or(Value::UNDEFINED),
            }) {
                Ok(r) => return Ok(r),
                Err(e) => e,
            }
        }; // tmpl dropped here, env borrow released

        // Retry strategy: if error is "unknown keyword argument" or "too many arguments",
        // strip the problematic macro call from the template line and retry.
        // Loop to handle multiple bad lines (up to a reasonable limit).
        let mut last_err = first_err;
        for _attempt in 0..10 {
            let err_str = last_err.to_string();
            let det = last_err.detail().unwrap_or("").to_string();
            let is_kwarg_error = err_str.contains("unknown keyword argument")
                || det.contains("unknown keyword argument")
                || err_str.contains("too many arguments")
                || det.contains("too many arguments");

            if !is_kwarg_error {
                break;
            }

            let Some(line_no) = last_err.line() else { break };

            let source = env.get_template("__model__")?.source().to_string();
            let lines: Vec<&str> = source.lines().collect();
            if line_no == 0 || (line_no as usize) > lines.len() {
                break;
            }
            let bad_line = lines[line_no as usize - 1];
            let stripped = strip_jinja_expressions(bad_line);
            // Use replacen to only replace the first occurrence of this exact line
            let cleaned = source.replacen(bad_line, &stripped, 1);
            if env.add_template_owned("__model__".to_string(), cleaned).is_err() {
                break;
            }

            let render_result = {
                let Ok(tmpl2) = env.get_template("__model__") else { break };
                tmpl2.render(minijinja::context! {
                    execute => execute,
                    target => &target_obj,
                    adapter => &adapter_obj,
                    dbt => &dbt_obj,
                    this => this_relation.as_ref().map(|r| Value::from(r.as_str())).unwrap_or(Value::UNDEFINED),
                })
            };
            match render_result {
                Ok(r) => return Ok(r),
                Err(e) => { last_err = e; }
            }
        }

        // Build error message with diagnostics
        let final_detail = last_err.detail().unwrap_or("").to_string();
        let mut msg = last_err.to_string();
        // Read line content from the template that actually errored (not always __model__)
        if let Some(line_no) = last_err.line() {
            let err_tmpl_name = last_err.name().unwrap_or("__model__");
            let tmpl_to_read = if err_tmpl_name == "__model__" {
                env.get_template("__model__").ok()
            } else {
                env.get_template(err_tmpl_name).ok()
                    .or_else(|| env.get_template("__model__").ok())
            };
            if let Some(tmpl_err) = tmpl_to_read {
                let source = tmpl_err.source();
                let lines: Vec<&str> = source.lines().collect();
                if line_no > 0 && (line_no as usize) <= lines.len() {
                    let content = lines[line_no as usize - 1].trim();
                    msg = format!("{} [line content: {}]", msg, content);
                }
            }
        }
        if !final_detail.is_empty() {
            msg = format!("{} [detail: {}]", msg, final_detail);
        }
        Err(anyhow::anyhow!("{}", msg))
    }
}

impl Default for JinjaEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[derive(serde::Serialize)]
struct TargetObj {
    name: String,
    schema: String,
    database: String,
    r#type: String,
    profile_name: String,
}

/// Render a minijinja Value as a SQL-safe string.
/// For string values, returns the raw string content (not wrapped in quotes).
/// For other types, returns the display representation.
fn render_value(val: &Value) -> String {
    if let Some(s) = val.as_str() {
        s.to_string()
    } else {
        val.to_string()
    }
}

/// Global dbt namespace object — accessible from inside macros (unlike {% import %}).
/// Extract an argument by position or by kwargs name from method args.
/// MiniJinja passes kwargs as the last element of args (a Kwargs map).
fn get_method_arg(args: &[Value], pos: usize, kwarg_names: &[&str]) -> String {
    // First try positional (non-kwargs values)
    if let Some(val) = args.get(pos) {
        if !val.is_kwargs() {
            return render_value(val);
        }
    }
    // Try kwargs (last arg if it's a kwargs map)
    if let Some(last) = args.last() {
        if last.is_kwargs() {
            for name in kwarg_names {
                if let Ok(val) = last.get_attr(name) {
                    let s = render_value(&val);
                    if !s.is_empty() && s != "undefined" {
                        return s;
                    }
                }
            }
        }
    }
    String::new()
}

/// Provides dbt.type_string(), dbt.date_trunc(), etc.
#[derive(Debug)]
struct DbtNamespaceObject {}

impl fmt::Display for DbtNamespaceObject {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "<dbt>")
    }
}

impl minijinja::value::Object for DbtNamespaceObject {
    fn call_method(
        self: &Arc<Self>,
        _state: &minijinja::State,
        method: &str,
        args: &[Value],
    ) -> Result<Value, JinjaError> {
        match method {
            "type_string" => Ok(Value::from("VARCHAR")),
            "type_timestamp" => Ok(Value::from("TIMESTAMP")),
            "type_int" => Ok(Value::from("INTEGER")),
            "type_bigint" => Ok(Value::from("BIGINT")),
            "type_float" => Ok(Value::from("DOUBLE")),
            "type_numeric" => Ok(Value::from("NUMERIC")),
            "type_boolean" => Ok(Value::from("BOOLEAN")),
            "date_trunc" => {
                let datepart = get_method_arg(args, 0, &["datepart"]);
                let field = get_method_arg(args, 1, &["field", "relation"]);
                Ok(Value::from(format!("DATE_TRUNC('{datepart}', {field})")))
            }
            "dateadd" => {
                let datepart = get_method_arg(args, 0, &["datepart"]);
                let interval = get_method_arg(args, 1, &["interval"]);
                let from_date = get_method_arg(args, 2, &["from_date_or_timestamp"]);
                let is_snowflake = _state
                    .lookup("target")
                    .and_then(|t| t.get_attr("type").ok())
                    .map(|t| t.to_string() == "snowflake")
                    .unwrap_or(false);
                if is_snowflake {
                    Ok(Value::from(format!("DATEADD({datepart}, {interval}, {from_date})")))
                } else {
                    Ok(Value::from(format!("{from_date} + INTERVAL '{interval}' {datepart}")))
                }
            }
            "datediff" => {
                // dbt convention: datediff(first_date, second_date, datepart)
                let first_date = get_method_arg(args, 0, &["first_date"]);
                let second_date = get_method_arg(args, 1, &["second_date"]);
                let datepart = get_method_arg(args, 2, &["datepart"]);
                let is_snowflake = _state
                    .lookup("target")
                    .and_then(|t| t.get_attr("type").ok())
                    .map(|t| t.to_string() == "snowflake")
                    .unwrap_or(false);
                if is_snowflake {
                    Ok(Value::from(format!(
                        "DATEDIFF({datepart}, {first_date}, {second_date})"
                    )))
                } else {
                    Ok(Value::from(format!(
                        "DATE_DIFF('{datepart}', {first_date}, {second_date})"
                    )))
                }
            }
            "safe_cast" => {
                let field = get_method_arg(args, 0, &["field"]);
                let r#type = get_method_arg(args, 1, &["type"]);
                Ok(Value::from(format!("TRY_CAST({field} AS {type})")))
            }
            "cast" => {
                let field = get_method_arg(args, 0, &["field"]);
                let r#type = get_method_arg(args, 1, &["type"]);
                Ok(Value::from(format!("CAST({field} AS {type})")))
            }
            "current_timestamp" | "current_timestamp_backcompat" => {
                Ok(Value::from("CURRENT_TIMESTAMP"))
            }
            "current_timestamp_in_utc_backcompat" => {
                Ok(Value::from("CURRENT_TIMESTAMP AT TIME ZONE 'UTC'"))
            }
            "concat" => {
                // dbt.concat() takes a single list argument
                let list = args.first().cloned().unwrap_or_default();
                let fields: Vec<String> = if let Ok(iter) = list.try_iter() {
                    iter.map(|v| render_value(&v)).collect()
                } else {
                    // Fallback: treat all args as individual items
                    args.iter().map(|v| render_value(v)).collect()
                };
                Ok(Value::from(format!("CONCAT({})", fields.join(", "))))
            }
            "split_part" => {
                let string = get_method_arg(args, 0, &["string_text", "string"]);
                let delimiter = get_method_arg(args, 1, &["delimiter_text", "delimiter"]);
                let part = get_method_arg(args, 2, &["part_number", "part"]);
                Ok(Value::from(format!("SPLIT_PART({string}, {delimiter}, {part})")))
            }
            "hash" => {
                let field = args.first().map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("MD5({field})")))
            }
            "position" => {
                let substr = args.first().map(|v| v.to_string()).unwrap_or_default();
                let string = args.get(1).map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("POSITION({substr} IN {string})")))
            }
            "length" => {
                let field = args.first().map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("LENGTH({field})")))
            }
            "right" => {
                let string = args.first().map(|v| v.to_string()).unwrap_or_default();
                let length = args.get(1).map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("RIGHT({string}, {length})")))
            }
            "replace" => {
                let field = args.first().map(|v| v.to_string()).unwrap_or_default();
                let old = args.get(1).map(|v| v.to_string()).unwrap_or_default();
                let new = args.get(2).map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("REPLACE({field}, {old}, {new})")))
            }
            "except" => Ok(Value::from("EXCEPT")),
            "listagg" | "string_agg" => {
                let field = args.first().map(|v| v.to_string()).unwrap_or_default();
                let delimiter = args.get(1).map(|v| v.to_string()).unwrap_or("','".to_string());
                let is_snowflake = _state
                    .lookup("target")
                    .and_then(|t| t.get_attr("type").ok())
                    .map(|t| t.to_string() == "snowflake")
                    .unwrap_or(false);
                if is_snowflake {
                    Ok(Value::from(format!("LISTAGG({field}, {delimiter})")))
                } else {
                    Ok(Value::from(format!("STRING_AGG({field}, {delimiter})")))
                }
            }
            "bool_or" => {
                let val = args.first().map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("BOOL_OR({val})")))
            }
            "any_value" => {
                let val = args.first().map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("ANY_VALUE({val})")))
            }
            "generate_series" => {
                let start = args.first().map(|v| v.to_string()).unwrap_or_default();
                let stop = args.get(1).map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("GENERATE_SERIES({start}, {stop})")))
            }
            "escape_single_quotes" => {
                let val = args.first().map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(val.replace('\'', "''")))
            }
            "cast_bool_to_text" => {
                let field = args.first().map(|v| v.to_string()).unwrap_or_default();
                Ok(Value::from(format!("CAST({field} AS VARCHAR)")))
            }
            "last_day" => {
                let date = get_method_arg(args, 0, &["date"]);
                Ok(Value::from(format!("LAST_DAY({date})")))
            }
            "now" => Ok(Value::from("CURRENT_TIMESTAMP")),
            "current_timestamp_in_utc" => {
                Ok(Value::from("CURRENT_TIMESTAMP"))
            }
            _ => {
                // Fall back to trying template-level macro
                Ok(Value::from(""))
            }
        }
    }
}

/// A dbt Relation object with `.database`, `.schema`, `.identifier` attributes.
/// Renders to a SQL-safe qualified name when used in string context.
#[derive(Debug, Clone)]
struct RelationObject {
    database: String,
    schema: String,
    identifier: String,
    /// The rendered string form for SQL: "schema"."table" or "db"."schema"."table"
    rendered: String,
    /// Include database prefix in rendered output
    include_database: bool,
}

impl RelationObject {
    fn new(database: &str, schema: &str, identifier: &str) -> Self {
        let rendered = format!("{schema}.{identifier}");
        Self {
            database: database.to_string(),
            schema: schema.to_string(),
            identifier: identifier.to_string(),
            rendered,
            include_database: false,
        }
    }

    fn with_rendered(database: &str, schema: &str, identifier: &str, rendered: String) -> Self {
        Self {
            database: database.to_string(),
            schema: schema.to_string(),
            identifier: identifier.to_string(),
            rendered,
            include_database: false,
        }
    }
}

impl fmt::Display for RelationObject {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.rendered)
    }
}

impl minijinja::value::Object for RelationObject {
    fn repr(self: &Arc<Self>) -> minijinja::value::ObjectRepr {
        minijinja::value::ObjectRepr::Plain
    }

    fn get_value(self: &Arc<Self>, key: &Value) -> Option<Value> {
        match key.as_str()? {
            "database" => Some(Value::from(self.database.as_str())),
            "schema" => Some(Value::from(self.schema.as_str())),
            "identifier" => Some(Value::from(self.identifier.as_str())),
            "name" => Some(Value::from(self.identifier.as_str())),
            "table" => Some(Value::from(self.identifier.as_str())),
            "include_policy" | "quote_policy" => Some(Value::from("")),
            _ => None,
        }
    }

    fn render(self: &Arc<Self>, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.rendered)
    }

    fn call_method(
        self: &Arc<Self>,
        _state: &minijinja::State,
        method: &str,
        _args: &[Value],
    ) -> Result<Value, JinjaError> {
        match method {
            "render" | "__str__" => Ok(Value::from(self.rendered.as_str())),
            "include" => {
                // Return self — dbt's `relation.include(database=False)` etc.
                Ok(Value::from_object(self.as_ref().clone()))
            }
            _ => Ok(Value::from(self.rendered.as_str())),
        }
    }
}

/// Stub adapter object that provides dbt adapter methods.
#[derive(Debug)]
struct AdapterObject {
    /// Known columns for relations, keyed by model/seed name.
    relation_columns: std::collections::HashMap<String, Vec<String>>,
    /// Target type (e.g. "snowflake", "bigquery", "duckdb").
    target_type: String,
}

impl fmt::Display for AdapterObject {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "<adapter>")
    }
}

impl minijinja::value::Object for AdapterObject {
    fn call_method(
        self: &Arc<Self>,
        _state: &minijinja::State,
        method: &str,
        args: &[Value],
    ) -> Result<Value, JinjaError> {
        match method {
            "get_columns_in_relation" => {
                // Extract the relation identifier from the argument
                let identifier = if let Some(arg) = args.first() {
                    // Try to get .identifier attribute (RelationObject)
                    arg.get_attr("identifier")
                        .ok()
                        .filter(|v| !v.is_undefined() && !v.is_none())
                        .map(|v| v.to_string())
                        .or_else(|| {
                            // Try .name attribute
                            arg.get_attr("name").ok()
                                .filter(|v| !v.is_undefined() && !v.is_none())
                                .map(|v| v.to_string())
                        })
                        .unwrap_or_else(|| {
                            // Fall back to string representation, extract last part
                            let s = arg.to_string();
                            s.rsplit('.').next().unwrap_or(&s).to_string()
                        })
                } else {
                    return Ok(Value::from(Vec::<Value>::new()));
                };

                // Clean up identifier: strip quotes, schema prefix, __dbt__cte__ prefix
                let clean_id = identifier.trim_matches('"').trim_matches('\'');
                let clean_id = clean_id.strip_prefix("__dbt__cte__").unwrap_or(clean_id);

                // Look up columns by identifier (case-insensitive)
                let cols = self.relation_columns.get(clean_id)
                    .or_else(|| self.relation_columns.get(&clean_id.to_uppercase()))
                    .or_else(|| self.relation_columns.get(&clean_id.to_lowercase()));

                if cols.is_none() {
                    tracing::debug!(
                        "get_columns_in_relation: no columns for '{}', available={}",
                        clean_id, self.relation_columns.len()
                    );
                }

                if let Some(columns) = cols {
                    // Return column objects with .name and .datatype attributes.
                    // For Snowflake targets, uppercase column names to match how
                    // Snowflake normalizes unquoted identifiers.
                    let is_snowflake = self.target_type == "snowflake";
                    let col_values: Vec<Value> = columns.iter().map(|name| {
                        let mut map = std::collections::BTreeMap::new();
                        let col_name = if is_snowflake { name.to_uppercase() } else { name.clone() };
                        map.insert("name".to_string(), Value::from(col_name));
                        map.insert("datatype".to_string(), Value::from("VARCHAR"));
                        Value::from(map)
                    }).collect();
                    Ok(Value::from(col_values))
                } else {
                    Ok(Value::from(Vec::<Value>::new()))
                }
            }
            "get_relation" => {
                // Extract kwargs: adapter.get_relation(database=..., schema=..., identifier=...)
                use minijinja::value::{Kwargs, from_args};
                let mut database = String::new();
                let mut schema = String::new();
                let mut identifier = String::new();
                if let Ok((_rest, kwargs)) = from_args::<(&[Value], Kwargs)>(args) {
                    if let Some(v) = kwargs.get::<Option<String>>("database").ok().flatten() {
                        database = v;
                    }
                    if let Some(v) = kwargs.get::<Option<String>>("schema").ok().flatten() {
                        schema = v;
                    }
                    if let Some(v) = kwargs.get::<Option<String>>("identifier").ok().flatten() {
                        identifier = v;
                    }
                }
                // Fallback: try positional args
                if database.is_empty() && schema.is_empty() && identifier.is_empty() {
                    for (i, arg) in args.iter().enumerate() {
                        let s = arg.to_string();
                        if s != "none" && s != "undefined" {
                            match i {
                                0 => database = s,
                                1 => schema = s,
                                2 => identifier = s,
                                _ => {}
                            }
                        }
                    }
                }
                Ok(Value::from_object(RelationObject::new(&database, &schema, &identifier)))
            }
            "dispatch" => {
                let macro_name = args
                    .first()
                    .map(|v| v.to_string())
                    .unwrap_or_default();
                // Build a fallback chain: try adapter-specific variant first, then default__
                let target_type = _state
                    .lookup("target")
                    .and_then(|t| t.get_attr("type").ok())
                    .map(|t| t.to_string())
                    .unwrap_or_default();
                let mut candidates = Vec::new();
                match target_type.as_str() {
                    "snowflake" => candidates.push(format!("snowflake__{macro_name}")),
                    "duckdb" => {
                        candidates.push(format!("duckdb__{macro_name}"));
                        candidates.push(format!("postgres__{macro_name}"));
                    }
                    "bigquery" => candidates.push(format!("bigquery__{macro_name}")),
                    "redshift" => {
                        candidates.push(format!("redshift__{macro_name}"));
                        candidates.push(format!("postgres__{macro_name}"));
                    }
                    "spark" | "databricks" => candidates.push(format!("spark__{macro_name}")),
                    "postgres" => candidates.push(format!("postgres__{macro_name}")),
                    _ => {}
                }
                candidates.push(format!("default__{macro_name}"));
                Ok(Value::from_object(DispatchResult { candidates }))
            }
            "set_query_tag" | "set_query_comment" => {
                Ok(Value::from(""))
            }
            "quote" => {
                let val = args.first().map(|v| v.to_string()).unwrap_or_default();
                // Snowflake normalizes unquoted identifiers to uppercase, so
                // quoting a lowercase name must also uppercase it to match.
                let val = if self.target_type == "snowflake" { val.to_uppercase() } else { val };
                Ok(Value::from(format!("\"{val}\"")))
            }
            "rename_relation" | "drop_relation" | "create_schema" | "drop_schema" => {
                Ok(Value::from(""))
            }
            _ => {
                Ok(Value::UNDEFINED)
            }
        }
    }
}

/// Result of adapter.dispatch() — a callable that tries adapter-specific macros first.
#[derive(Debug)]
struct DispatchResult {
    candidates: Vec<String>,
}

impl fmt::Display for DispatchResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "<dispatch:{}>", self.candidates.first().map(|s| s.as_str()).unwrap_or("?"))
    }
}

impl minijinja::value::Object for DispatchResult {
    fn call(self: &Arc<Self>, state: &minijinja::State, args: &[Value]) -> Result<Value, JinjaError> {
        for candidate in &self.candidates {
            match state.call_macro(candidate, args) {
                Ok(result) => return Ok(Value::from(result)),
                Err(_) => continue,
            }
        }
        Ok(Value::from(""))
    }
}

fn parse_ref_args(args: &[Value]) -> Result<(String, Option<String>), JinjaError> {
    match args.len() {
        1 => Ok((args[0].to_string(), None)),
        2 => {
            let first = args[0].to_string();
            let second = args[1].to_string();
            if second.parse::<i32>().is_ok() {
                Ok((first, None))
            } else {
                Ok((second, Some(first)))
            }
        }
        _ => Err(JinjaError::new(
            ErrorKind::MissingArgument,
            "ref() requires 1 or 2 arguments",
        )),
    }
}

/// Extract the dispatched macro name from an adapter.dispatch() call.
/// e.g., `{{ return(adapter.dispatch('cents_to_dollars')(column_name)) }}` -> Some("cents_to_dollars")
fn extract_dispatch_name(body: &str) -> Option<String> {
    let dispatch_pos = body.find("adapter.dispatch(")?;
    let after_dispatch = &body[dispatch_pos + "adapter.dispatch(".len()..];
    // Find the quote-delimited name: 'name' or "name"
    let quote = after_dispatch.chars().next()?;
    if quote != '\'' && quote != '"' {
        return None;
    }
    let name_start = 1;
    let name_end = after_dispatch[name_start..].find(quote)?;
    Some(after_dispatch[name_start..name_start + name_end].to_string())
}

/// Convert a serde_yaml::Value to a minijinja::Value, preserving types.
fn yaml_to_minijinja(val: &serde_yaml::Value) -> Value {
    match val {
        serde_yaml::Value::String(s) => Value::from(s.as_str()),
        serde_yaml::Value::Bool(b) => Value::from(*b),
        serde_yaml::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                Value::from(i)
            } else if let Some(f) = n.as_f64() {
                Value::from(f)
            } else {
                Value::from(n.to_string())
            }
        }
        serde_yaml::Value::Sequence(seq) => {
            let items: Vec<Value> = seq.iter().map(yaml_to_minijinja).collect();
            Value::from(items)
        }
        serde_yaml::Value::Mapping(map) => {
            let mut m = std::collections::BTreeMap::new();
            for (k, v) in map {
                let key = match k {
                    serde_yaml::Value::String(s) => s.clone(),
                    other => serde_yaml::to_string(other).unwrap_or_default().trim().to_string(),
                };
                m.insert(key, yaml_to_minijinja(v));
            }
            Value::from(m)
        }
        serde_yaml::Value::Null => Value::from(()),
        _ => Value::UNDEFINED,
    }
}

/// Strip {{ config(...) }} blocks from SQL.
/// These blocks often contain complex Python expressions (ternary operators,
/// dict literals, list comprehensions) that minijinja cannot parse.
/// Since config() returns "" and values are captured separately, this is safe.
fn strip_config_blocks(sql: &str) -> String {
    let mut result = sql.to_string();
    loop {
        // Find `{{` then skip optional `-` and whitespace to check for `config(`
        let start = {
            let mut found = None;
            let mut search = 0;
            while let Some(pos) = result[search..].find("{{") {
                let abs = search + pos;
                let mut j = abs + 2;
                let bytes = result.as_bytes();
                // Skip optional `-`
                if j < bytes.len() && bytes[j] == b'-' {
                    j += 1;
                }
                // Skip whitespace/newlines
                while j < bytes.len() && matches!(bytes[j], b' ' | b'\t' | b'\n' | b'\r') {
                    j += 1;
                }
                // Check for `config(`
                if result[j..].starts_with("config(") {
                    found = Some(abs);
                    break;
                }
                search = abs + 2;
            }
            found
        };
        let Some(start) = start else { break };

        // Find matching }} by tracking parenthesis depth
        let search_start = start + 2; // skip {{
        let mut paren_depth: i32 = 0;
        let rest = &result[search_start..];
        let mut found_end = None;
        let mut in_string: Option<char> = None;
        let mut char_iter = rest.char_indices().peekable();

        while let Some((_byte_off, ch)) = char_iter.next() {
            if let Some(quote) = in_string {
                if ch == '\\' {
                    char_iter.next(); // skip escaped char
                } else if ch == quote {
                    in_string = None;
                }
            } else {
                match ch {
                    '\'' | '"' => in_string = Some(ch),
                    '(' => paren_depth += 1,
                    ')' => {
                        paren_depth = paren_depth.saturating_sub(1);
                    }
                    '}' if paren_depth <= 0 => {
                        if let Some(&(next_off, next_ch)) = char_iter.peek() {
                            if next_ch == '}' {
                                found_end = Some(search_start + next_off + next_ch.len_utf8());
                                break;
                            }
                        }
                    }
                    _ => {}
                }
            }
        }

        if let Some(end) = found_end {
            // Also consume trailing whitespace/newline
            let mut actual_end = end;
            let remaining = &result[end..];
            if remaining.starts_with('\n') {
                actual_end += 1;
            } else if remaining.starts_with("\r\n") {
                actual_end += 2;
            }
            result.replace_range(start..actual_end, "");
        } else {
            break;
        }
    }
    result
}

/// Strip {% do ... %} statements from SQL (not supported by minijinja).
/// Strip list concatenation with `+` operator that minijinja doesn't support.
/// Wrap list-literal assignments with `_mklist()` when `.append(` is used later.
///
/// Detects `{% set VAR = [...] %}` and rewrites to `{% set VAR = _mklist([...]) %}`
/// for any VAR that is later used with `.append(`. This enables true list mutation
/// via jinja2's MutableList object.
fn rewrite_list_append(sql: &str) -> String {
    // First, collect variable names that use .append(
    let mut appended_vars = std::collections::HashSet::new();
    let mut pos = 0;
    while let Some(idx) = sql[pos..].find(".append(") {
        let abs = pos + idx;
        // Walk backwards to find the variable name
        let prefix = &sql[..abs];
        let var_end = prefix.len();
        let var_start = prefix.rfind(|c: char| !c.is_ascii_alphanumeric() && c != '_')
            .map(|i| i + 1)
            .unwrap_or(0);
        if var_start < var_end {
            appended_vars.insert(sql[var_start..var_end].to_string());
        }
        pos = abs + 8;
    }
    if appended_vars.is_empty() {
        return sql.to_string();
    }

    // Now rewrite `{% set VAR = [...]` to `{% set VAR = _mklist([...]`
    // for any VAR in appended_vars
    let mut result = sql.to_string();
    for var in &appended_vars {
        // Match patterns like {% set VAR = [ or {%- set VAR = [
        let patterns = [
            format!("{{% set {} = [", var),
            format!("{{%- set {} = [", var),
            format!("{{% set {} =[", var),
            format!("{{%- set {} =[", var),
        ];
        for pat in &patterns {
            if let Some(idx) = result.find(pat.as_str()) {
                // Find the `= [` part and insert _mklist(
                let eq_pos = result[idx..].find('=').unwrap() + idx;
                let bracket_pos = result[eq_pos..].find('[').unwrap() + eq_pos;
                // Find matching ]
                let mut depth = 1;
                let mut j = bracket_pos + 1;
                let mut in_str: Option<char> = None;
                let bytes = result.as_bytes();
                while j < result.len() && depth > 0 {
                    if let Some(q) = in_str {
                        if bytes[j] == b'\\' { j += 1; }
                        else if bytes[j] == q as u8 { in_str = None; }
                    } else {
                        match bytes[j] {
                            b'\'' | b'"' => in_str = Some(bytes[j] as char),
                            b'[' => depth += 1,
                            b']' => depth -= 1,
                            _ => {}
                        }
                    }
                    j += 1;
                }
                if depth == 0 {
                    // j now points past the closing ]
                    // Insert _mklist( before [ and ) after ]
                    result.insert_str(j, ")");
                    result.insert_str(bracket_pos, "_mklist(");
                    break; // Only process first occurrence per var
                }
            }
        }
    }
    result
}

/// Detect dict variables that use `.update()`, `.pop()`, `.setdefault()`, or `.clear()`
/// and rewrite their `{% set VAR = {...} %}` initialization to `{% set VAR = _mkdict({...}) %}`
/// so mutations actually take effect via MutableDict.
fn rewrite_dict_mutation(sql: &str) -> String {
    // Collect variable names that use dict mutation methods
    let mut mutated_vars = std::collections::HashSet::new();
    for pattern in [".update(", ".pop(", ".setdefault(", ".clear("] {
        let mut pos = 0;
        while let Some(idx) = sql[pos..].find(pattern) {
            let abs = pos + idx;
            let prefix = &sql[..abs];
            let var_end = prefix.len();
            let var_start = prefix.rfind(|c: char| !c.is_ascii_alphanumeric() && c != '_')
                .map(|i| i + 1)
                .unwrap_or(0);
            if var_start < var_end {
                let var_name = &sql[var_start..var_end];
                // Only add if it looks like a variable name (not a method chain)
                if !var_name.is_empty() && var_name.chars().next().unwrap().is_ascii_alphabetic() {
                    mutated_vars.insert(var_name.to_string());
                }
            }
            pos = abs + pattern.len();
        }
    }
    if mutated_vars.is_empty() {
        return sql.to_string();
    }

    let mut result = sql.to_string();
    for var in &mutated_vars {
        // Match patterns like {% set VAR = { or {%- set VAR={ with flexible spacing
        let set_patterns = [
            format!("{{% set {}", var),
            format!("{{%- set {}", var),
            format!("{{%-set {}", var),
        ];
        let mut matched = false;
        for pat in &set_patterns {
            if matched { break; }
            if let Some(idx) = result.find(pat.as_str()) {
                // Find the `=` after the set VAR
                let after_var = idx + pat.len();
                let eq_pos = match result[after_var..].find('=') {
                    Some(p) => after_var + p,
                    None => continue,
                };
                // Find the `{` after `=`
                let brace_pos = match result[eq_pos + 1..].find('{') {
                    Some(p) => eq_pos + 1 + p,
                    None => continue,
                };
                // Make sure this is a dict literal, not a Jinja tag
                if brace_pos + 1 < result.len() {
                    let next = result.as_bytes()[brace_pos + 1];
                    if next == b'%' || next == b'{' || next == b'#' {
                        continue; // Jinja delimiter, not dict
                    }
                }
                // Find matching } accounting for nesting and strings
                let mut depth = 1;
                let mut j = brace_pos + 1;
                let mut in_str: Option<char> = None;
                let bytes = result.as_bytes();
                while j < result.len() && depth > 0 {
                    if let Some(q) = in_str {
                        if bytes[j] == b'\\' { j += 1; }
                        else if bytes[j] == q as u8 { in_str = None; }
                    } else {
                        match bytes[j] {
                            b'\'' | b'"' => in_str = Some(bytes[j] as char),
                            b'{' => depth += 1,
                            b'}' => depth -= 1,
                            _ => {}
                        }
                    }
                    j += 1;
                }
                if depth == 0 {
                    // j now points past the closing }
                    result.insert_str(j, ")");
                    result.insert_str(brace_pos, "_mkdict(");
                    matched = true;
                    break; // Only process first occurrence per var
                }
            }
        }
    }
    result
}

/// Removes the ` + EXPR` part where EXPR is a list literal or function call.
#[allow(dead_code)]
fn strip_list_concat(sql: &str) -> String {
    let mut result = sql.to_string();
    // Repeatedly find and remove ` + [...]` or ` + func(...)` patterns in Jinja contexts
    let mut last_pos = 0;
    loop {
        if let Some(rel_pos) = result[last_pos..].find(" + ") {
            let pos = last_pos + rel_pos;
            if !is_inside_jinja(&result, pos) {
                last_pos = pos + 3;
                continue;
            }
            let after = &result[pos + 3..]; // after " + "
            let first_char = after.chars().next().unwrap_or(' ');
            if first_char == '[' {
                // ` + [...]` — find matching ]
                let mut depth = 1;
                let mut end = 0;
                let mut in_str: Option<char> = None;
                for (i, ch) in after[1..].char_indices() {
                    if let Some(q) = in_str {
                        if ch == q { in_str = None; }
                    } else {
                        match ch {
                            '\'' | '"' => in_str = Some(ch),
                            '[' => depth += 1,
                            ']' => {
                                depth -= 1;
                                if depth == 0 { end = pos + 3 + 1 + i + 1; break; }
                            }
                            _ => {}
                        }
                    }
                }
                if end > 0 {
                    result.replace_range(pos..end, "");
                    continue;
                }
            } else if first_char.is_ascii_alphabetic() || first_char == '_' {
                let mut j = 0;
                let after_bytes = after.as_bytes();
                // Skip identifier
                while j < after_bytes.len() && (after_bytes[j].is_ascii_alphanumeric() || after_bytes[j] == b'_' || after_bytes[j] == b'.') {
                    j += 1;
                }
                if j < after_bytes.len() && after_bytes[j] == b'(' {
                    // ` + func(...)` — only strip in list concat context (left side ends with ] or is a known list pattern)
                    let before_trimmed = result[..pos].trim_end();
                    if before_trimmed.ends_with(']') {
                        let mut depth = 1;
                        j += 1;
                        while j < after_bytes.len() && depth > 0 {
                            match after_bytes[j] {
                                b'(' => depth += 1,
                                b')' => depth -= 1,
                                _ => {}
                            }
                            j += 1;
                        }
                        if depth == 0 {
                            let end = pos + 3 + j;
                            result.replace_range(pos..end, "");
                            continue;
                        }
                    }
                } else {
                    // ` + bare_variable` — strip if preceded by ] (list concat context)
                    let before_trimmed = result[..pos].trim_end();
                    if before_trimmed.ends_with(']') {
                        let end = pos + 3 + j;
                        result.replace_range(pos..end, "");
                        continue;
                    }
                }
            }
            last_pos = pos + 3;
        } else {
            break;
        }
    }
    result
}

/// Check if a column name is a SQL reserved keyword that needs quoting.
fn is_sql_reserved_keyword(name: &str) -> bool {
    matches!(
        name.to_uppercase().as_str(),
        "ORDER" | "SELECT" | "FROM" | "WHERE" | "GROUP" | "HAVING" | "LIMIT"
            | "OFFSET" | "INSERT" | "UPDATE" | "DELETE" | "CREATE" | "DROP"
            | "ALTER" | "TABLE" | "INDEX" | "VIEW" | "JOIN" | "LEFT" | "RIGHT"
            | "INNER" | "OUTER" | "CROSS" | "ON" | "AND" | "OR" | "NOT" | "IN"
            | "IS" | "NULL" | "TRUE" | "FALSE" | "AS" | "CASE" | "WHEN" | "THEN"
            | "ELSE" | "END" | "BETWEEN" | "LIKE" | "EXISTS" | "ALL" | "ANY"
            | "UNION" | "EXCEPT" | "INTERSECT" | "INTO" | "VALUES" | "SET"
            | "DEFAULT" | "PRIMARY" | "KEY" | "FOREIGN" | "REFERENCES" | "CHECK"
            | "UNIQUE" | "CONSTRAINT" | "DISTINCT" | "ASC" | "DESC" | "BY"
            | "WITH" | "RECURSIVE" | "OVER" | "PARTITION" | "WINDOW" | "ROWS"
            | "RANGE" | "RANK" | "ROW" | "FETCH" | "NEXT" | "ONLY" | "PERCENT"
            | "ROLLUP" | "CUBE" | "GROUPING" | "FILTER" | "CURRENT" | "DATE"
            | "TIME" | "TIMESTAMP" | "INTERVAL" | "YEAR" | "MONTH" | "DAY"
            | "HOUR" | "MINUTE" | "SECOND" | "ZONE" | "BOTH" | "LEADING"
            | "TRAILING" | "FOR" | "SOME" | "TO" | "USER" | "GRANT" | "REVOKE"
            | "COLUMN" | "TYPE" | "FULL" | "NATURAL" | "USING" | "DO" | "IF"
            | "BEGIN" | "COMMIT" | "ROLLBACK" | "START" | "TRANSACTION"
    )
}

/// Fix unary negation of function calls: minijinja can't handle `-func(...)`.
/// Replace `=-func(` with `=0-func(` which uses subtraction instead of negation.
/// Check whether position `pos` in `sql` is inside a Jinja expression or block
/// (i.e. between an unclosed `{{`/`{%` and its matching `}}`/`%}`).
fn is_inside_jinja(sql: &str, pos: usize) -> bool {
    let before = &sql[..pos];
    let last_expr_open = before.rfind("{{");
    let last_expr_close = before.rfind("}}");
    let in_expr = match (last_expr_open, last_expr_close) {
        (Some(o), Some(c)) => o > c,
        (Some(_), None) => true,
        _ => false,
    };
    if in_expr {
        return true;
    }
    let last_block_open = before.rfind("{%");
    let last_block_close = before.rfind("%}");
    match (last_block_open, last_block_close) {
        (Some(o), Some(c)) => o > c,
        (Some(_), None) => true,
        _ => false,
    }
}

fn fix_unary_negation(sql: &str) -> String {
    let chars: Vec<char> = sql.chars().collect();
    let len = chars.len();
    let mut i = 0;
    let mut out = String::with_capacity(sql.len() + 32);
    while i < len {
        if chars[i] == '=' && i + 1 < len {
            // Skip past any whitespace after =
            let mut j = i + 1;
            while j < len && chars[j] == ' ' {
                j += 1;
            }
            // Check for - followed by identifier char (function call)
            if j < len && chars[j] == '-' && j + 1 < len
                && (chars[j + 1].is_ascii_alphabetic() || chars[j + 1] == '_')
            {
                // Make sure this '=' is not part of ==, !=, >=, <=
                let prev = if i > 0 { chars[i - 1] } else { ' ' };
                if prev != '!' && prev != '>' && prev != '<' && prev != '=' {
                    out.push('=');
                    for k in (i + 1)..j {
                        out.push(chars[k]);
                    }
                    out.push('0');
                    i = j; // now points at `-`
                    continue;
                }
            }
        }
        out.push(chars[i]);
        i += 1;
    }
    out
}

/// Strip Jinja expression blocks (`{{ ... }}`) from a single line,
/// replacing them with empty strings. Used to recover from macro call errors
/// (unknown kwargs, too many args) by removing the problematic expressions.
fn strip_jinja_expressions(line: &str) -> String {
    let mut result = String::new();
    let chars: Vec<char> = line.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        if i + 1 < chars.len() && chars[i] == '{' && chars[i + 1] == '{' {
            // Find matching }}
            let mut depth = 1;
            let mut j = i + 2;
            while j + 1 < chars.len() && depth > 0 {
                if chars[j] == '{' && chars[j + 1] == '{' {
                    depth += 1;
                    j += 1;
                } else if chars[j] == '}' && chars[j + 1] == '}' {
                    depth -= 1;
                    j += 1;
                }
                j += 1;
            }
            // Skip this expression entirely
            i = j;
        } else {
            result.push(chars[i]);
            i += 1;
        }
    }
    result
}

/// Strip Jinja comments `{# ... #}` that may contain syntax confusing to minijinja.
fn strip_jinja_comments(sql: &str) -> String {
    let mut result = sql.to_string();
    loop {
        if let Some(start) = result.find("{#") {
            if let Some(end_offset) = result[start + 2..].find("#}") {
                let end = start + 2 + end_offset + 2;
                result.replace_range(start..end, "");
                continue;
            }
        }
        break;
    }
    result
}

/// Replace `{% set a, b, c = expr %}` (multi-assignment / tuple unpacking)
/// with individual `{% set a = none %}\n{% set b = none %}\n{% set c = none %}`.
/// Minijinja macros always return strings, so tuple unpacking from macro calls never works.
fn strip_multi_set(sql: &str) -> String {
    let mut result = sql.to_string();
    let mut search_from = 0;
    loop {
        // Find {% set or {%- set
        let set_start = result[search_from..].find("{% set ")
            .or_else(|| result[search_from..].find("{%- set "))
            .or_else(|| result[search_from..].find("{%-set "))
            .map(|p| search_from + p);
        let Some(start) = set_start else { break };

        // Find the closing %} for this set tag FIRST
        let Some(close_offset) = result[start..].find("%}") else { break };
        let tag_end = start + close_offset + 2;
        let tag_content = &result[start..tag_end];

        // Find = within this tag only
        let after_set_offset = tag_content.find("set ").unwrap() + 4;
        let tag_rest = &tag_content[after_set_offset..];
        let Some(eq_pos) = tag_rest.find('=') else {
            search_from = tag_end;
            continue;
        };

        let vars_str = tag_rest[..eq_pos].trim();

        // Check if this is a multi-assignment (contains comma in variable names)
        if !vars_str.contains(',') {
            search_from = tag_end;
            continue;
        }

        // Parse variable names
        let vars: Vec<&str> = vars_str.split(',').map(|s| s.trim()).collect();

        let mut end = tag_end;
        if end < result.len() && result.as_bytes()[end] == b'\n' {
            end += 1;
        }

        let replacement: String = vars.iter()
            .map(|v| format!("{{% set {} = none %}}", v))
            .collect::<Vec<_>>()
            .join("\n");
        result.replace_range(start..end, &replacement);
        // Don't update search_from — re-search from same position after replacement
    }
    result
}

/// Rewrite `{% do expr %}` → `{% set _do_N = expr %}` so minijinja evaluates the
/// expression (including mutations like dict.update()) instead of silently stripping it.
/// Wrap macro calls in `{% set VAR = func(...) %}` with `_get_return()` so that
/// dbt macros using `{{ return(val) }}` have their structured return values recovered.
/// Without this, macro calls in set-expressions return the text output (empty string)
/// instead of the value passed to `return()`.
fn wrap_set_macro_calls(sql: &str) -> String {
    // Known built-in functions that don't use return() — skip wrapping these
    const BUILTINS: &[&str] = &[
        "var", "ref", "source", "env_var", "config", "range", "dict", "zip",
        "_mklist", "_mkdict", "_get_return", "log", "print", "tojson", "fromjson",
        "set", "namespace", "caller", "loop", "cycler", "joiner",
        "load_result", "graph", "adapter", "target", "project_name", "modules",
        "exceptions", "context", "execute", "flags", "invocation_id",
        "run_started_at", "model", "this", "builtins",
    ];

    let mut result = sql.to_string();
    let mut search_from = 0;

    loop {
        // Find {% set or {%- set
        let set_tag = result[search_from..].find("{% set ")
            .or_else(|| result[search_from..].find("{%- set "))
            .or_else(|| result[search_from..].find("{%-set "))
            .map(|p| search_from + p);
        let Some(tag_start) = set_tag else { break };

        // Find the = sign
        let rest_after_set = &result[tag_start..];
        let eq_rel = match rest_after_set.find('=') {
            Some(p) => p,
            None => { search_from = tag_start + 6; continue; }
        };

        // Check if this is a multi-assignment (a, b = expr) — skip
        let between = &rest_after_set[..eq_rel];
        if between.contains(',') {
            search_from = tag_start + eq_rel + 1;
            continue;
        }

        let eq_abs = tag_start + eq_rel;

        // Find closing %} or -%} for this tag, accounting for strings
        let after_eq = &result[eq_abs + 1..];
        let mut in_str: Option<char> = None;
        let mut close_pos = None;
        let bytes = after_eq.as_bytes();
        let mut j = 0;
        while j < bytes.len().saturating_sub(1) {
            if let Some(q) = in_str {
                if bytes[j] == b'\\' { j += 2; continue; }
                if bytes[j] == q as u8 { in_str = None; }
            } else {
                match bytes[j] {
                    b'\'' | b'"' => in_str = Some(bytes[j] as char),
                    b'-' if j + 2 < bytes.len() && bytes[j + 1] == b'%' && bytes[j + 2] == b'}' => {
                        close_pos = Some(j);
                        break;
                    }
                    b'%' if j + 1 < bytes.len() && bytes[j + 1] == b'}' => {
                        close_pos = Some(j);
                        break;
                    }
                    _ => {}
                }
            }
            j += 1;
        }
        let Some(expr_end_offset) = close_pos else {
            search_from = eq_abs + 1;
            continue;
        };

        // Extract the expression (between = and %}/-%})
        let expr = after_eq[..expr_end_offset].trim();
        if expr.is_empty() {
            search_from = eq_abs + 1 + expr_end_offset + 2;
            continue;
        }

        // Check if expression starts with an identifier followed by (
        let first_char = expr.chars().next().unwrap_or(' ');
        if !first_char.is_ascii_alphabetic() && first_char != '_' {
            search_from = eq_abs + 1 + expr_end_offset + 2;
            continue;
        }
        let ident_end = expr.find(|c: char| !c.is_ascii_alphanumeric() && c != '_').unwrap_or(expr.len());
        let ident = &expr[..ident_end];
        let after_ident = expr[ident_end..].trim_start();

        if !after_ident.starts_with('(') {
            search_from = eq_abs + 1 + expr_end_offset + 2;
            continue;
        }

        // Skip known builtins
        if BUILTINS.contains(&ident) {
            search_from = eq_abs + 1 + expr_end_offset + 2;
            continue;
        }

        // Wrap the expression with _get_return()
        let wrapped = format!("_get_return({})", expr);
        let replace_start = eq_abs + 1 + (after_eq.len() - after_eq.trim_start().len());
        let replace_end = eq_abs + 1 + expr_end_offset;
        // Trim trailing whitespace from the expression region
        let actual_end = {
            let region = &result[replace_start..replace_end];
            replace_start + region.trim_end().len()
        };
        result.replace_range(replace_start..actual_end, &wrapped);
        search_from = replace_start + wrapped.len() + 2;
    }

    result
}

fn rewrite_do_statements(sql: &str) -> String {
    let mut result = sql.to_string();
    let mut counter = 0u32;
    loop {
        let found = result.find("{% do ")
            .or_else(|| result.find("{%- do "))
            .or_else(|| result.find("{%-do "));
        if let Some(start) = found {
            // Find the `do ` keyword position to extract the expression
            let do_keyword_end = if result[start..].starts_with("{%- do ") || result[start..].starts_with("{%-do ") {
                let offset = if result[start..].starts_with("{%-do ") {
                    start + 6 // "{%-do "
                } else {
                    start + 7 // "{%- do "
                };
                offset
            } else {
                start + 6 // "{% do "
            };
            // Find closing %} or -%} while respecting string literals
            let rest = &result[start..];
            let mut in_string: Option<char> = None;
            let mut close_pos = None;
            let mut has_trim_close = false;
            let bytes = rest.as_bytes();
            let mut j = 0;
            while j < bytes.len().saturating_sub(1) {
                if let Some(quote) = in_string {
                    if bytes[j] == b'\\' {
                        j += 1; // skip escaped char
                    } else if bytes[j] == quote as u8 {
                        in_string = None;
                    }
                } else {
                    match bytes[j] {
                        b'\'' | b'"' => in_string = Some(bytes[j] as char),
                        b'-' if j + 2 < bytes.len() && bytes[j + 1] == b'%' && bytes[j + 2] == b'}' => {
                            has_trim_close = true;
                            close_pos = Some(j);
                            break;
                        }
                        b'%' if bytes[j + 1] == b'}' => {
                            close_pos = Some(j);
                            break;
                        }
                        _ => {}
                    }
                }
                j += 1;
            }
            if let Some(expr_end_offset) = close_pos {
                let expr = result[do_keyword_end..start + expr_end_offset].trim();
                let trim_open = result[start..].starts_with("{%-");
                let open = if trim_open { "{%-" } else { "{%" };
                let close = if has_trim_close { "-%}" } else { "%}" };
                let replacement = format!("{} set _do_{} = {} {}", open, counter, expr, close);
                let full_end = if has_trim_close {
                    start + expr_end_offset + 3 // -% }
                } else {
                    start + expr_end_offset + 2 // %}
                };
                result.replace_range(start..full_end, &replacement);
                counter += 1;
                continue;
            }
        }
        break;
    }
    result
}

/// Strip ternary expressions (`val if cond else alt`) within Jinja expression
/// blocks that minijinja cannot parse in function call keyword arguments.
/// Replaces `=VALUE if COND else ALT` with `=VALUE`.
fn strip_ternary_in_kwargs(sql: &str) -> String {
    strip_ternary_in_kwargs_inner(sql, false)
}

fn strip_ternary_in_kwargs_inner(sql: &str, is_macro_body: bool) -> String {
    let mut result = sql.to_string();
    // Repeatedly find and replace ternary patterns
    // Pattern: ='string' if ... else 'string'  OR  ="string" if ... else "string"
    loop {
        let mut found = false;
        // Search for ` if ` that appears after a value in kwarg context
        if let Some(if_pos) = find_kwarg_ternary_inner(&result, is_macro_body) {
            if let Some(else_end) = find_else_end(&result, if_pos) {
                // Remove from if_pos to else_end
                result.replace_range(if_pos..else_end, "");
                found = true;
            }
        }
        if !found {
            break;
        }
    }
    result
}

/// Find position of ` if ` that is part of a ternary expression in a kwarg context.
/// Returns the start of ` if ` (including leading space).
fn find_kwarg_ternary(sql: &str) -> Option<usize> {
    find_kwarg_ternary_inner(sql, false)
}

fn find_kwarg_ternary_inner(sql: &str, is_macro_body: bool) -> Option<usize> {
    let bytes = sql.as_bytes();
    let len = bytes.len();
    let mut i = 0;
    while i + 4 < len {
        // Look for " if " or ")if " patterns
        if (bytes[i] == b' ' || bytes[i] == b')') && &bytes[i + 1..i + 4] == b"if " {
            if is_macro_body || is_inside_jinja(sql, i) {
                // Verify there's a kwarg context: go backwards past value to find =
                let trimmed = sql[..i].trim_end();
                let has_kwarg = {
                    // Skip backwards over a chained expression:
                    // e.g. source(a, b).database, func(), 'string', identifier
                    let tb = trimmed.as_bytes();
                    let mut j = tb.len();
                    let mut moved = true;
                    while moved && j > 0 {
                        moved = false;
                        let c = tb[j - 1];
                        if c == b'\'' || c == b'"' {
                            let quote = c;
                            j -= 1;
                            while j > 0 && tb[j - 1] != quote { j -= 1; }
                            if j > 0 { j -= 1; }
                            moved = true;
                        } else if c == b')' {
                            let mut depth = 1;
                            j -= 1;
                            while j > 0 && depth > 0 {
                                j -= 1;
                                if tb[j] == b')' { depth += 1; }
                                else if tb[j] == b'(' { depth -= 1; }
                            }
                            moved = true;
                        } else if c == b']' {
                            let mut depth = 1;
                            j -= 1;
                            while j > 0 && depth > 0 {
                                j -= 1;
                                if tb[j] == b']' { depth += 1; }
                                else if tb[j] == b'[' { depth -= 1; }
                            }
                            moved = true;
                        } else if c.is_ascii_alphanumeric() || c == b'_' {
                            while j > 0 && (tb[j-1].is_ascii_alphanumeric() || tb[j-1] == b'_') {
                                j -= 1;
                            }
                            moved = true;
                        }
                        // Consume dot or pipe to continue chaining
                        if moved && j > 0 && (tb[j - 1] == b'.' || tb[j - 1] == b'|') {
                            j -= 1;
                            moved = true;
                        }
                    }
                    // Check for = before the value
                    let before_val = trimmed[..j].trim_end();
                    if !before_val.ends_with('=') {
                        false
                    } else {
                        // Exclude `{% set var = val if ... %}` — not a kwarg context
                        let before_eq = before_val[..before_val.len()-1].trim_end();
                        let mut vj = before_eq.len();
                        while vj > 0 && (before_eq.as_bytes()[vj-1].is_ascii_alphanumeric() || before_eq.as_bytes()[vj-1] == b'_') {
                            vj -= 1;
                        }
                        let keyword = before_eq[..vj].trim_end();
                        !(keyword.ends_with("set") || keyword.ends_with("set-"))
                    }
                };
                if has_kwarg {
                    return Some(i);
                }
            }
        }
        i += 1;
    }
    None
}

/// Find the end of the `else VALUE` part of a ternary expression.
fn find_else_end(sql: &str, if_start: usize) -> Option<usize> {
    let rest = &sql[if_start..];
    // Find ` else `
    if let Some(else_pos) = rest.find(" else ") {
        let after_else = if_start + else_pos + 6; // skip " else "
        let bytes = sql.as_bytes();
        let mut j = after_else;
        // Skip past the else value
        if j < bytes.len() && (bytes[j] == b'\'' || bytes[j] == b'"') {
            // String literal
            let quote = bytes[j];
            j += 1;
            while j < bytes.len() && bytes[j] != quote {
                j += 1;
            }
            if j < bytes.len() {
                j += 1; // skip closing quote
            }
        } else if j < bytes.len() && bytes[j] == b'[' {
            // List literal
            let mut depth = 1;
            j += 1;
            while j < bytes.len() && depth > 0 {
                if bytes[j] == b'[' {
                    depth += 1;
                } else if bytes[j] == b']' {
                    depth -= 1;
                }
                j += 1;
            }
        } else {
            // Identifier or function call
            while j < bytes.len() && (bytes[j].is_ascii_alphanumeric() || bytes[j] == b'_' || bytes[j] == b'.') {
                j += 1;
            }
            if j < bytes.len() && bytes[j] == b'(' {
                let mut depth = 1;
                j += 1;
                while j < bytes.len() && depth > 0 {
                    if bytes[j] == b'(' {
                        depth += 1;
                    } else if bytes[j] == b')' {
                        depth -= 1;
                    }
                    j += 1;
                }
            }
        }
        return Some(j);
    }
    None
}

/// Pre-process Jinja source to replace Python-style dict literals
/// that minijinja doesn't support.
/// Handles: {'key': 'val'}, {"key": "val"}, and multiline dicts like
/// {\n  "key": "val"\n}
fn preprocess_dicts(sql: &str) -> String {
    preprocess_dicts_inner(sql, false)
}

/// If `is_macro_body` is true, skips the expensive `is_inside_jinja` check
/// since all content in a macro body is considered inside Jinja context.
fn preprocess_dicts_inner(sql: &str, is_macro_body: bool) -> String {
    let mut result = String::with_capacity(sql.len());
    let chars: Vec<char> = sql.chars().collect();
    let len = chars.len();
    let mut i = 0;
    // Track whether we're inside a Jinja tag: 0=raw, 1={{ }}, 2={% %}
    let mut jinja_ctx: u8 = 0;

    while i < len {
        // Detect Jinja delimiters to track context
        if i + 1 < len {
            match (chars[i], chars[i + 1]) {
                ('{', '{') => { jinja_ctx = 1; }
                ('{', '%') => { jinja_ctx = 2; }
                ('}', '}') if jinja_ctx == 1 => { jinja_ctx = 0; }
                ('%', '}') if jinja_ctx == 2 => { jinja_ctx = 0; }
                // Handle whitespace-trimming variants: -%} and -}}
                ('-', '%') if jinja_ctx == 2 && i + 2 < len && chars[i + 2] == '}' => { jinja_ctx = 0; }
                ('-', '}') if jinja_ctx == 1 && i + 2 < len && chars[i + 2] == '}' => { jinja_ctx = 0; }
                _ => {}
            }
        }

        // Look for { that could be a dict literal
        if chars[i] == '{' && i + 1 < len {
            let next = chars[i + 1];
            // Skip Jinja delimiters themselves
            if next == '{' || next == '%' || next == '#' || next == '-' {
                result.push(chars[i]);
                i += 1;
                continue;
            }
            // Preserve dicts inside Jinja tags — minijinja handles them natively
            if jinja_ctx != 0 {
                result.push(chars[i]);
                i += 1;
                continue;
            }
            // Outside Jinja tags: only process dicts that are between Jinja
            // blocks (e.g. inside {% if %}...{% endif %}) but not in raw SQL.
            // Skip this expensive check for macro bodies (all content is inside Jinja).
            if !is_macro_body {
                let byte_pos: usize = chars[..i].iter().map(|c| c.len_utf8()).sum();
                if !is_inside_jinja(sql, byte_pos) {
                    result.push(chars[i]);
                    i += 1;
                    continue;
                }
            }
            // Check if this looks like a Python dict literal
            let prev_char = if i > 0 { chars[i - 1] } else { ' ' };
            let dict_context = prev_char == '=' || prev_char == '(' || prev_char == '['
                || prev_char == ',' || prev_char == ':' || prev_char == ' '
                || prev_char == '\n' || prev_char == '\t';
            let mut peek = i + 1;
            while peek < len && (chars[peek] == ' ' || chars[peek] == '\n' || chars[peek] == '\r' || chars[peek] == '\t') {
                peek += 1;
            }
            let is_dict = dict_context && peek < len && (chars[peek] == '\'' || chars[peek] == '"');
            // Also match empty dict: {}
            let is_empty_dict = dict_context && peek < len && chars[peek] == '}';
            if is_dict || is_empty_dict {
                // Find matching } respecting nested braces and strings
                let mut depth = 1;
                let mut j = i + 1;
                let mut in_string: Option<char> = None;
                while j < len && depth > 0 {
                    let c = chars[j];
                    if let Some(quote) = in_string {
                        if c == '\\' {
                            j += 1; // skip escaped char
                        } else if c == quote {
                            in_string = None;
                        }
                    } else {
                        match c {
                            '\'' | '"' => in_string = Some(c),
                            '{' => depth += 1,
                            '}' => depth -= 1,
                            _ => {}
                        }
                    }
                    j += 1;
                }
                if depth == 0 {
                    // Successfully found matching } — replace dict with none
                    result.push_str("none");
                    i = j;
                    continue;
                }
                // No matching } found — not a dict, keep the { as-is
            }
        }
        result.push(chars[i]);
        i += 1;
    }

    result
}

/// Pre-process a macro body to handle unsupported Jinja patterns:
/// - Replace dict literals with `none`
/// - Remove {% do expr %} lines (convert to comments)
fn preprocess_macro_body(body: &str) -> String {
    let mut result = preprocess_dicts_inner(body, true);
    result = strip_ternary_in_kwargs_inner(&result, true);
    result = rewrite_list_append(&result);
    result = strip_list_concat(&result);
    result = rewrite_dict_mutation(&result);
    result = rewrite_do_statements(&result);
    result = wrap_set_macro_calls(&result);
    result
}

#[cfg(test)]
mod tests {
    use super::*;
    use minijinja::Environment;

    #[test]
    fn test_fix_unary_negation() {
        let mut env = Environment::new();
        env.add_template("ns", "{% macro ts_add(datepart, interval, tstamp) %}{{ tstamp }} + INTERVAL '{{ interval }}' {{ datepart }}{% endmacro %}").unwrap();
        env.add_function("var", |args: &[Value]| -> Result<Value, minijinja::Error> {
            args.get(1).cloned().ok_or_else(|| minijinja::Error::from(minijinja::ErrorKind::MissingArgument))
        });

        let raw = r#"{% import "ns" as ns %}{{ ns.ts_add(datepart="s", interval=-var("x", 5), tstamp="t") }}"#;
        let fixed = fix_unary_negation(raw);
        assert!(fixed.contains("interval=0-var("), "expected 0-var, got: {}", fixed);

        env.add_template("test", &fixed).unwrap();
        let result = env.get_template("test").unwrap().render(minijinja::context!{}).unwrap();
        assert!(result.contains("-5"), "expected -5 in output: {}", result);
    }

    #[test]
    fn test_fix_unary_negation_preserves_comparisons() {
        // Should NOT modify !=, >=, <=, ==
        let sql = "WHERE x != -val AND y >= -1 AND z <= -2 AND a == -b";
        let result = fix_unary_negation(sql);
        assert_eq!(result, sql);
    }

    #[test]
    fn test_strip_config_blocks_basic() {
        let sql = "{{ config(materialized='table') }}\nSELECT 1";
        let result = strip_config_blocks(sql);
        assert_eq!(result, "SELECT 1");
    }

    #[test]
    fn test_strip_config_blocks_with_dash() {
        let sql = "{{- config(materialized='view') -}}\nSELECT 1";
        let result = strip_config_blocks(sql);
        assert_eq!(result, "SELECT 1");
    }

    #[test]
    fn test_strip_config_blocks_multiline() {
        let sql = "{{\n  config(\n    materialized='table',\n    schema='analytics'\n  )\n}}\nSELECT 1";
        let result = strip_config_blocks(sql);
        assert_eq!(result, "SELECT 1");
    }

    #[test]
    fn test_rewrite_dict_mutation() {
        let sql = "{% set my_dict = {'a': 1} %}\n{% do my_dict.update({'b': 2}) %}";
        let result = rewrite_dict_mutation(sql);
        assert!(result.contains("_mkdict("), "expected _mkdict wrapper, got: {}", result);
    }

    #[test]
    fn test_rewrite_dict_mutation_no_spaces() {
        // ad-reporting style: {%- set final_fields_superset={} -%}
        let sql = "{%- set final_fields_superset={} -%}\n{%- do final_fields_superset.update({'a': 'b'}) -%}";
        let result = rewrite_dict_mutation(sql);
        assert!(result.contains("_mkdict({}"), "expected _mkdict wrapper, got: {}", result);
    }

    #[test]
    fn test_rewrite_dict_mutation_no_mutation() {
        let sql = "{% set my_dict = {'a': 1} %}\n{{ my_dict.a }}";
        let result = rewrite_dict_mutation(sql);
        assert!(!result.contains("_mkdict("), "should not rewrite without mutations: {}", result);
    }

    #[test]
    fn test_strip_config_blocks_nested_parens() {
        let sql = "{{ config(materialized='table', pre_hook=sql_header(is_incremental())) }}\nSELECT 1";
        let result = strip_config_blocks(sql);
        assert_eq!(result, "SELECT 1");
    }

    #[test]
    fn test_strip_jinja_comments() {
        let sql = "SELECT {# this is a comment #} 1 FROM {# another #} t";
        let result = strip_jinja_comments(sql);
        assert_eq!(result, "SELECT  1 FROM  t");
    }

    #[test]
    fn test_rewrite_do_statements() {
        let sql = "{% do some_list.append('x') %}\nSELECT 1\n{%- do log('msg') %}";
        let result = rewrite_do_statements(sql);
        assert!(result.contains("{% set _do_0 = some_list.append('x') %}"), "got: {}", result);
        assert!(result.contains("SELECT 1"));
        assert!(result.contains("{%- set _do_1 = log('msg') %}"), "got: {}", result);
    }

    #[test]
    fn test_strip_multi_set() {
        let sql = "{% set a, b, c = func() %}\nSELECT 1";
        let result = strip_multi_set(sql);
        assert!(result.contains("{% set a = none %}"));
        assert!(result.contains("{% set b = none %}"));
        assert!(result.contains("{% set c = none %}"));
        assert!(result.contains("SELECT 1"));
    }

    #[test]
    fn test_strip_multi_set_ignores_single() {
        let sql = "{% set x = 1 %}\nSELECT 1";
        let result = strip_multi_set(sql);
        assert_eq!(result, sql);
    }

    #[test]
    fn test_preprocess_dicts_inside_jinja() {
        let sql = "{{ func({'key': 'val'}) }}";
        let result = preprocess_dicts(sql);
        // Dicts inside {{ }} are preserved — minijinja handles them natively
        assert_eq!(result, sql);
    }

    #[test]
    fn test_preprocess_dicts_outside_jinja_unchanged() {
        let sql = "SELECT * FROM t WHERE col = {'not_a_dict'}";
        let result = preprocess_dicts(sql);
        // Outside Jinja context, should be left alone
        assert_eq!(result, sql);
    }

    #[test]
    fn test_preprocess_dicts_preserves_set_tag() {
        let sql = "{% set x = {'a': 1} %}";
        let result = preprocess_dicts(sql);
        // Inside {% set %} — should keep dict for minijinja
        assert_eq!(result, sql);
    }

    #[test]
    fn test_strip_list_concat() {
        let sql = "{% set x = mylist + ['a', 'b'] %}SELECT 1";
        let result = strip_list_concat(sql);
        assert!(result.contains("{% set x = mylist %}"));
    }

    #[test]
    fn test_strip_list_concat_outside_jinja() {
        let sql = "SELECT 1 + 2 FROM t";
        let result = strip_list_concat(sql);
        assert_eq!(result, sql);
    }

    #[test]
    fn test_strip_ternary_in_kwargs() {
        let sql = "{{ func(key='val' if cond else 'alt') }}";
        let result = strip_ternary_in_kwargs(sql);
        assert_eq!(result, "{{ func(key='val') }}");
    }

    #[test]
    fn test_strip_ternary_preserves_if_filter() {
        // `if` used as a filter (selectattr) should not be stripped
        let sql = "SELECT * FROM t WHERE x if y";
        let result = strip_ternary_in_kwargs(sql);
        assert_eq!(result, sql);
    }

    #[test]
    fn test_is_inside_jinja() {
        let sql = "SELECT {{ ref('model') }} FROM {{ source('s', 't') }}";
        // Inside first {{ }}
        assert!(is_inside_jinja(sql, 10));
        // Between the two {{ }} blocks (plain SQL)
        assert!(!is_inside_jinja(sql, 30));
    }

    #[test]
    fn test_is_inside_jinja_block() {
        let sql = "{% if true %}SELECT 1{% endif %}";
        assert!(is_inside_jinja(sql, 5));
        assert!(!is_inside_jinja(sql, 20));
    }

    #[test]
    fn test_extract_config_from_raw_basic() {
        let config_values = std::sync::Arc::new(std::sync::Mutex::new(std::collections::HashMap::new()));
        let sql = "{{ config(materialized='table', schema='analytics') }}\nSELECT 1";
        JinjaEngine::extract_config_from_raw(sql, &config_values);
        let cv = config_values.lock().unwrap();
        assert_eq!(cv.get("materialized"), Some(&"table".to_string()));
        assert_eq!(cv.get("schema"), Some(&"analytics".to_string()));
    }

    #[test]
    fn test_globals_in_imported_templates() {
        let mut env = Environment::new();
        add_jinja2_compat(&mut env);
        env.set_undefined_behavior(minijinja::UndefinedBehavior::Chainable);

        // Register templates FIRST (before globals) — matching actual engine order
        env.add_template_owned("myns".to_string(), r#"{% macro get_cols() %}{% set columns = [{"name": "test", "datatype": dbt.type_string()}] %}{% for c in columns %}{{ c.name }}:{{ c.datatype }}{% endfor %}{% endmacro %}"#.to_string()).unwrap();
        env.add_template_owned("model".to_string(), r#"{% import "myns" as myns %}RESULT={{ myns.get_cols() }}"#.to_string()).unwrap();

        // Add globals AFTER template registration
        env.add_global("dbt", Value::from_object(DbtNamespaceObject {}));

        let tmpl = env.get_template("model").unwrap();
        // Also pass dbt in render context (like the engine does)
        let result = tmpl.render(minijinja::context! {
            dbt => Value::from_object(DbtNamespaceObject {}),
        }).unwrap();
        assert!(result.contains("VARCHAR"), "Expected VARCHAR in result: {}", result);
    }

    #[test]
    fn test_engine_dbt_global_in_project_macros() {
        // Use the actual JinjaEngine to render a model that calls a project
        // macro which uses dbt.type_string() inside a {% set %} with dict literals.
        let mut engine = JinjaEngine::new();

        // Add a custom macro that mimics amazon-selling-partner's exact pattern
        engine.load_macros(&[(
            "get_type_test".to_string(),
            vec![],
            r#"
{% set columns = [
    {"name": "charge_kind", "datatype": dbt.type_string()},
    {"name": "currency_amount", "datatype": dbt.type_float()},
    {"name": "index", "datatype": dbt.type_int()}
] %}
{% for c in columns %}{{ c.name }}:{{ c.datatype }},{% endfor %}
"#.to_string(),
        )]);

        let ctx = DbtContext {
            project_name: "test_project".to_string(),
            execute: false,
            vars: std::collections::HashMap::new(),
            target_name: "dev".to_string(),
            target_schema: "public".to_string(),
            target_database: "db".to_string(),
            target_type: "duckdb".to_string(),
            refs: std::sync::Arc::new(std::sync::Mutex::new(vec![])),
            sources: std::sync::Arc::new(std::sync::Mutex::new(vec![])),
            config_values: std::sync::Arc::new(std::sync::Mutex::new(std::collections::HashMap::new())),
            ref_resolutions: std::collections::HashMap::new(),
            source_resolutions: std::collections::HashMap::new(),
            full_refresh: false,
            is_incremental: false,
            this_relation: None,
            relation_columns: std::collections::HashMap::new(),
        };

        // Model SQL that calls the project macro via the namespace
        let sql = "SELECT {{ test_project.get_type_test() }} as result";
        let result = engine.render(sql, &ctx);
        match &result {
            Ok(r) => eprintln!("Engine test result: {}", r),
            Err(e) => eprintln!("Engine test error: {}", e),
        }
        assert!(result.is_ok(), "Engine render failed: {:?}", result.err());
    }

    #[test]
    fn test_extract_config_from_raw_multiple_blocks() {
        let config_values = std::sync::Arc::new(std::sync::Mutex::new(std::collections::HashMap::new()));
        let sql = "{{ config(materialized='table') }}\n{{ config(schema='staging') }}\nSELECT 1";
        JinjaEngine::extract_config_from_raw(sql, &config_values);
        let cv = config_values.lock().unwrap();
        assert_eq!(cv.get("materialized"), Some(&"table".to_string()));
        assert_eq!(cv.get("schema"), Some(&"staging".to_string()));
    }

    #[test]
    fn test_extract_config_from_raw_escaped_quotes() {
        let config_values = std::sync::Arc::new(std::sync::Mutex::new(std::collections::HashMap::new()));
        let sql = r#"{{ config(materialized='table', pre_hook="SET x = 'y'") }}"#;
        JinjaEngine::extract_config_from_raw(sql, &config_values);
        let cv = config_values.lock().unwrap();
        assert_eq!(cv.get("materialized"), Some(&"table".to_string()));
    }

    #[test]
    fn test_rewrite_do_with_string_containing_percent_brace() {
        let sql = r#"{% do log("hello %} world") %}SELECT 1"#;
        let result = rewrite_do_statements(sql);
        assert!(result.contains(r#"{% set _do_0 = log("hello %} world") %}"#), "got: {}", result);
        assert!(result.contains("SELECT 1"));
    }

    #[test]
    fn test_strip_list_concat_preserves_func_addition() {
        // func() + other_func() is arithmetic, not list concat
        let sql = "{% set x = func() + other_func() %}SELECT 1";
        let result = strip_list_concat(sql);
        assert_eq!(result, sql);
    }

    #[test]
    fn test_strip_list_concat_strips_list_plus_func() {
        // ['a'] + func() IS list concat
        let sql = "{% set x = ['a'] + func() %}SELECT 1";
        let result = strip_list_concat(sql);
        assert!(result.contains("['a']"), "should keep the list: {}", result);
        assert!(!result.contains("func()"), "should strip func(): {}", result);
    }

    #[test]
    fn test_strip_config_blocks_with_unicode() {
        let sql = "{{ config(materialized='table', description='données utilisateur') }}\nSELECT 1";
        let result = strip_config_blocks(sql);
        assert_eq!(result, "SELECT 1");
    }

    #[test]
    fn test_mutable_dict_rendering() {
        // Test the full pipeline: rewrite_dict_mutation + rewrite_do_statements + render
        let macro_body = r#"
{%- set consistent_fields = ['spend', 'impressions', 'clicks'] -%}
{%- set final_fields_superset={} -%}
{%- for consistent_field in consistent_fields -%}
    {%- do final_fields_superset.update({consistent_field: consistent_field}) -%}
{%- endfor -%}
select
{%- for field in final_fields_superset.keys()|sort() %}
  {{ field }}{% if not loop.last %},{% endif %}
{%- endfor %}
from test_table
"#;
        // Apply preprocessing (same as preprocess_macro_body)
        let processed = preprocess_macro_body(macro_body);
        eprintln!("Processed macro body:\n{}", processed);

        // Build the template
        let tpl = format!("{{% macro get_query() %}}{}{{% endmacro %}}", processed);
        eprintln!("Full template:\n{}", tpl);

        let mut env = Environment::new();
        jinja2::add_jinja2_compat(&mut env);

        // Try adding the template
        match env.add_template_owned("ns".to_string(), tpl.clone()) {
            Ok(()) => eprintln!("Template parsed OK"),
            Err(e) => {
                panic!("Template failed to parse: {}\n\nTemplate:\n{}", e, tpl);
            }
        }

        let render_tpl = r#"{% import "ns" as ns %}{{ ns.get_query() }}"#;
        env.add_template("render", render_tpl).unwrap();
        let tmpl = env.get_template("render").unwrap();
        match tmpl.render(minijinja::context!{}) {
            Ok(result) => {
                eprintln!("Render result:\n{}", result);
                assert!(result.contains("clicks"), "expected 'clicks' in output: {}", result);
                assert!(result.contains("impressions"), "expected 'impressions' in output: {}", result);
                assert!(result.contains("spend"), "expected 'spend' in output: {}", result);
            }
            Err(e) => {
                panic!("Render failed: {}", e);
            }
        }
    }

    #[test]
    fn test_return_value_recovery() {
        // Test that macros using return() have their values recovered via _get_return()
        let mut env = Environment::new();
        jinja2::add_jinja2_compat(&mut env);

        // Register return() and _get_return() — same as the engine does
        env.add_function("return", |args: &[Value]| -> Result<Value, minijinja::Error> {
            let val = args.first().cloned().unwrap_or(Value::UNDEFINED);
            LAST_RETURN_VALUE.with(|v| *v.borrow_mut() = Some(val));
            Ok(Value::from(""))
        });
        env.add_function("_get_return", |args: &[Value]| -> Result<Value, minijinja::Error> {
            let fallback = args.first().cloned().unwrap_or(Value::UNDEFINED);
            let stored = LAST_RETURN_VALUE.with(|v| v.borrow_mut().take());
            Ok(stored.unwrap_or(fallback))
        });

        // Macro that returns a list via return()
        let ns = r#"
{% macro get_items() %}
{% set items = _mklist([]) %}
{% for x in ['a', 'b', 'c'] %}
{% set _ = items.append(x) %}
{% endfor %}
{{ return(items) }}
{% endmacro %}
"#;
        env.add_template_owned("ns".to_string(), ns.to_string()).unwrap();

        // Model SQL that calls the macro — preprocessed to use _get_return()
        let model = r#"{% import "ns" as ns %}{% set items = _get_return(ns.get_items()) %}{% for item in items %}{{ item }},{% endfor %}"#;
        env.add_template("model", model).unwrap();
        let result = env.get_template("model").unwrap().render(minijinja::context!{}).unwrap();
        eprintln!("Return value test result: '{}'", result);
        assert!(result.contains("a,"), "expected 'a,' in output: {}", result);
        assert!(result.contains("b,"), "expected 'b,' in output: {}", result);
        assert!(result.contains("c,"), "expected 'c,' in output: {}", result);
    }

    #[test]
    fn test_wrap_set_macro_calls() {
        // Basic macro call wrapping
        let sql = "{% set x = get_items() %}";
        let result = wrap_set_macro_calls(sql);
        assert!(result.contains("_get_return(get_items())"), "got: {}", result);

        // Should skip builtins
        let sql2 = "{% set x = var('key', 'default') %}";
        let result2 = wrap_set_macro_calls(sql2);
        assert!(!result2.contains("_get_return"), "should not wrap var(): {}", result2);

        // Should skip non-function expressions
        let sql3 = "{% set x = 42 %}";
        let result3 = wrap_set_macro_calls(sql3);
        assert!(!result3.contains("_get_return"), "should not wrap literal: {}", result3);

        // With trim markers
        let sql4 = "{%- set items = get_enabled_packages() -%}";
        let result4 = wrap_set_macro_calls(sql4);
        assert!(result4.contains("_get_return(get_enabled_packages())"), "got: {}", result4);
    }
}
