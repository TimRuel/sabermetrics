library(targets)
library(tarchetypes)
library(here)

# Source all functions in R/
tar_source("R")

list(
  # Config — change year_range here and targets reruns only what's affected
  tar_target(year_range, 2010:2025),
  tar_target(dest_dir, here("data", "retrosheet_gamelogs")),

  # Download and unzip gamelogs; tracks the returned file paths
  tar_target(
    gamelog_files,
    fetch_gamelogs(year_range, dest_dir),
    format = "file"
  ),

  tar_target(
    gamelogs_raw,
    parse_gamelogs(gamelog_files)
  ),

  tar_target(
    gamelogs_clean,
    clean_gamelogs(gamelogs_raw)
  ),

  tar_target(
    gamelogs_agg,
    aggregate_gamelogs(gamelogs_clean)
  ),

  tar_target(
    pythagenpat_fit,
    estimate_pythagenpat(gamelogs_agg)
  )

  # tar_quarto(
  #   report,
  #   "pythagenpat_analysis.qmd"
  # )
)
