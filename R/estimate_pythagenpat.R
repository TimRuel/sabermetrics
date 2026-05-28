library(dplyr)

estimate_pythagenpat <- function(gamelogs_agg) {
  fit_pythagenpat <- function(data, rpg_col, rs_col, ra_col) {
    rmse_fn <- function(z) {
      x <- data[[rpg_col]]^z
      win_pct_hat <- data[[rs_col]]^x / (data[[rs_col]]^x + data[[ra_col]]^x)
      sqrt(mean((data$win_pct - win_pct_hat)^2))
    }
    fit <- optim(
      par = 0.287,
      fn = rmse_fn,
      method = "Brent",
      lower = 0,
      upper = 1
    )
    list(z = fit$par, rmse = fit$value * 162)
  }

  df <- gamelogs_agg |>
    select(
      season,
      team,
      win_pct,
      runs_scored,
      runs_allowed,
      rpg,
      runs_scored_per_9,
      runs_allowed_per_9,
      rpg_9
    )

  standard <- fit_pythagenpat(
    df,
    "rpg",
    "runs_scored",
    "runs_allowed"
  )

  rate <- fit_pythagenpat(
    df,
    "rpg_9",
    "runs_scored_per_9",
    "runs_allowed_per_9"
  )

  list(
    standard = standard,
    rate = rate,
    data = df
  )
}
