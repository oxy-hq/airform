use regex::Regex;
use sqlparser::ast::{
    CastKind, Expr, Function, FunctionArg, FunctionArgExpr, FunctionArgumentList,
    FunctionArguments, Ident, ObjectName, Query, Select, SetExpr, Statement,
};
use sqlparser::dialect::{
    BigQueryDialect, ClickHouseDialect, DatabricksDialect, DuckDbDialect, GenericDialect,
    PostgreSqlDialect, RedshiftSqlDialect, SQLiteDialect, SnowflakeDialect,
};
use sqlparser::parser::Parser;
use std::sync::LazyLock;

/// Supported SQL dialects for transpilation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SqlDialect {
    Snowflake,
    BigQuery,
    Redshift,
    Databricks,
    Postgres,
    DuckDb,
    ClickHouse,
    SQLite,
    DataFusion,
    Generic,
}

impl SqlDialect {
    /// Map a dbt adapter type string to a `SqlDialect`.
    pub fn from_adapter_type(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "snowflake" => SqlDialect::Snowflake,
            "bigquery" => SqlDialect::BigQuery,
            "redshift" => SqlDialect::Redshift,
            "databricks" | "spark" => SqlDialect::Databricks,
            "postgres" | "postgresql" => SqlDialect::Postgres,
            "duckdb" | "motherduck" => SqlDialect::DuckDb,
            "clickhouse" => SqlDialect::ClickHouse,
            "sqlite" => SqlDialect::SQLite,
            "datafusion" => SqlDialect::DataFusion,
            _ => SqlDialect::Generic,
        }
    }

    /// Return the corresponding `sqlparser` dialect for parsing.
    fn get_sqlparser_dialect(&self) -> Box<dyn sqlparser::dialect::Dialect> {
        match self {
            SqlDialect::Snowflake => Box::new(SnowflakeDialect),
            SqlDialect::BigQuery => Box::new(BigQueryDialect),
            SqlDialect::Redshift => Box::new(RedshiftSqlDialect {}),
            SqlDialect::Databricks => Box::new(DatabricksDialect),
            SqlDialect::Postgres => Box::new(PostgreSqlDialect {}),
            SqlDialect::DuckDb => Box::new(DuckDbDialect),
            SqlDialect::ClickHouse => Box::new(ClickHouseDialect {}),
            SqlDialect::SQLite => Box::new(SQLiteDialect {}),
            SqlDialect::DataFusion => Box::new(GenericDialect),
            SqlDialect::Generic => Box::new(GenericDialect),
        }
    }
}

/// Normalize dialect-specific SQL to DataFusion-compatible SQL using AST-based
/// transpilation. Falls back to regex-based normalization on parse failure.
pub fn normalize_sql(sql: &str, dialect: &SqlDialect) -> String {
    let parser_dialect = dialect.get_sqlparser_dialect();
    let parse_result = Parser::parse_sql(parser_dialect.as_ref(), sql);

    match parse_result {
        Ok(mut statements) if !statements.is_empty() => {
            let results: Vec<String> = statements
                .iter_mut()
                .map(|stmt| {
                    rewrite_statement(stmt);
                    // Replace backtick-quoted identifiers with double-quoted
                    stmt.to_string().replace('`', "\"")
                })
                .collect();
            results.join("; ")
        }
        _ => {
            // Fall back to regex-based normalization
            regex_normalize_sql(sql)
        }
    }
}

/// Rewrite a single statement in-place to be DataFusion-compatible.
fn rewrite_statement(stmt: &mut Statement) {
    if let Statement::Query(query) = stmt {
        rewrite_query(query);
    }
}

/// Recursively rewrite a query.
fn rewrite_query(query: &mut Query) {
    rewrite_set_expr(&mut query.body);
    if let Some(order_by) = &mut query.order_by {
        for expr_item in &mut order_by.exprs {
            take_and_rewrite(&mut expr_item.expr);
        }
    }
}

/// Rewrite a set expression (SELECT, UNION, etc).
fn rewrite_set_expr(set_expr: &mut SetExpr) {
    match set_expr {
        SetExpr::Select(select) => rewrite_select(select),
        SetExpr::Query(query) => rewrite_query(query),
        SetExpr::SetOperation { left, right, .. } => {
            rewrite_set_expr(left);
            rewrite_set_expr(right);
        }
        _ => {}
    }
}

