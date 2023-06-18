#' This file loads the raw data, extracts the text and converts it to sentences.
#' It then extracts keywords from the sentences if they exist.
#' This script takes about 40 minutes to run.

doc_links <- readr::read_csv("data-raw/20230614-gov-uk-evaluation-doc-links.csv") |>
  dplyr::filter(stringr::str_detect(documents, "gov.uk")) |>
  dplyr::pull(documents)

keywords <- readLines("data-raw/keywords.txt")
search_ <- keywords |> paste(collapse="|")

files <- list.files("data-raw", pattern = "docs-")

keyword_match <- purrr::map_df(cli::cli_progress_along(files), function(i){
  rds <- files[i]
  raw <- readRDS(file.path("data-raw", rds))
  
  text <- purrr::map_df(raw, ~{
    if(.x[[2]] == "application/pdf"){
      text <- pdftools::pdf_text(.x[[3]]) |> paste(collapse = "\n")
    } else{
      if(stringr::str_detect(.x[[2]], "text/html")){
        text <-  xml2::read_html(.x[[3]]) |> xml2::xml_text()
      } else text <- NA
    }
    dplyr::tibble(id = .x[[1]], content_type = .x[[2]], text)
  })
  
  sentences <- text |>
    dplyr::filter(!is.na(text)) |>
    tidytext::unnest_sentences("sentence", text, TRUE) 
  
  sentences |>
    dplyr::mutate(keywords = stringr::str_extract_all(sentence, search_)) |>
    tidyr::unnest("keywords") |> 
    dplyr::group_by(id) |>
    dplyr::summarise(paste(unique(keywords), collapse = ", ")) |>
    dplyr::ungroup() |>
    dplyr::mutate(source = rds)
})

keyword_match |>
  dplyr::mutate(doc_id =  substr(source, 6, 10)) 

keyword_match2 <- keyword_match |>
  dplyr::mutate(doc_id =  as.numeric(substr(source, 6, 10)) + id - 1) |>
  dplyr::left_join(
    dplyr::tibble(documents = doc_links) |>
      dplyr::mutate(doc_id = 1:dplyr::n()),
    by = "doc_id"
  ) |>
  dplyr::rename(keywords = 2)


write.csv(keyword_match2, "data-raw/20230614-keyword-match.csv", row.names = FALSE)
