# 
keyword_match <- readr::read_csv("data-raw/keyword-match.csv") 

keyword_match |> 
  dplyr::filter(doc.id == 1) |>
  View()

doc_link <- readr::read_csv("data-raw/20230614-gov-uk-evaluation-doc-links.csv") |>
  dplyr::mutate(doc.id = 1:dplyr::n(), .before = "documents")
evaluations <- readr::read_csv(("data-raw/20230614-gov-uk-evaluations_details.csv"))

evaluations |>
  dplyr::select(link, title) |>
  dplyr::left_join(doc_link, by = "link", relationship = "many-to-many")


head(keyword_match)