/// Helper: take an expression out, rewrite it, and put it back.
fn take_and_rewrite(expr: &mut Expr) {
    let placeholder = Expr::Value(sqlparser::ast::Value::Null);
    let taken = std::mem::replace(expr, placeholder);
    *expr = rewrite_expr(taken);
}

/// Rewrite a SELECT statement in-place.
fn rewrite_select(select: &mut Select) {
    // Strip QUALIFY clause
    select.qualify = None;

    // Rewrite projection expressions
    for item in &mut select.projection {
        match item {
            sqlparser::ast::SelectItem::UnnamedExpr(expr)
            | sqlparser::ast::SelectItem::ExprWithAlias { expr, .. } => {
                take_and_rewrite(expr);
            }
            _ => {}
        }
    }

    // Rewrite WHERE clause
    if let Some(expr) = &mut select.selection {
        take_and_rewrite(expr);
    }

    // Rewrite HAVING clause
    if let Some(expr) = &mut select.having {
        take_and_rewrite(expr);
    }

    // Rewrite FROM subqueries and join conditions
    for table_with_joins in &mut select.from {
        rewrite_table_factor(&mut table_with_joins.relation);
        for join in &mut table_with_joins.joins {
            rewrite_table_factor(&mut join.relation);
            let constraint = match &mut join.join_operator {
                sqlparser::ast::JoinOperator::Inner(c)
                | sqlparser::ast::JoinOperator::LeftOuter(c)
                | sqlparser::ast::JoinOperator::RightOuter(c)
                | sqlparser::ast::JoinOperator::FullOuter(c)
                | sqlparser::ast::JoinOperator::LeftSemi(c)
                | sqlparser::ast::JoinOperator::RightSemi(c)
                | sqlparser::ast::JoinOperator::LeftAnti(c)
                | sqlparser::ast::JoinOperator::RightAnti(c)
                | sqlparser::ast::JoinOperator::AsOf { constraint: c, .. } => Some(c),
                _ => None,
            };
            if let Some(sqlparser::ast::JoinConstraint::On(expr)) = constraint {
                take_and_rewrite(expr);
            }
        }
    }

    // Rewrite GROUP BY expressions
    if let sqlparser::ast::GroupByExpr::Expressions(exprs, _) = &mut select.group_by {
        for expr in exprs.iter_mut() {
            take_and_rewrite(expr);
        }
    }
}

/// Rewrite table factors (for subqueries in FROM clauses).
fn rewrite_table_factor(tf: &mut sqlparser::ast::TableFactor) {
    match tf {
        sqlparser::ast::TableFactor::Derived { subquery, .. } => {
            rewrite_query(subquery);
        }
        sqlparser::ast::TableFactor::NestedJoin {
            table_with_joins, ..
        } => {
            rewrite_table_factor(&mut table_with_joins.relation);
            for join in &mut table_with_joins.joins {
                rewrite_table_factor(&mut join.relation);
            }
        }
        _ => {}
    }
}

