library(dplyr)

aggregate_gamelogs <- function(gamelogs_clean) {
  visitor <- gamelogs_clean |>
    transmute(
      season,
      game_date,
      team = v_team,
      league = v_league,
      runs_scored = v_score,
      runs_allowed = h_score,
      off_outs = as.integer(h_po), # outs recorded against visiting batters
      def_outs = as.integer(v_po), # outs recorded by visiting pitchers
      win = as.integer(v_score > h_score)
    )

  home <- gamelogs_clean |>
    transmute(
      season,
      game_date,
      team = h_team,
      league = h_league,
      runs_scored = h_score,
      runs_allowed = v_score,
      off_outs = as.integer(v_po), # outs recorded against home batters
      def_outs = as.integer(h_po), # outs recorded by home pitchers
      win = as.integer(h_score > v_score)
    )

  bind_rows(visitor, home) |>
    group_by(season, team, league) |>
    summarise(
      games = n(),
      wins = sum(win),
      losses = games - wins,
      off_outs = sum(off_outs),
      def_outs = sum(def_outs),
      win_pct = wins / games,
      runs_scored = sum(runs_scored),
      runs_allowed = sum(runs_allowed),
      runs_scored_per_9 = runs_scored / off_outs * 27,
      runs_allowed_per_9 = runs_allowed / def_outs * 27,
      rpg_9 = runs_scored_per_9 + runs_allowed_per_9,
      rpg = (runs_scored + runs_allowed) / games,
      .groups = "drop"
    )
}
