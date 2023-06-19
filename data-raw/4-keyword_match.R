#' This file loads the raw data, extracts the text and converts it to sentences.
#' It then extracts keywords from the sentences if they exist.
#' This script takes about 40 minutes to run.

keywords <- readLines("data-raw/keywords.txt")
search_ <- keywords |> paste(collapse="|")

files <- list.files("data-raw", pattern = "docs-")

keyword_match <- purrr::map_df(cli::cli_progress_along(files), function(i){
  rds <- files[i]
  raw <- readRDS(file.path("data-raw", rds))

  text <- purrr::map_df(raw, ~{
    text <- tryCatch({
      if(.x[[2]] == "application/pdf"){
        suppressMessages(suppressWarnings(pdftools::pdf_text(.x[[3]]))) |> 
          paste(collapse = "\n")
      } else{
        if(stringr::str_detect(.x[[2]], "text/html")){
          xml2::read_html(.x[[3]]) |> xml2::xml_text()
        } else text <- NA
      }
    }, error = function(e) NA)
    
    dplyr::tibble(documents = .x[[1]], content_type = .x[[2]], text)
  })
  
  sentences <- text |>
    dplyr::filter(!is.na(text)) |>
    tidytext::unnest_sentences("sentence", text, TRUE) 
  
  sentences |>
    dplyr::mutate(keywords = stringr::str_extract_all(sentence, search_)) |>
    tidyr::unnest("keywords") |> 
    dplyr::group_by(documents) |>
    dplyr::summarise(keywords = paste(unique(keywords), collapse = ", ")) |>
    dplyr::ungroup() 
}) |>
  dplyr::distinct()

write.csv(keyword_match, "data-raw/20230614-keyword-match.csv", row.names = FALSE)
