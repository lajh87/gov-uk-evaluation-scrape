library(shiny)

df <- readr::read_csv("data-raw/20230614-gov-uk-evaluations_details.csv")
docs <- readr::read_csv("data-raw/20230614-gov-uk-evaluation-doc-links.csv")
keywords <- readr::read_csv("data-raw/20230614-keyword-match.csv")

docs <- docs |>
  dplyr::left_join(keywords |> dplyr::select(documents, keywords))


ui <- fluidPage(
  helpText(glue::glue(
    "The table shows the results of a 'web-scrape' of the gov.uk website",
    "carried out on 16 June 23",
    "for the keyword 'evaluation' and content purpose 'research_and_statistics'.", 
    .sep = " "
  )),
  tabsetPanel(
    tabPanel("Summary", DT::dataTableOutput("table")),
    tabPanel("Documents", DT::dataTableOutput("documents"))
  )
)

server <- function(input, output, session) {
  output$table <- DT::renderDataTable(
    df |> dplyr::mutate(title = glue::glue("<a href = '{link}' target = '_blank'>{title}</a>")) |>
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
    df |>
      dplyr::select(updated, link, title, dept) |>
      dplyr::distinct(updated, link, title, .keep_all = TRUE) |>
       dplyr::mutate(title = glue::glue("<a href = '{link}' target = '_blank'>{title}</a>")) |>
      dplyr::left_join(docs, by = "link", relationship = "many-to-many") |>
      dplyr::select(-link) |>
      dplyr::mutate(documents = glue::glue("<a href = '{documents}' target = '_blank'>{basename(documents)}</a>")) |>
      dplyr::rename(document = documents),
    filter = "top",
    escape = FALSE,
    selection = "single",
    options = list(
      searchCols = list(NULL,NULL, list(search = 'impact evaluation'))
    )
    
  )
}

shinyApp(ui, server)