/// Rewrite an expression, returning the rewritten version.
fn rewrite_expr(expr: Expr) -> Expr {
    match expr {
        // ILIKE -> LOWER(lhs) LIKE LOWER(pattern)
        Expr::ILike {
            negated,
            any: _,
            expr: lhs,
            pattern,
            escape_char,
        } => {
            let lower_lhs = make_lower_call(rewrite_expr(*lhs));
            let lower_pattern = make_lower_call(rewrite_expr(*pattern));
            Expr::Like {
                negated,
                any: false,
                expr: Box::new(lower_lhs),
                pattern: Box::new(lower_pattern),
                escape_char,
            }
        }

        // IFNULL(a, b) / NVL(a, b) -> COALESCE(a, b)
        Expr::Function(func) => {
            let name_upper = func.name.to_string().to_uppercase();
            let mut new_func = func;
            if name_upper == "IFNULL" || name_upper == "NVL" {
                new_func.name = ObjectName(vec![Ident::new("COALESCE")]);
            }
            // ClickHouse toFloat64/toInt32/etc → CAST(arg AS type)
            if let Some(stripped) = name_upper.strip_prefix("TO") {
                let cast_type = match stripped {
                    "FLOAT64" | "FLOAT32" => Some("DOUBLE"),
                    "INT8" | "INT16" | "INT32" | "INT64" | "UINT8" | "UINT16" | "UINT32"
                    | "UINT64" => Some("BIGINT"),
                    "STRING" => Some("VARCHAR"),
                    _ => None,
                };
                if let Some(target_type) = cast_type {
                    if let FunctionArguments::List(ref list) = new_func.args {
                        if let Some(FunctionArg::Unnamed(FunctionArgExpr::Expr(inner))) =
                            list.args.first()
                        {
                            return Expr::Cast {
                                kind: CastKind::Cast,
                                expr: Box::new(rewrite_expr(inner.clone())),
                                data_type: sqlparser::ast::DataType::Custom(
                                    ObjectName(vec![Ident::new(target_type)]),
                                    vec![],
                                ),
                                format: None,
                            };
                        }
                    }
                }
            }
            rewrite_function_args(&mut new_func.args);
            if let Some(filter) = &mut new_func.filter {
                let taken = std::mem::replace(filter.as_mut(), Expr::Value(sqlparser::ast::Value::Null));
                *filter.as_mut() = rewrite_expr(taken);
            }
            Expr::Function(new_func)
        }

        // Recursively rewrite subexpressions
        Expr::BinaryOp { left, op, right } => Expr::BinaryOp {
            left: Box::new(rewrite_expr(*left)),
            op,
            right: Box::new(rewrite_expr(*right)),
        },
        Expr::UnaryOp { op, expr: inner } => Expr::UnaryOp {
            op,
            expr: Box::new(rewrite_expr(*inner)),
        },
        Expr::Nested(inner) => Expr::Nested(Box::new(rewrite_expr(*inner))),
        Expr::Cast {
            kind,
            expr: inner,
            data_type,
            format,
        } => {
            // Normalize :: cast syntax to standard CAST()
            let normalized_kind = match kind {
                CastKind::DoubleColon => CastKind::Cast,
                other => other,
            };
            Expr::Cast {
                kind: normalized_kind,
                expr: Box::new(rewrite_expr(*inner)),
                data_type,
                format,
            }
        }
        Expr::Case {
            operand,
            conditions,
            results,
            else_result,
        } => Expr::Case {
            operand: operand.map(|e| Box::new(rewrite_expr(*e))),
            conditions: conditions.into_iter().map(rewrite_expr).collect(),
            results: results.into_iter().map(rewrite_expr).collect(),
            else_result: else_result.map(|e| Box::new(rewrite_expr(*e))),
        },
        Expr::InSubquery {
            expr: inner,
            subquery,
            negated,
        } => {
            let mut sq = subquery;
            rewrite_query(&mut sq);
            Expr::InSubquery {
                expr: Box::new(rewrite_expr(*inner)),
                subquery: sq,
                negated,
            }
        }
        Expr::InList {
            expr: inner,
            list,
            negated,
        } => Expr::InList {
            expr: Box::new(rewrite_expr(*inner)),
            list: list.into_iter().map(rewrite_expr).collect(),
            negated,
        },
        Expr::Between {
            expr: inner,
            negated,
            low,
            high,
        } => Expr::Between {
            expr: Box::new(rewrite_expr(*inner)),
            negated,
            low: Box::new(rewrite_expr(*low)),
            high: Box::new(rewrite_expr(*high)),
        },
        Expr::Like {
            negated,
            any,
            expr: lhs,
            pattern,
            escape_char,
        } => Expr::Like {
            negated,
            any,
            expr: Box::new(rewrite_expr(*lhs)),
            pattern: Box::new(rewrite_expr(*pattern)),
            escape_char,
        },
        Expr::IsNull(inner) => Expr::IsNull(Box::new(rewrite_expr(*inner))),
        Expr::IsNotNull(inner) => Expr::IsNotNull(Box::new(rewrite_expr(*inner))),
        Expr::IsTrue(inner) => Expr::IsTrue(Box::new(rewrite_expr(*inner))),
        Expr::IsFalse(inner) => Expr::IsFalse(Box::new(rewrite_expr(*inner))),
        Expr::Subquery(mut query) => {
            rewrite_query(&mut query);
            Expr::Subquery(query)
        }
        Expr::Exists {
            mut subquery,
            negated,
        } => {
            rewrite_query(&mut subquery);
            Expr::Exists { subquery, negated }
        }
        // For all other expressions, return as-is
        other => other,
    }
}

