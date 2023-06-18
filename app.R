library(shiny)

keywords <- readr::read_csv("data/keyword_lookup.csv")
details <- readr::read_csv("data/evaluation_detail_keywords.csv")
documents <- readr::read_csv("data/evaluation_document_keywords.csv")
repo <- "https://github.com/lajh87/gov-uk-evaluation-scrape"

ui <- fluidPage(
  helpText(glue::glue(
    "The table shows the results of a 'web-scrape' of the gov.uk website",
    "carried out on 16 June 23",
    "for the keyword 'evaluation' and content purpose 'research_and_statistics'.", 
    .sep = " "
  )),
  helpText(glue::glue(
    "The keywords are based on whether there is an exact match in any of the ",
    "character strings listed in the 'Keywords' tab.",
    .sep = " "
  )),
  helpText(HTML(glue::glue(
    "This source code can be found of <a href='{repo}' target = '_blank'>github.</a>"
  ))),
  tabsetPanel(
    tabPanel("Summary", DT::dataTableOutput("table")),
    tabPanel("Documents", DT::dataTableOutput("documents")),
    tabPanel("Keywords", DT::dataTableOutput("keywords"))
  )
)

server <- function(input, output, session) {
  output$table <- DT::renderDataTable(
    details |> dplyr::mutate(title = glue::glue("<a href = '{link}' target = '_blank'>{title}</a>")) |>
      dplyr::select(-link) |>
      dplyr::relocate(dept, .after = "title") |>
      dplyr::distinct(updated, title, .keep_all = TRUE) |>
      dplyr::mutate(dept = factor(dept)),
    filter = "top",
    escape = FALSE,
    selection = "single",
    options = list(
      searchCols = list(NULL, NULL, list(search = 'impact evaluation'))
      )
  )
  
  output$documents <- DT::renderDataTable(
    documents  |>
      dplyr::mutate(title = glue::glue("<a href = '{link}' target = '_blank'>{title}</a>")) |>
      dplyr::mutate(documents = glue::glue("<a href = '{documents}' target = '_blank'>{basename(documents)}</a>")) |>
      dplyr::rename(document = documents) |>
      dplyr::select(-link),
    filter = "top",
    escape = FALSE,
    selection = "single",
    options = list(
      searchCols = list(NULL,NULL, list(search = 'impact evaluation'))
    )
  )
  
  output$keywords <- DT::renderDataTable(keywords)
}

shinyApp(ui, server)