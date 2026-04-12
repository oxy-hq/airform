use crate::context::DbtContext;
use airform_core::{RefCall, SourceCall};
use minijinja::{Environment, Error as JinjaError, ErrorKind, Value};
use std::cell::RefCell;
use std::fmt;
use std::sync::Arc;

thread_local! {
    /// Captures the most recent value passed to `return()` in a Jinja macro.
    /// Used by `fill_staging_columns` to receive structured column lists
    /// (since Jinja macros render to text, losing structured data).
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
}

impl JinjaEngine {
    pub fn new() -> Self {
        let mut env = Environment::new();

        // Lenient undefined handling (dbt is permissive with undefined vars)
        env.set_undefined_behavior(minijinja::UndefinedBehavior::Chainable);

        // Handle unknown method calls — supports list.append(), dict.items(), etc.
        env.set_unknown_method_callback(|_state, value, method, args| {
            match method {
                // list.append(item) — mutates list, returns None (we return "")
                "append" => {
                    let _ = (value, args);
                    Ok(Value::from(""))
                }
                // list.extend(items) — mutates list, returns None
                "extend" => {
                    Ok(Value::from(""))
                }
                // dict.items() — return empty list for undefined dicts
                "items" => {
                    if let Some(obj) = value.as_object() {
                        if let Some(iter) = obj.try_iter() {
                            let items: Vec<Value> = iter
                                .map(|k| {
                                    let v = obj.get_value(&k).unwrap_or(Value::UNDEFINED);
                                    Value::from(vec![k, v])
                                })
                                .collect();
                            return Ok(Value::from(items));
                        }
                    }
                    Ok(Value::from(Vec::<Value>::new()))
                }
                // dict.values()
                "values" => {
                    if let Some(obj) = value.as_object() {
                        if let Some(iter) = obj.try_iter() {
                            let vals: Vec<Value> = iter
                                .filter_map(|k| obj.get_value(&k))
                                .collect();
                            return Ok(Value::from(vals));
                        }
                    }
                    Ok(Value::from(Vec::<Value>::new()))
                }
                // dict.keys()
                "keys" => {
                    if let Some(obj) = value.as_object() {
                        if let Some(iter) = obj.try_iter() {
                            let keys: Vec<Value> = iter.collect();
                            return Ok(Value::from(keys));
                        }
                    }
                    Ok(Value::from(Vec::<Value>::new()))
                }
                // dict.get(key, default)
                "get" => {
                    let key = args.first().cloned().unwrap_or(Value::UNDEFINED);
                    let default = args.get(1).cloned().unwrap_or(Value::UNDEFINED);
                    if let Some(obj) = value.as_object() {
                        if let Some(val) = obj.get_value(&key) {
                            return Ok(val);
                        }
                    }
                    Ok(default)
                }
                // dict.update(other) — no-op
                "update" => {
                    Ok(Value::from(""))
                }
                // list.pop() / dict.pop() — no-op, return undefined
                "pop" => {
                    Ok(args.get(1).cloned().unwrap_or(Value::UNDEFINED))
                }
                // str.strip() / str.lstrip() / str.rstrip()
                "strip" => {
                    Ok(Value::from(value.to_string().trim().to_string()))
                }
                "lstrip" => {
                    Ok(Value::from(value.to_string().trim_start().to_string()))
                }
                "rstrip" => {
                    Ok(Value::from(value.to_string().trim_end().to_string()))
                }
                // str.replace(old, new)
                "replace" => {
                    let old = args.first().map(|v| v.to_string()).unwrap_or_default();
                    let new = args.get(1).map(|v| v.to_string()).unwrap_or_default();
                    Ok(Value::from(value.to_string().replace(&old, &new)))
                }
                // str.startswith / str.endswith
                "startswith" => {
                    let prefix = args.first().map(|v| v.to_string()).unwrap_or_default();
                    Ok(Value::from(value.to_string().starts_with(&prefix)))
                }
                "endswith" => {
                    let suffix = args.first().map(|v| v.to_string()).unwrap_or_default();
                    Ok(Value::from(value.to_string().ends_with(&suffix)))
                }
                // str.split(sep)
                "split" => {
                    let sep = args.first().map(|v| v.to_string()).unwrap_or_else(|| " ".to_string());
                    let parts: Vec<Value> = value.to_string().split(&sep).map(|s| Value::from(s.to_string())).collect();
                    Ok(Value::from(parts))
                }
                // For unknown methods on unknown types, return empty string to avoid breaking
                _ => {
                    // If the value is undefined (chainable), just return empty
                    if value.is_undefined() {
                        Ok(Value::from(""))
                    } else {
                        Err(JinjaError::new(
                            ErrorKind::UnknownMethod,
                            format!("{}: no method named {}", value.kind(), method),
                        ))
                    }
                }
            }
        });

        // Register custom filters
        env.add_filter("as_bool", |val: Value| -> bool {
            if let Some(s) = val.as_str() {
                matches!(s.to_lowercase().as_str(), "true" | "1" | "yes")
            } else {
                !val.is_undefined() && !val.is_none() && val.is_true()
            }
        });

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
             "{{ from_date_or_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}"),
            ("datediff", &["first_date", "second_date", "datepart"],
             "DATE_DIFF('{{ datepart }}', {{ first_date }}, {{ second_date }})"),
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
             "STRING_AGG({{ measure }}, {% if delimiter_text is not none %}{{ delimiter_text }}{% else %}', '{% endif %})"),
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
             "SELECT UNNEST(GENERATE_SERIES(CAST({{ start_date }} AS DATE), CAST({{ end_date }} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}"),
            ("pivot", &["column", "values", "alias=true", "agg='sum'", "cmp='='", "prefix=''", "suffix=''", "then_value='1'", "else_value='0'", "quote_identifiers=true", "distinct=false", "field_to_agg=none", "aliases=none"],
             "{% for v in values %}{{ agg }}({% if distinct %}DISTINCT {% endif %}CASE WHEN {{ column }} {{ cmp }} '{{ v }}' THEN {{ then_value }} ELSE {{ else_value }} END) AS {{ prefix }}{{ v }}{{ suffix }}{% if not loop.last %},\n{% endif %}{% endfor %}"),
            ("unpivot", &["relation=none", "cast_to='varchar'", "exclude=[]", "remove=[]", "field_name='field_name'", "value_name='value'"],
             "/* unpivot not supported in airform */ SELECT * FROM {{ relation }}"),
            ("union_data", &["table_identifier=none", "database_variable=none", "schema_variable=none", "default_database=none", "default_schema=none", "default_variable=none", "union_schema_variable=none", "union_database_variable=none"],
             "SELECT * FROM {{ var(schema_variable, default_schema) }}.{{ table_identifier }}"),
            ("enabled_vars", &["vars=[]"], "true"),
            ("fill_staging_columns", &["source_columns", "staging_columns"],
             "{{ _fill_staging_columns_impl() }}"),
            ("string_agg", &["field=none", "delimiter=','", "field_to_agg=none"],
             "STRING_AGG({{ field if field else field_to_agg }}, {{ delimiter }})"),
            ("json_parse", &["string", "string_path"],
             "JSON_EXTRACT({{ string }}, '$.{{ string_path }}')"),
            ("array_agg", &["field"], "ARRAY_AGG({{ field }})"),
            ("timestamp_add", &["datepart", "interval", "from_timestamp"],
             "{{ from_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}"),
            ("timestamp_diff", &["first_timestamp=none", "second_timestamp=none", "datepart='day'", "first_date=none", "second_date=none"],
             "DATE_DIFF('{{ datepart }}', {{ first_timestamp if first_timestamp else first_date }}, {{ second_timestamp if second_timestamp else second_date }})"),
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
            ("get_column_values", &["table", "column", "default=[]", "max_records=none", "order_by='count(*) desc'"],
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
             "{{ from_date_or_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}"),
            ("datediff", &["first_date", "second_date", "datepart"],
             "DATE_DIFF('{{ datepart }}', {{ first_date }}, {{ second_date }})"),
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
             "STRING_AGG({{ measure }}, {% if delimiter_text is not none %}{{ delimiter_text }}{% else %}', '{% endif %})"),
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
             "GENERATE_SERIES({{ start_val }}, {{ stop_val if stop_val else upper_bound }}{% if step %}, {{ step }}{% endif %})"),
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
             "SELECT UNNEST(GENERATE_SERIES(CAST({{ start_date }} AS DATE), CAST({{ end_date }} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}"),
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
            ("get_column_values", &["table", "column", "default=[]", "max_records=none", "order_by='count(*) desc'"],
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
             "GENERATE_SERIES({{ start_val }}, {{ stop_val if stop_val else upper_bound }}{% if step %}, {{ step }}{% endif %})"),
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
             "{{ _fill_staging_columns_impl() }}"),
            ("string_agg", &["field=none", "delimiter=','", "field_to_agg=none"],
             "STRING_AGG({{ field if field else field_to_agg }}, {{ delimiter }})"),
            ("json_parse", &["string", "string_path"],
             "JSON_EXTRACT({{ string }}, '$.{{ string_path }}')"),
            ("array_agg", &["field"], "ARRAY_AGG({{ field }})"),
            ("timestamp_add", &["datepart", "interval", "from_timestamp"],
             "{{ from_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}"),
            ("timestamp_diff", &["first_timestamp=none", "second_timestamp=none", "datepart='day'", "first_date=none", "second_date=none"],
             "DATE_DIFF('{{ datepart }}', {{ first_timestamp if first_timestamp else first_date }}, {{ second_timestamp if second_timestamp else second_date }})"),
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
             "SELECT UNNEST(GENERATE_SERIES(CAST({% if start_date %}{{ start_date }}{% else %}CURRENT_DATE - INTERVAL '{{ n_dateparts }}' {{ datepart }}{% endif %} AS DATE), CAST({% if end_date %}{{ end_date }}{% else %}CURRENT_DATE{% endif %} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}"),
            ("get_columns_in_relation", &["relation"],
             ""),
            ("add_renamed_columns", &["source_columns=[]", "renamed_columns=[]"],
             "{% for col in source_columns %}{% if not loop.first %}, {% endif %}{{ col.name }}{% endfor %}"),
            ("max_bool", &["field=none", "boolean_field=none"],
             "MAX({{ field if field else boolean_field }})"),
            ("fivetran_date_spine", &["datepart", "start_date", "end_date"],
             "SELECT UNNEST(GENERATE_SERIES(CAST({{ start_date }} AS DATE), CAST({{ end_date }} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}"),
        ];

        // ── snowplow_utils namespace (stubs) ─────────────────────────────
        let snowplow_utils_macros: &[(&str, &[&str], &str)] = &[
            ("get_value_by_target_type", &["bigquery_val=none", "snowflake_val=none", "databricks_val=none", "default_val=none"],
             "{{ default_val }}"),
            ("set_query_tag", &["tag=none"], ""),
            ("allow_refresh", &[], ""),
            ("get_split_to_array", &["field", "relation_alias=none", "delimiter=','"],
             "STRING_SPLIT({{ field }}, {{ delimiter }})"),
            ("get_string_agg", &["base_query", "field", "delimiter=','", "sort_numeric=false", "order_by_column=none", "sort_by_suffix=none", "is_distinct=false"],
             "STRING_AGG({{ field }}, {{ delimiter }})"),
            ("timestamp_add", &["datepart", "interval", "tstamp"],
             "{{ tstamp }} + INTERVAL '{{ interval }}' {{ datepart }}"),
            ("timestamp_diff", &["first_tstamp", "second_tstamp", "datepart"],
             "DATE_DIFF('{{ datepart }}', {{ first_tstamp }}, {{ second_tstamp }})"),
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
             "SELECT UNNEST(GENERATE_SERIES(CAST({% if start_date %}{{ start_date }}{% else %}CURRENT_DATE - INTERVAL '{{ n_dateparts }}' {{ datepart }}{% endif %} AS DATE), CAST({% if end_date %}{{ end_date }}{% else %}CURRENT_DATE{% endif %} AS DATE), INTERVAL '1' {{ datepart }})) AS date_{{ datepart }}"),
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
                        // Function calls like var(...) → none
                        if fixed.contains('(') && fixed.contains(')') {
                            fixed = "none".to_string();
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
    fn build_namespace_template(macros: &[LoadedMacro]) -> String {
        let test_env = Environment::new();
        let mut s = String::new();
        for m in macros {
            let clean = Self::clean_args(&m.args);
            let args_str = clean.join(", ");
            let mut body = preprocess_macro_body(&m.body);
            // Detect dispatcher macros: body is just `{{ return(adapter.dispatch('name')(args)) }}`
            // Replace with a direct call to default__name(args) since adapter is not in macro scope.
            if body.contains("adapter.dispatch(") {
                let trimmed = body.trim();
                if trimmed.starts_with("{{ return(") || trimmed.starts_with("{{return(") {
                    if let Some(dispatched) = extract_dispatch_name(&body) {
                        body = format!("{{{{ default__{}({}) | trim }}}}", dispatched, args_str);
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
            if probe.add_template_owned(format!("__probe_{}", m.name), macro_str.clone()).is_ok() {
                s.push_str(&macro_str);
            }
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

        // Remove {% do ... %} statements (not supported by minijinja)
        result = strip_do_statements(&result);

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

        // Replace list concatenation with + that minijinja doesn't support:
        // `list + ['item']` → `list`  and  `['a'] + func()` → `['a']`
        result = strip_list_concat(&result);

        // Fix unary negation of function calls: minijinja can't handle `-func(...)`.
        // Replace `=-func(` with `=(0 - func(` in Jinja expression contexts.
        result = fix_unary_negation(&result);

        result
    }

    /// Render a SQL template with the given dbt context.
    /// Returns the rendered SQL string.
    pub fn render(&self, sql: &str, ctx: &DbtContext) -> anyhow::Result<String> {
        let mut env = self.env.clone();

        // Register namespace templates so {% import "dbt" as dbt %} works
        for ns in &self.builtin_namespaces {
            let tmpl = Self::build_namespace_template(&ns.macros);
            env.add_template_owned(ns.name.to_string(), tmpl)?;
        }

        // All custom macros are included — their bodies are preprocessed
        // in build_namespace_template() to handle {% do %}, dict literals, etc.
        let safe_macros: Vec<&LoadedMacro> = self.custom_macros.iter().collect();

        // Register custom macros as a project-level namespace template
        let mut project_ns_ok = false;
        if !safe_macros.is_empty() && !ctx.project_name.is_empty() {
            let safe_owned: Vec<LoadedMacro> = safe_macros.iter().map(|m| (*m).clone()).collect();
            let project_tmpl = Self::build_namespace_template(&safe_owned);
            match env.add_template_owned(ctx.project_name.clone(), project_tmpl) {
                Ok(_) => { project_ns_ok = true; }
                Err(_) => { /* skip namespace import if template fails to parse */ }
            }
        }

        // Build macro prefix: prepend namespace imports + custom macro definitions
        let mut macro_prefix = String::new();

        // Auto-import all builtin namespaces
        for ns in &self.builtin_namespaces {
            macro_prefix.push_str(&format!(
                "{{% import \"{}\" as {} %}}\n",
                ns.name, ns.name
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
            let test_env = Environment::new();
            for m in &safe_macros {
                let clean = Self::clean_args(&m.args);
                let args_str = clean.join(", ");
                let mut body = preprocess_macro_body(&m.body);
                // Detect dispatcher macros: body is just `{{ return(adapter.dispatch('name')(args)) }}`
                // Replace with a direct call to default__name(args) since adapter is not in macro scope.
                if body.contains("adapter.dispatch(") {
                    let trimmed = body.trim();
                    if trimmed.starts_with("{{ return(") || trimmed.starts_with("{{return(") {
                        if let Some(dispatched) = extract_dispatch_name(&body) {
                            body = format!("{{{{ default__{}({}) | trim }}}}", dispatched, args_str);
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
                fallback_prefix.push_str(&format!(
                    "{{% import \"{}\" as {} %}}\n",
                    ns.name, ns.name
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

        // Register source() function
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

                if execute {
                    let key = (source_name.clone(), table_name.clone());
                    if let Some(relation) = source_resolutions_clone.get(&key) {
                        Ok(Value::from(relation.as_str()))
                    } else {
                        Ok(Value::from(format!("{source_name}.{table_name}")))
                    }
                } else {
                    Ok(Value::from(format!("{source_name}.{table_name}")))
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
                // Try to preserve the original type: parse as bool/int/float before falling back to string
                let result = if val == "true" || val == "True" {
                    Value::from(true)
                } else if val == "false" || val == "False" {
                    Value::from(false)
                } else if val == "none" || val == "None" {
                    Value::from(())
                } else if let Ok(n) = val.parse::<i64>() {
                    Value::from(n)
                } else if let Ok(n) = val.parse::<f64>() {
                    Value::from(n)
                } else {
                    Value::from(val.as_str())
                };
                Ok(result)
            } else if let Some(default) = default {
                Ok(default.clone())
            } else {
                // Return empty string for undefined vars. This produces cleaner
                // compiled SQL than [] (empty list) which creates invalid "FROM []".
                // Templates should use var('x', []) or var('x', '') for defaults.
                Ok(Value::from(""))
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
        // for fill_staging_columns to consume, renders as empty string like dbt's return())
        env.add_function(
            "return",
            |args: &[Value]| -> Result<Value, JinjaError> {
                let val = args.first().cloned().unwrap_or(Value::UNDEFINED);
                LAST_RETURN_VALUE.with(|v| *v.borrow_mut() = Some(val.clone()));
                Ok(Value::from(""))
            },
        );

        // Register _fill_staging_columns_impl() — reads the column list from thread-local
        // (set by the most recent return() call from a get_*_columns macro)
        env.add_function(
            "_fill_staging_columns_impl",
            || -> Result<Value, JinjaError> {
                let columns = LAST_RETURN_VALUE.with(|v| v.borrow_mut().take());
                if let Some(cols) = columns {
                    if let Ok(iter) = cols.try_iter() {
                        let mut alias_parts = Vec::new();
                        for item in iter {
                            let name: String = item
                                .get_attr("name")
                                .ok()
                                .map(|v: Value| v.to_string())
                                .unwrap_or_default();
                            if name.is_empty() {
                                continue;
                            }
                            let alias: Option<String> = item.get_attr("alias").ok().and_then(|v: Value| {
                                let s = v.to_string();
                                if s.is_empty()
                                    || s == "undefined"
                                    || s == "none"
                                    || s == "None"
                                {
                                    None
                                } else {
                                    Some(s)
                                }
                            });
                            // Only add columns that have aliases — base columns come from *
                            if let Some(a) = alias {
                                alias_parts.push(format!("{} as {}", name, a));
                            }
                        }
                        if !alias_parts.is_empty() {
                            // Output * plus alias mappings
                            return Ok(Value::from(format!("*,\n    {}", alias_parts.join(",\n    "))));
                        }
                    }
                }
                Ok(Value::from("*"))
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

        // Build adapter object
        let adapter_obj = Value::from_object(AdapterObject {});

        // Build dbt namespace object — accessible from inside macros (unlike {% import %})
        let dbt_obj = Value::from_object(DbtNamespaceObject {});

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
        if let Ok(tmpl_err) = env.get_template("__model__") {
            if let Some(line_no) = last_err.line() {
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

/// Global dbt namespace object — accessible from inside macros (unlike {% import %}).
/// Extract an argument by position or by kwargs name from method args.
/// MiniJinja passes kwargs as the last element of args (a Kwargs map).
fn get_method_arg(args: &[Value], pos: usize, kwarg_names: &[&str]) -> String {
    // First try positional (non-kwargs values)
    if let Some(val) = args.get(pos) {
        if !val.is_kwargs() {
            return val.to_string();
        }
    }
    // Try kwargs (last arg if it's a kwargs map)
    if let Some(last) = args.last() {
        if last.is_kwargs() {
            for name in kwarg_names {
                if let Ok(val) = last.get_attr(name) {
                    let s = val.to_string();
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
                Ok(Value::from(format!("{from_date} + INTERVAL '{interval}' {datepart}")))
            }
            "datediff" => {
                let datepart = get_method_arg(args, 0, &["datepart"]);
                let first_date = get_method_arg(args, 1, &["first_date"]);
                let second_date = get_method_arg(args, 2, &["second_date"]);
                Ok(Value::from(format!(
                    "DATE_DIFF('{datepart}', {first_date}, {second_date})"
                )))
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
                let fields: Vec<String> = args.iter().map(|v| v.to_string()).collect();
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
                Ok(Value::from(format!("STRING_AGG({field}, {delimiter})")))
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
            _ => {
                // Fall back to trying template-level macro
                Ok(Value::from(""))
            }
        }
    }
}

/// Stub adapter object that provides dbt adapter methods.
#[derive(Debug)]
struct AdapterObject {}

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
                Ok(Value::from(Vec::<Value>::new()))
            }
            "get_relation" => {
                // Return a truthy relation stub so that `if relation is not none` checks pass
                // and the macro generates the actual SQL instead of the empty warning branch.
                Ok(Value::from("__relation__"))
            }
            "dispatch" => {
                let macro_name = args
                    .first()
                    .map(|v| v.to_string())
                    .unwrap_or_default();
                let target_name = format!("default__{macro_name}");
                Ok(Value::from_object(DispatchResult { target_name }))
            }
            "set_query_tag" | "set_query_comment" => {
                Ok(Value::from(""))
            }
            _ => {
                Ok(Value::UNDEFINED)
            }
        }
    }
}

/// Result of adapter.dispatch() — a callable that resolves to the default__ macro.
#[derive(Debug)]
struct DispatchResult {
    target_name: String,
}

impl fmt::Display for DispatchResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "<dispatch:{}>", self.target_name)
    }
}

impl minijinja::value::Object for DispatchResult {
    fn call(self: &Arc<Self>, state: &minijinja::State, args: &[Value]) -> Result<Value, JinjaError> {
        match state.call_macro(&self.target_name, args) {
            Ok(result) => Ok(Value::from(result)),
            Err(_) => {
                Ok(Value::from(""))
            }
        }
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
/// Removes the ` + EXPR` part where EXPR is a list literal or function call.
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

fn strip_do_statements(sql: &str) -> String {
    let mut result = sql.to_string();
    loop {
        let found = result.find("{% do ")
            .or_else(|| result.find("{%- do "))
            .or_else(|| result.find("{%-do "));
        if let Some(start) = found {
            // Find closing %} while respecting string literals
            let rest = &result[start..];
            let mut in_string: Option<char> = None;
            let mut close_pos = None;
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
                        b'%' if bytes[j + 1] == b'}' => {
                            close_pos = Some(j + 2);
                            break;
                        }
                        _ => {}
                    }
                }
                j += 1;
            }
            if let Some(offset) = close_pos {
                let mut end = start + offset;
                // Consume trailing newline
                if end < result.len() && result.as_bytes()[end] == b'\n' {
                    end += 1;
                }
                result.replace_range(start..end, "");
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
    let mut result = sql.to_string();
    // Repeatedly find and replace ternary patterns
    // Pattern: ='string' if ... else 'string'  OR  ="string" if ... else "string"
    loop {
        let mut found = false;
        // Search for ` if ` that appears after a value in kwarg context
        if let Some(if_pos) = find_kwarg_ternary(&result) {
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
    let bytes = sql.as_bytes();
    let len = bytes.len();
    let mut i = 0;
    while i + 4 < len {
        // Look for " if " or ")if " patterns
        if (bytes[i] == b' ' || bytes[i] == b')') && &bytes[i + 1..i + 4] == b"if " {
            if is_inside_jinja(sql, i) {
                // Verify there's a kwarg context: go backwards past value to find =
                let trimmed = sql[..i].trim_end();
                let has_kwarg = {
                    // Check if the value before ` if ` is preceded by `=`
                    // Value can be: 'string', "string", identifier, func_call()
                    let mut j = trimmed.len();
                    // Skip past string literal or identifier
                    if j > 0 && (trimmed.as_bytes()[j - 1] == b'\'' || trimmed.as_bytes()[j - 1] == b'"') {
                        let quote = trimmed.as_bytes()[j - 1];
                        j -= 1;
                        while j > 0 && trimmed.as_bytes()[j - 1] != quote {
                            j -= 1;
                        }
                        if j > 0 {
                            j -= 1; // skip opening quote
                        }
                    } else if j > 0 && trimmed.as_bytes()[j - 1] == b')' {
                        // Skip function call - find matching (
                        let mut depth = 1;
                        j -= 1;
                        while j > 0 && depth > 0 {
                            j -= 1;
                            if trimmed.as_bytes()[j] == b')' {
                                depth += 1;
                            } else if trimmed.as_bytes()[j] == b'(' {
                                depth -= 1;
                            }
                        }
                        // Skip function name
                        while j > 0 && (trimmed.as_bytes()[j - 1].is_ascii_alphanumeric() || trimmed.as_bytes()[j - 1] == b'_' || trimmed.as_bytes()[j - 1] == b'.') {
                            j -= 1;
                        }
                    } else {
                        // Skip identifier
                        while j > 0 && (trimmed.as_bytes()[j - 1].is_ascii_alphanumeric() || trimmed.as_bytes()[j - 1] == b'_' || trimmed.as_bytes()[j - 1] == b'.') {
                            j -= 1;
                        }
                    }
                    // Check for = before the value
                    let before_val = trimmed[..j].trim_end();
                    before_val.ends_with('=')
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
    let mut result = String::with_capacity(sql.len());
    let chars: Vec<char> = sql.chars().collect();
    let len = chars.len();
    let mut i = 0;

    while i < len {
        // Look for { that's not part of {{ or {% or {#
        if chars[i] == '{' && i + 1 < len {
            let next = chars[i + 1];
            if next == '{' || next == '%' || next == '#' || next == '-' {
                result.push(chars[i]);
                i += 1;
                continue;
            }
            // Only replace dicts that are inside a Jinja context
            let byte_pos: usize = chars[..i].iter().map(|c| c.len_utf8()).sum();
            if !is_inside_jinja(sql, byte_pos) {
                result.push(chars[i]);
                i += 1;
                continue;
            }
            // Check if this looks like a Python dict literal
            // Pattern: { followed by optional whitespace/newlines then ' or "
            // Only detect dict if preceded by = ( [ , : or whitespace (not random SQL chars)
            let prev_char = if i > 0 { chars[i - 1] } else { ' ' };
            let dict_context = prev_char == '=' || prev_char == '(' || prev_char == '['
                || prev_char == ',' || prev_char == ':' || prev_char == ' '
                || prev_char == '\n' || prev_char == '\t';
            // Skip dicts inside {% set x = {...} %} — they're used for iteration
            // and minijinja supports dict literals natively
            let in_set_tag = {
                let before: String = chars[..i].iter().collect();
                let last_block_open = before.rfind("{%");
                if let Some(o) = last_block_open {
                    let tag_content = &before[o..];
                    tag_content.contains(" set ") || tag_content.contains("-set ") || tag_content.contains(" set\n")
                } else {
                    false
                }
            };
            if in_set_tag {
                result.push(chars[i]);
                i += 1;
                continue;
            }
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
    let mut result = preprocess_dicts(body);
    result = strip_do_statements(&result);
    result = strip_list_concat(&result);
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
    fn test_strip_do_statements() {
        let sql = "{% do some_list.append('x') %}\nSELECT 1\n{%- do log('msg') %}";
        let result = strip_do_statements(sql);
        assert_eq!(result, "SELECT 1\n");
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
        assert_eq!(result, "{{ func(none) }}");
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
    fn test_strip_do_with_string_containing_percent_brace() {
        let sql = r#"{% do log("hello %} world") %}SELECT 1"#;
        let result = strip_do_statements(sql);
        assert_eq!(result, "SELECT 1");
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
}