/// Create a `LOWER(expr)` function call.
fn make_lower_call(expr: Expr) -> Expr {
    Expr::Function(Function {
        name: ObjectName(vec![Ident::new("LOWER")]),
        uses_odbc_syntax: false,
        parameters: FunctionArguments::None,
        args: FunctionArguments::List(FunctionArgumentList {
            duplicate_treatment: None,
            args: vec![FunctionArg::Unnamed(FunctionArgExpr::Expr(expr))],
            clauses: vec![],
        }),
        filter: None,
        null_treatment: None,
        over: None,
        within_group: vec![],
    })
}

/// Recursively rewrite function arguments.
fn rewrite_function_args(args: &mut FunctionArguments) {
    match args {
        FunctionArguments::List(list) => {
            for arg in &mut list.args {
                match arg {
                    FunctionArg::Unnamed(FunctionArgExpr::Expr(expr))
                    | FunctionArg::Named {
                        arg: FunctionArgExpr::Expr(expr),
                        ..
                    }
                    | FunctionArg::ExprNamed {
                        arg: FunctionArgExpr::Expr(expr),
                        ..
                    } => {
                        take_and_rewrite(expr);
                    }
                    _ => {}
                }
            }
        }
        FunctionArguments::Subquery(query) => {
            rewrite_query(query);
        }
        FunctionArguments::None => {}
    }
}

// ---- Regex-based fallback normalization ----

/// Regex-based normalization as fallback when AST parsing fails.
fn regex_normalize_sql(sql: &str) -> String {
    let mut result = sql.to_string();

    // 1. Snowflake :: cast syntax -> CAST(expr AS type)
    result = rewrite_double_colon_casts(&result);

    // 2. QUALIFY clause -> strip
    result = strip_qualify(&result);

    // 3. ILIKE -> LIKE (lossy but plannable)
    result = ILIKE_RE.replace_all(&result, "LIKE").to_string();

    // 4. BigQuery backtick-quoted identifiers -> double-quoted
    result = result.replace('`', "\"");

    // 5. IFNULL -> COALESCE
    result = IFNULL_RE.replace_all(&result, "COALESCE(").to_string();

    // 6. NVL -> COALESCE
    result = NVL_RE.replace_all(&result, "COALESCE(").to_string();

    // 7. DATEADD -> DATE_ADD
    result = DATEADD_RE.replace_all(&result, "DATE_ADD(").to_string();

    // 8. Strip CLUSTER BY (BigQuery)
    result = CLUSTER_BY_RE.replace_all(&result, "").to_string();

    result
}

static ILIKE_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?i)\bILIKE\b").unwrap());

static IFNULL_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?i)\bIFNULL\s*\(").unwrap());

static NVL_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?i)\bNVL\s*\(").unwrap());

static DATEADD_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?i)\bDATEADD\s*\(").unwrap());

static CLUSTER_BY_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?i)\bCLUSTER\s+BY\s+[^;]+").unwrap());

/// Rewrite Snowflake `::type` cast syntax to CAST(... AS type).
fn rewrite_double_colon_casts(sql: &str) -> String {
    static CAST_RE: LazyLock<Regex> =
        LazyLock::new(|| Regex::new(r"(\b\w+(?:\.\w+)?)\s*::\s*(\w+)").unwrap());

    CAST_RE
        .replace_all(sql, "CAST($1 AS $2)")
        .to_string()
}

