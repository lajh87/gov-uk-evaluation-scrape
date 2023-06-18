#' This file searches for keywords in documents and returns the document id and number of matches
#' 
keywords <- readLines("data-raw/keywords.txt")
files <- list.files("data-raw", pattern = "docs-")

keyword_match <- purrr::map_df(cli::cli_progress_along(files), function(i){
  rds <- files[i]
  content <- readRDS(file.path("data-raw", rds))
  
  # Extract text from pdf and html documents
  text <- purrr::map_df(content, ~{
    if(.x[[2]] == "application/pdf"){
      text <- pdftools::pdf_text(.x[[3]]) |> paste(collapse = "\n")
    } else{
      if(stringr::str_detect(.x[[2]], "text/html")){
        text <-  xml2::read_html(.x[[3]]) |> xml2::xml_text()
      } else text <- NA
    }
    dplyr::tibble(id = .x[[1]], content_type = .x[[2]], text)
  })
  
  # Extract Trigrams, Bigrams and Word lookup tables
  trigram <- text |>
    tidytext::unnest_ngrams(trigram, text, 3)
  bigram <- text |>
    tidytext::unnest_ngrams(bigram, text, 2)
  word <- text |>
    tidytext::unnest_tokens(word, text)
  
  # Match keyword to the lookup table and return location
  keyword_match <- purrr::map_df(keywords, ~{
    words <- (stringr::str_locate_all(.x, "\\s")[[1]] |> length())/2+1
    loc <- NULL
    if(words == 1){
      loc <- word |> dplyr::filter(stringr::str_detect(.x, word)) |> dplyr::pull(id)
    } else{
      if(words == 2){
        loc <- bigram |> dplyr::filter(stringr::str_detect(.x, bigram)) |> dplyr::pull(id)
      } else{
        loc <- trigram |> dplyr::filter(stringr::str_detect(.x, trigram)) |> dplyr::pull(id)
      }
    }
    if(!is.null(loc)){
      dplyr::tibble(source = rds, keyword = .x, doc.id = loc)
    } else{
      dplyr::tibble(source = rds, keyword = .x, doc.id = NA)
    }
  })
  
  keyword_match |>
    dplyr::group_by(source, keyword, doc.id) |>
    dplyr::count()
})

write.csv(keyword_match, "data-raw/keyword-match.csv", row.names = FALSE)


