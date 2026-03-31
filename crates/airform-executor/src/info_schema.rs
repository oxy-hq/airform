use airform_core::{Manifest, ManifestNode};
use airform_graph::{build_column_lineage, DbtGraph};
use datafusion::arrow::array::{ArrayRef, StringArray};
use datafusion::arrow::datatypes::{DataType, Field, Schema};
use datafusion::arrow::record_batch::RecordBatch;
use datafusion::datasource::MemTable;
use datafusion::prelude::SessionContext;
use std::sync::Arc;

/// Register virtual information schema tables in the DataFusion session.
pub fn register_info_schema(
    ctx: &SessionContext,
    manifest: &Manifest,
    graph: &DbtGraph,
) -> anyhow::Result<()> {
    register_tables_table(ctx, manifest)?;
    register_columns_table(ctx, manifest)?;
    register_table_lineage_table(ctx, manifest, graph)?;
    register_column_lineage_table(ctx, manifest)?;
    Ok(())
}

fn register_tables_table(ctx: &SessionContext, manifest: &Manifest) -> anyhow::Result<()> {
    let mut names = Vec::new();
    let mut unique_ids = Vec::new();
    let mut resource_types = Vec::new();
    let mut materializations = Vec::new();
    let mut descriptions = Vec::new();
    let mut packages = Vec::new();

    for (id, node) in &manifest.nodes {
        match node {
            ManifestNode::Model(m) => {
                names.push(m.name.clone());
                unique_ids.push(id.clone());
                resource_types.push("model".to_string());
                materializations.push(m.config.materialized.to_string());
                descriptions.push(m.description.clone().unwrap_or_default());
                packages.push(m.package_name.clone());
            }
            ManifestNode::Seed(s) => {
                names.push(s.name.clone());
                unique_ids.push(id.clone());
                resource_types.push("seed".to_string());
                materializations.push("seed".to_string());
                descriptions.push(s.description.clone().unwrap_or_default());
                packages.push(s.package_name.clone());
            }
            _ => {}
        }
    }

    for (id, source) in &manifest.sources {
        names.push(format!("{}.{}", source.source_name, source.name));
        unique_ids.push(id.clone());
        resource_types.push("source".to_string());
        materializations.push("source".to_string());
        descriptions.push(source.description.clone().unwrap_or_default());
        packages.push(source.package_name.clone());
    }

    let schema = Arc::new(Schema::new(vec![
        Field::new("name", DataType::Utf8, false),
        Field::new("unique_id", DataType::Utf8, false),
        Field::new("resource_type", DataType::Utf8, false),
        Field::new("materialization", DataType::Utf8, false),
        Field::new("description", DataType::Utf8, true),
        Field::new("package_name", DataType::Utf8, false),
    ]));

    let batch = RecordBatch::try_new(
        schema.clone(),
        vec![
            Arc::new(StringArray::from(names)) as ArrayRef,
            Arc::new(StringArray::from(unique_ids)) as ArrayRef,
            Arc::new(StringArray::from(resource_types)) as ArrayRef,
            Arc::new(StringArray::from(materializations)) as ArrayRef,
            Arc::new(StringArray::from(descriptions)) as ArrayRef,
            Arc::new(StringArray::from(packages)) as ArrayRef,
        ],
    )?;

    let table = MemTable::try_new(schema, vec![vec![batch]])?;
    let _ = ctx.deregister_table("airform_tables");
    ctx.register_table("airform_tables", Arc::new(table))?;
    Ok(())
}

fn register_columns_table(ctx: &SessionContext, manifest: &Manifest) -> anyhow::Result<()> {
    let mut table_names = Vec::new();
    let mut column_names = Vec::new();
    let mut data_types = Vec::new();
    let mut descriptions = Vec::new();
    let mut tests: Vec<String> = Vec::new();

    for (_id, node) in &manifest.nodes {
        let (name, columns) = match node {
            ManifestNode::Model(m) => (m.name.as_str(), &m.columns),
            ManifestNode::Seed(s) => (s.name.as_str(), &s.columns),
            _ => continue,
        };
        for col in columns {
            table_names.push(name.to_string());
            column_names.push(col.name.clone());
            data_types.push(col.data_type.clone().unwrap_or_default());
            descriptions.push(col.description.clone().unwrap_or_default());
            let test_names: Vec<String> = col
                .tests
                .iter()
                .map(|t| match t {
                    airform_core::TestDef::Simple(s) => s.clone(),
                    airform_core::TestDef::Complex(m) => {
                        m.keys().cloned().collect::<Vec<_>>().join(",")
                    }
                })
                .collect();
            tests.push(test_names.join(", "));
        }
    }

    for (_id, source) in &manifest.sources {
        let name = format!("{}.{}", source.source_name, source.name);
        for col in &source.columns {
            table_names.push(name.clone());
            column_names.push(col.name.clone());
            data_types.push(col.data_type.clone().unwrap_or_default());
            descriptions.push(col.description.clone().unwrap_or_default());
            let test_names: Vec<String> = col
                .tests
                .iter()
                .map(|t| match t {
                    airform_core::TestDef::Simple(s) => s.clone(),
                    airform_core::TestDef::Complex(m) => {
                        m.keys().cloned().collect::<Vec<_>>().join(",")
                    }
                })
                .collect();
            tests.push(test_names.join(", "));
        }
    }

    let schema = Arc::new(Schema::new(vec![
        Field::new("table_name", DataType::Utf8, false),
        Field::new("column_name", DataType::Utf8, false),
        Field::new("data_type", DataType::Utf8, true),
        Field::new("description", DataType::Utf8, true),
        Field::new("tests", DataType::Utf8, true),
    ]));

    let batch = RecordBatch::try_new(
        schema.clone(),
        vec![
            Arc::new(StringArray::from(table_names)) as ArrayRef,
            Arc::new(StringArray::from(column_names)) as ArrayRef,
            Arc::new(StringArray::from(data_types)) as ArrayRef,
            Arc::new(StringArray::from(descriptions)) as ArrayRef,
            Arc::new(StringArray::from(tests)) as ArrayRef,
        ],
    )?;

    let table = MemTable::try_new(schema, vec![vec![batch]])?;
    let _ = ctx.deregister_table("airform_columns");
    ctx.register_table("airform_columns", Arc::new(table))?;
    Ok(())
}