/// Strip QUALIFY clauses from SQL.
fn strip_qualify(sql: &str) -> String {
    static QUALIFY_RE: LazyLock<Regex> = LazyLock::new(|| {
        Regex::new(r"(?i)\bQUALIFY\b[^;)]*").unwrap()
    });

    QUALIFY_RE.replace_all(sql, "").to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn snowflake() -> SqlDialect {
        SqlDialect::Snowflake
    }

    fn bigquery() -> SqlDialect {
        SqlDialect::BigQuery
    }

    fn generic() -> SqlDialect {
        SqlDialect::Generic
    }

    #[test]
    fn test_double_colon_cast() {
        let result = normalize_sql("SELECT col::varchar FROM t", &snowflake());
        // sqlparser parses :: as Cast and to_string() emits CAST(... AS ...)
        assert!(
            result.contains("CAST(col AS VARCHAR)") || result.contains("CAST(col AS varchar)"),
            "unexpected result: {result}"
        );
    }

    #[test]
    fn test_ilike() {
        let result = normalize_sql("SELECT * FROM t WHERE name ILIKE '%foo%'", &snowflake());
        assert!(
            result.contains("LOWER") && result.contains("LIKE"),
            "expected LOWER(...) LIKE LOWER(...), got: {result}"
        );
        assert!(
            !result.to_uppercase().contains("ILIKE"),
            "ILIKE should be rewritten, got: {result}"
        );
    }

    #[test]
    fn test_ifnull() {
        let result = normalize_sql("SELECT IFNULL(a, b) FROM t", &snowflake());
        assert!(
            result.contains("COALESCE"),
            "expected COALESCE, got: {result}"
        );
        assert!(
            !result.to_uppercase().contains("IFNULL"),
            "IFNULL should be rewritten, got: {result}"
        );
    }

    #[test]
    fn test_nvl() {
        let result = normalize_sql("SELECT NVL(a, b) FROM t", &snowflake());
        assert!(
            result.contains("COALESCE"),
            "expected COALESCE, got: {result}"
        );
    }

    #[test]
    fn test_backtick_to_double_quote() {
        let result = normalize_sql("SELECT `col` FROM `schema`.`table`", &bigquery());
        // sqlparser with BigQuery dialect parses backtick identifiers and emits them quoted
        assert!(
            !result.contains('`'),
            "backticks should be removed, got: {result}"
        );
    }

    #[test]
    fn test_qualify_stripped() {
        let sql = "SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY ts DESC) AS rn FROM t QUALIFY rn = 1";
        let result = normalize_sql(sql, &snowflake());
        assert!(
            !result.contains("QUALIFY"),
            "QUALIFY should be stripped, got: {result}"
        );
    }

    #[test]
    fn test_fallback_to_regex() {
        // Intentionally broken SQL that sqlparser can't parse should fall back to regex
        let sql = "SELECT IFNULL(a, b) FROM %%%broken";
        let result = normalize_sql(sql, &generic());
        assert!(
            result.contains("COALESCE"),
            "regex fallback should rewrite IFNULL, got: {result}"
        );
    }

    #[test]
    fn test_from_adapter_type() {
        assert_eq!(
            SqlDialect::from_adapter_type("snowflake"),
            SqlDialect::Snowflake
        );
        assert_eq!(
            SqlDialect::from_adapter_type("bigquery"),
            SqlDialect::BigQuery
        );
        assert_eq!(
            SqlDialect::from_adapter_type("redshift"),
            SqlDialect::Redshift
        );
        assert_eq!(
            SqlDialect::from_adapter_type("postgres"),
            SqlDialect::Postgres
        );
        assert_eq!(
            SqlDialect::from_adapter_type("duckdb"),
            SqlDialect::DuckDb
        );
        assert_eq!(
            SqlDialect::from_adapter_type("databricks"),
            SqlDialect::Databricks
        );
        assert_eq!(
            SqlDialect::from_adapter_type("clickhouse"),
            SqlDialect::ClickHouse
        );
        assert_eq!(
            SqlDialect::from_adapter_type("sqlite"),
            SqlDialect::SQLite
        );
        assert_eq!(
            SqlDialect::from_adapter_type("motherduck"),
            SqlDialect::DuckDb
        );
        assert_eq!(
            SqlDialect::from_adapter_type("unknown"),
            SqlDialect::Generic
        );
    }

    #[test]
    fn test_nested_function_rewrite() {
        let result = normalize_sql("SELECT IFNULL(NVL(a, b), c) FROM t", &snowflake());
        assert!(
            !result.to_uppercase().contains("IFNULL") && !result.to_uppercase().contains("NVL"),
            "nested functions should be rewritten, got: {result}"
        );
        let coalesce_count = result.to_uppercase().matches("COALESCE").count();
        assert_eq!(
            coalesce_count, 2,
            "expected 2 COALESCE calls, got: {result}"
        );
    }
}
