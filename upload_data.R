fluidPage(
  titlePanel("Upload Data"),
  # Input: Select a file ----
  box(
    title = "Upload Data", 
    status = "primary", 
    width=12,
    solidHeader = TRUE,
    fileInput("file1", "Choose CSV/XLSX File",
              multiple = TRUE,
              accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv",
                         ".xlsx")
              ),
    uiOutput("separator"),
    textInput(
      inputId="dataName", 
      label="Data Name"
      ),

    
      # , 
      # style="color: red;"),
    selectizeInput(
      inputId="columns", 
      label= tagList("Column Names", 
        helpText("Please put location name or index in the first column as this will be used for modelling process")), 
      choices=colnames(data), 
      multiple=TRUE,
      options = list(
                   'plugins' = list('remove_button'),
                   'create' = TRUE,
                   'persist' = FALSE)
      ),
    
    shinyjs::hidden(div(id="uploadVal", class="red-font", textOutput("uploadValidation"))),
    div(
      class="centerButton",
          actionButton(
            inputId="upload", 
            label="Upload Data", 
            class = "btn-success whitefont btnOther"
            )
      )

  ),
  
  
  # Output: Data file ----
  shinyjs::hidden(div(id="dataBox",
    box(
    title = "Data Overview", status = "primary", solidHeader = TRUE,
    collapsible = FALSE,
    width=12,
    DT::dataTableOutput("contents")
    )
  )
  )
  
  
  
)
