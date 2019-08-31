fluidPage(
  titlePanel("Upload History"),
  box(
    title = "Upload History", 
    status = "primary", 
    width=12,
    solidHeader = TRUE,
    DT::dataTableOutput("list_history")%>% withSpinner(color="#0dc5c1")
    # ,
    # tags$script(HTML("$(document).on('click', '.historyBtn', function () {
    #   Shiny.setInputValue('lastClickId',this.id);
    #   Shiny.setInputValue('lastClick', Math.random())
    #   });"))

  ),
  
  
  # Output: Data file ----
  shinyjs::hidden(div(id="dataHistoryBox",
    box(
    title = "Data History Overview", status = "primary", solidHeader = TRUE,
    collapsible = FALSE,
    width=12,
    DT::dataTableOutput("contents_history")
    )
  )
  )
  
  
  
)
