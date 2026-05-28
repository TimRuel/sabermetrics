library(dplyr)

clean_gamelogs <- function(gamelogs_raw) {
  gamelogs_raw |>

    # Remove forfeits and suspended/completed games
    filter(is.na(forfeit) | forfeit == "") |>
    filter(is.na(completion) | completion == "") |>

    # Remove games with missing or implausible run totals
    filter(!is.na(v_score), !is.na(h_score)) |>
    filter(v_score >= 0, h_score >= 0) |>
    filter(!(v_score == 0 & h_score == 0)) |>

    # Remove duplicates
    distinct() |>

    # Coerce key numeric columns that weren't caught in parsing
    mutate(
      v_score = as.integer(v_score),
      h_score = as.integer(h_score),
      attendance = as.integer(attendance)
    )
}
