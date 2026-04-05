mod parse;
mod source_parser;
mod seed_parser;
mod snapshot_parser;

pub use parse::parse_models;
pub use source_parser::parse_sources;
pub use seed_parser::parse_seeds;
pub use snapshot_parser::parse_snapshots;

use airform_core::Manifest;
use airform_jinja::JinjaEngine;
use airform_loader::LoadState;

/// Parse all discovered files into a Manifest.
/// This is the "parse" phase: read SQL, extract refs/sources, build nodes.
pub fn parse(load_state: &LoadState, engine: &JinjaEngine) -> anyhow::Result<Manifest> {
    let mut manifest = Manifest::new();
    manifest.set_metadata(&load_state.project);

    // Parse sources from schema files first (models may reference them)
    parse_sources(&load_state.project, &load_state.schema_files, &mut manifest)?;

    // Parse seeds (models may reference them via ref())
    parse_seeds(
        &load_state.project,
        &load_state.seed_files,
        &load_state.schema_files,
        &mut manifest,
    )?;

    // Parse model SQL files
    parse_models(
        &load_state.project,
        &load_state.model_files,
        &load_state.schema_files,
        engine,
        &mut manifest,
    )?;

    // Parse snapshot SQL files
    parse_snapshots(
        &load_state.project,
        &load_state.snapshot_files,
        &load_state.schema_files,
        engine,
        &mut manifest,
    )?;

    Ok(manifest)
}
