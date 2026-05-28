library(rvest)
library(httr)
library(stringr)
library(purrr)

fetch_gamelogs <- function(year_range, dest_dir) {
  base_url <- "https://www.retrosheet.org/gamelogs/"
  index_url <- paste0(base_url, "index.html")
  dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

  # Scrape index
  page <- read_html(index_url)
  links <- page |>
    html_elements("a") |>
    html_attr("href")

  # Filter to gamelog zips for the requested years
  zip_links <- links[str_detect(links, "gl\\d{4}\\.zip$")]
  zip_links <- zip_links[str_detect(
    zip_links,
    paste(year_range, collapse = "|")
  )]
  zip_urls <- ifelse(
    str_starts(zip_links, "http"),
    zip_links,
    paste0(base_url, zip_links)
  )

  cat("Found", length(zip_urls), "gamelog zips for requested years.\n")

  # Download
  walk(zip_urls, function(url) {
    zip_name <- basename(url)
    txt_name <- sub("\\.zip$", ".txt", zip_name)
    fname_txt <- file.path(dest_dir, txt_name)
    fname_zip <- file.path(dest_dir, zip_name)

    if (file.exists(fname_txt)) {
      cat("Already exists, skipping:", fname_txt, "\n")
      return(invisible(NULL))
    }
    cat("Downloading:", url, "\n")
    result <- tryCatch(
      GET(
        url,
        write_disk(fname_zip, overwrite = TRUE),
        user_agent("Mozilla/5.0"),
        timeout(60)
      ),
      error = function(e) {
        cat("  ERROR:", conditionMessage(e), "\n")
        NULL
      }
    )
    if (!is.null(result) && status_code(result) == 200) {
      cat("  Saved to:", fname_zip, "\n")
    } else {
      cat("  Failed with status:", status_code(result), "\n")
      file.remove(fname_zip)
    }
    Sys.sleep(1)
  })

  # Unzip
  zip_files <- list.files(
    dest_dir,
    pattern = "gl\\d{4}\\.zip$",
    full.names = TRUE
  )
  walk(zip_files, function(zf) {
    cat("Unzipping:", zf, "\n")
    unzip(zf, exdir = dest_dir)
  })

  # Delete zip files after unzipping
  walk(zip_files, function(zf) {
    cat("Deleting:", zf, "\n")
    file.remove(zf)
  })

  # Return paths to the extracted .TXT files so targets can track them
  list.files(
    dest_dir,
    pattern = paste0("gl(", paste(year_range, collapse = "|"), ")\\.txt$"),
    full.names = TRUE
  )
}
