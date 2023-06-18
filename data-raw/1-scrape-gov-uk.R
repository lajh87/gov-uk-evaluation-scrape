# TODO note RDS files are moved to onedrive
# https://www.gov.uk/search/all?keywords=evaluation&content_purpose_supergroup%5B%5D=research_and_statistics&order=relevance
# Date 17 June 23
base <- "https://www.gov.uk/"
pages <- 1:192

## Extract List of Evaluations and There Associated Links ----
evaluations <- purrr::map_df(cli::cli_progress_along(pages), function(i){

  req <- httr::GET(base, path = "search/all.atom", 
                   query = list(content_purpose_supergroup = "research_and_statistics",
                                keywords = "evaluation",
                                order = "relevance",
                                page = i ))
  
  
  httr::content(req, type = "text/xml", encoding = "UTF-8")
  
  xml <- xml2::read_xml(req) 
  #xml2::xml_ns(xml)
  xml2::xml_find_all(xml, "//d1:entry") |>
    purrr::map(function(x){
      updated <-  xml2::xml_text(xml2::xml_child(x, 2))
      link <- xml2::xml_attr(xml2::xml_child(x,3), "href")
      title <- xml2::xml_text(xml2::xml_child(x,4))
      summary <- xml2::xml_text(xml2::xml_child(x,5))
      tibble::tibble(link, updated, title, summary)
      
    })  
})

write.csv(evaluations, "data-raw/20230614-gov-uk-evaluations.csv", row.names = FALSE)

#' Extract the main section from each evaluation webpage ----
#' This takes a few minutes
content_data <-  purrr::map(cli::cli_progress_along(1:nrow(evaluations)),
                                    function(i){
                                      
                                      link <- evaluations$link[i]
  req <- httr::GET(link)
  
  out <- req |>
    httr::content() |>
    xml2::xml_find_all("//main")
  
  out_s <- xml2::xml_serialize(out, NULL)
  
  list(link, out_s)
  
})

saveRDS(content_data, file = "data-raw/20230614-Gov-UK-Eval-Content.RDS")

                