
fluidPage(
  # Page title
  titlePanel("Model"),
  box(
    title = "Choose Data", 
    status = "primary", 
    width=12,
    solidHeader = TRUE,
    fluidRow(
      column(3, h5(tags$b("Data"))),
      column(9, 
        selectInput(
          inputId="dataModel",
          label=NULL,
          choices=""
          )
        )
      ),
    fluidRow(
      column(3, h5(tags$b("Dependent Variable"))),
      column(9, 
        selectInput(
          inputId="varDepModel",
          label=NULL,
          choices=""
          )
        )
      ),

    # fluidRow(
    #   column(3, h5(tags$b("Independent Variable"))),
    #   column(9, 
    #     selectInput(
    #       inputId="varIndepModel",
    #       label=NULL,
    #       choices="", 
    #       multiple=TRUE,
    #       options = list(
    #                    'plugins' = list('remove_button'),
    #                    'create' = TRUE,
    #                    'persist' = FALSE)
    #       )
    #     )
    #   ),

    selectizeInput(
      inputId="varIndepModel", 
      label="Independent Variable", 
      choices="", 
      multiple=TRUE,
      options = list(
                   'plugins' = list('remove_button'),
                   'create' = TRUE,
                   'persist' = FALSE)
      ),
    # checkboxInput( 
    #         inputId="cbshp",
    #         label = "Use embedded SHP (Indonesia Regencies only)"
    #       ),
    fluidRow(
      column(3, h5(tags$b("Longitude Variable"))),
      column(9, 
        selectInput(
          inputId="longitude",
          label=NULL,
          choices=""
          )
        )
      ),
    fluidRow(
      column(3, h5(tags$b("Latitude Variable"))),
      column(9, 
        selectInput(
          inputId="latitude",
          label=NULL,
          choices=""
          )
        )
      ),
    fluidRow(
      column(3, h5(tags$b("Significance Level"))),
      column(9, 
        numericInput(
          inputId="alpha",
          label=NULL,
          value=0.05,
          min= 0.01,
          max= 0.25,
          step=0.01
          )
        )
      ),
    
    div(
      class="centerButton",
          actionButton(
            inputId="runModel", 
            label="Run", 
            class = "btn-success whitefont"
            )
      )
    ),

  # Output: Result  ----
  shinyjs::hidden(div(id="model_result",
    box(
    title = "Result", status = "primary", solidHeader = TRUE,
    collapsible = FALSE,
    width=12,
    

    p("Global tests of geographical weighted regressions:"),
    verbatimTextOutput("gwrtest"),
    verbatimTextOutput("gwrtestInterpret"),
    br(),
    p("Choose location to view local GWR model"),
    fluidRow(
      column(3, h5(tags$b("Location"))),
      column(9, 
        selectInput(
          inputId="location",
          label=NULL,
          choices=""
          )
        )
      ),

    DT::dataTableOutput("model_table")%>% withSpinner(color="#0dc5c1")
    ,
    downloadButton(
      outputId="exportCSV", 
      label="Download Full Report", 
      class = "btn-primary whitefont"
      )
    )
  )
  )
  
  
)




