# This file brings it all togehter and outputs to data folder

details <- readr::read_csv("data-raw/20230614-gov-uk-evaluations_details.csv")
docs <- readr::read_csv("data-raw/20230614-keyword-match.csv")
doc_links <- readr::read_csv("data-raw/20230614-gov-uk-evaluation-doc-links.csv")
keyword_match <- readr::read_csv("data-raw/20230614-keyword-match.csv") 
keywords <- readLines("data-raw/keywords.txt")

document_keywords <- details |>
  dplyr::select(updated, title, dept, link) |>
  dplyr::left_join(
    doc_links |>
      dplyr::left_join(
        keyword_match |>
          dplyr::select(documents, keywords),
        by = "documents"
      ),
    by = "link", relationship = "many-to-many"
  ) |>
  dplyr::arrange(dplyr::desc(updated))

link_keywords <- document_keywords |>
  dplyr::group_by(link) |>
  dplyr::reframe(keyword = stringr::str_split(keywords, ", ")) |>
  tidyr::unnest(keyword) |>
  dplyr::filter(!is.na(keyword)) |>
  dplyr::group_by(link) |>
  dplyr::summarise(keywords = paste(unique(keyword), collapse = ", ")) 

detail_keywords <- details |>
  dplyr::left_join(link_keywords, by = "link") |>
  dplyr::arrange(dplyr::desc(updated))

keywords <- dplyr::tibble(keywords = keywords)

write.csv(detail_keywords, "data/evaluation_detail_keywords.csv", row.names = FALSE)
write.csv(document_keywords, "data/evaluation_document_keywords.csv", row.names = FALSE)
write.csv(keywords, "data/keyword_lookup.csv", row.names = FALSE)

head(keyword_match)

