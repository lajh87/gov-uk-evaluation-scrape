evaluations <- readr::read_csv("data-raw/20230614-gov-uk-evaluations.csv")
content_data <- readRDS("data-raw/20230614-Gov-UK-Eval-Content.RDS")

webpage_data <- content_data |>
  purrr::map(~{
    # Document Link
    content <- xml2::xml_unserialize(.x[[2]])
    documents <- content |>
      xml2::xml_find_all("//section[@id='documents']//a") |>
      xml2::xml_attr("href") |> unique()
    
    details <- content |> 
      xml2::xml_find_all("//section[@id='details']") |>
      xml2::xml_text() |> stringr::str_remove_all("\n|Details") |> 
      stringr::str_trim()
    
    dept <- content |>
      xml2::xml_find_all("//dd//a[@class='govuk-link']") |>
      xml2::xml_text()
    
    
    list(link = .x[[1]], documents, details, dept)
    
  })

documents <- webpage_data |>
  purrr::map_df(function(x){
    tibble::tibble(documents = unlist(x[2]), link = unlist(x[1]))
  })

details <- webpage_data |>
  purrr::map_df(function(x){
    tibble::tibble(details = unlist(x[3]), dept = unlist(x[4]), link = unlist(x[1]))
  })

dplyr::left_join(evaluations, details, by = "link") |> 
  write.csv("data-raw/20230614-gov-uk-evaluations_details.csv", row.names = FALSE)

documents |>
  dplyr::filter(!stringr::str_detect(documents, "mailto")) |>
  dplyr::mutate(documents = ifelse(stringr::str_detect(documents, "^/government"), paste0("https://www.gov.uk", documents), documents)) |>
  dplyr::distinct(documents, .keep_all = TRUE) |>
  write.csv("data-raw/20230614-gov-uk-evaluation-doc-links.csv", row.names = FALSE)