fn register_table_lineage_table(
    ctx: &SessionContext,
    manifest: &Manifest,
    _graph: &DbtGraph,
) -> anyhow::Result<()> {
    let mut source_nodes = Vec::new();
    let mut target_nodes = Vec::new();
    let mut is_direct = Vec::new();

    for (_id, node) in &manifest.nodes {
        let deps = match node {
            ManifestNode::Model(m) => Some(&m.depends_on),
            ManifestNode::Test(t) => Some(&t.depends_on),
            ManifestNode::Snapshot(s) => Some(&s.depends_on),
            _ => None,
        };
        if let Some(deps) = deps {
            for ref_call in &deps.refs {
                if let Some(target) = manifest.resolve_ref(
                    &ref_call.model_name,
                    ref_call.package.as_deref(),
                ) {
                    source_nodes.push(target.name().to_string());
                    target_nodes.push(node.name().to_string());
                    is_direct.push("true".to_string());
                }
            }
            for source_call in &deps.sources {
                source_nodes.push(format!(
                    "{}.{}",
                    source_call.source_name, source_call.table_name
                ));
                target_nodes.push(node.name().to_string());
                is_direct.push("true".to_string());
            }
        }
    }

    let schema = Arc::new(Schema::new(vec![
        Field::new("source_node", DataType::Utf8, false),
        Field::new("target_node", DataType::Utf8, false),
        Field::new("is_direct", DataType::Utf8, false),
    ]));

    let batch = RecordBatch::try_new(
        schema.clone(),
        vec![
            Arc::new(StringArray::from(source_nodes)) as ArrayRef,
            Arc::new(StringArray::from(target_nodes)) as ArrayRef,
            Arc::new(StringArray::from(is_direct)) as ArrayRef,
        ],
    )?;

    let table = MemTable::try_new(schema, vec![vec![batch]])?;
    let _ = ctx.deregister_table("airform_table_lineage");
    ctx.register_table(
        "airform_table_lineage",
        Arc::new(table),
    )?;
    Ok(())
}

fn register_column_lineage_table(
    ctx: &SessionContext,
    manifest: &Manifest,
) -> anyhow::Result<()> {
    let col_lineage = build_column_lineage(manifest);

    let mut source_nodes = Vec::new();
    let mut source_columns = Vec::new();
    let mut target_nodes = Vec::new();
    let mut target_columns = Vec::new();
    let mut dep_types = Vec::new();

    for edge in &col_lineage.edges {
        source_nodes.push(edge.source_node.clone());
        source_columns.push(edge.source_column.clone());
        target_nodes.push(edge.target_node.clone());
        target_columns.push(edge.target_column.clone());
        dep_types.push(edge.dependency_type.to_string());
    }

    let schema = Arc::new(Schema::new(vec![
        Field::new("source_node", DataType::Utf8, false),
        Field::new("source_column", DataType::Utf8, false),
        Field::new("target_node", DataType::Utf8, false),
        Field::new("target_column", DataType::Utf8, false),
        Field::new("dependency_type", DataType::Utf8, false),
    ]));

    let batch = RecordBatch::try_new(
        schema.clone(),
        vec![
            Arc::new(StringArray::from(source_nodes)) as ArrayRef,
            Arc::new(StringArray::from(source_columns)) as ArrayRef,
            Arc::new(StringArray::from(target_nodes)) as ArrayRef,
            Arc::new(StringArray::from(target_columns)) as ArrayRef,
            Arc::new(StringArray::from(dep_types)) as ArrayRef,
        ],
    )?;

    let table = MemTable::try_new(schema, vec![vec![batch]])?;
    let _ = ctx.deregister_table("airform_column_lineage");
    ctx.register_table(
        "airform_column_lineage",
        Arc::new(table),
    )?;
    Ok(())
}
