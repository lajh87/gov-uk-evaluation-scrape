#' Download the Content from Files as Binary
#' 16 June 23
#' File Takes 1h + to load
doc_links <- readr::read_csv("data-raw/20230614-gov-uk-evaluation-doc-links.csv") |>
  dplyr::filter(stringr::str_detect(documents, "gov.uk")) |>
  dplyr::pull(documents) 

# First Tranche ----
raw <- lapply(cli::cli_progress_along(doc_links[1:1000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
  })

saveRDS(raw, "data-raw/docs-00001-01000.RDS")


# Second Tranche ----
raw <- lapply( cli::cli_progress_along(doc_links[1001:2000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-01001-02000.RDS")

# Third Tranche ----
raw <- lapply( cli::cli_progress_along(doc_links[2001:3000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-02001-03000.RDS")

# 4 -----
raw <- lapply( cli::cli_progress_along(doc_links[3001:4000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-03001-04000.RDS")


# 5 ----
raw <- lapply( cli::cli_progress_along(doc_links[4001:5000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-04001-05000.RDS")

# 6 ----
raw <- lapply( cli::cli_progress_along(doc_links[5001:6000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-05001-06000.RDS")

# 7 ----
raw <- lapply( cli::cli_progress_along(doc_links[6001:7000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-06001-07000.RDS")

# 8 -----
raw <- lapply( cli::cli_progress_along(doc_links[7001:8000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-07001-08000.RDS")

# 9 ----
raw <- lapply( cli::cli_progress_along(doc_links[8001:9000]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-08001-09000.RDS")


# 10 ----
raw <- lapply( cli::cli_progress_along(doc_links[9001:10214]), function(i) {
  if(i %% 50 == 0) Sys.sleep(1)
  tryCatch({
    req <- httr::GET(doc_links[i])
    content_type <- req$headers$`content-type`
    raw <- httr::content(req, as = "raw")
    list(i, content_type, raw)
  }, error = function(e) list(i, NA))
})

saveRDS(raw, "data-raw/docs-09001-010214.RDS")
