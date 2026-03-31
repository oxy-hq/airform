use crate::context::DbtContext;
use airform_core::{RefCall, SourceCall};
use minijinja::{Environment, Error as JinjaError, ErrorKind, Value};

/// A custom macro loaded from a macro file.
#[derive(Debug, Clone)]
pub struct LoadedMacro {
    pub name: String,
    pub args: Vec<String>,
    pub body: String,
}

/// The Jinja rendering engine, wrapping minijinja with dbt-compatible functions.
pub struct JinjaEngine {
    env: Environment<'static>,
    custom_macros: Vec<LoadedMacro>,
}

impl JinjaEngine {
    pub fn new() -> Self {
        let mut env = Environment::new();

        // Lenient undefined handling (dbt is permissive with undefined vars)
        env.set_undefined_behavior(minijinja::UndefinedBehavior::Chainable);

        Self {
            env,
            custom_macros: Vec::new(),
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

    /// Render a SQL template with the given dbt context.
    /// Returns the rendered SQL string.
    pub fn render(&self, sql: &str, ctx: &DbtContext) -> anyhow::Result<String> {
        let mut env = self.env.clone();

        // Build macro prefix: prepend custom macro definitions so they are available
        let mut macro_prefix = String::new();
        for m in &self.custom_macros {
            let args_str = m.args.join(", ");
            macro_prefix.push_str(&format!(
                "{{% macro {}({}) %}}{}{{% endmacro %}}\n",
                m.name, args_str, m.body
            ));
        }
        let full_template = if macro_prefix.is_empty() {
            sql.to_string()
        } else {
            format!("{macro_prefix}{sql}")
        };

        // Register the template
        env.add_template("__model__", &full_template)?;

        // Build the context variables
        let refs = ctx.refs.clone();
        let sources = ctx.sources.clone();
        let config_values = ctx.config_values.clone();
        let execute = ctx.execute;
        let ref_resolutions = ctx.ref_resolutions.clone();
        let source_resolutions = ctx.source_resolutions.clone();
        let vars = ctx.vars.clone();
        let target_name = ctx.target_name.clone();
        let target_schema = ctx.target_schema.clone();
        let target_database = ctx.target_database.clone();
        let target_type = ctx.target_type.clone();
        let project_name = ctx.project_name.clone();

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
        // config() in dbt is called with keyword args: config(materialized='table')
        // In minijinja, we handle this by accepting variadic args and kwargs
        let config_values_clone = config_values.clone();
        env.add_function(
            "config",
            move |args: &[Value]| -> Result<Value, JinjaError> {
                let mut cv = config_values_clone.lock().unwrap();
                // Try to extract kwargs from the arguments
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
                Ok(Value::from(val.as_str()))
            } else if let Some(default) = default {
                Ok(default.clone())
            } else {
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
                Ok(Value::from(false))
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

        let tmpl = env.get_template("__model__")?;
        let rendered = tmpl.render(minijinja::context! {
            execute => execute,
            target => target_obj,
            this => Value::UNDEFINED,
        })?;

        Ok(rendered)
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
