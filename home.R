
fluidPage(
  # Application title
  titlePanel(textOutput("titlePanel")),
  box(
    # id="about",
    title= tags$p(id="about", "GeoVis", style = "font-size: 125%;", class="boxTitle-bottom"),
    status = "primary", 
    solidHeader = FALSE,
    collapsible = TRUE,
    width=12,
    background = "light-blue",
    p("A web based application to perform Geographically Weighted Regression (GWR) model. 
      After uploading your data, you can visualize your data on Visualization Tab and perform GWR on Model Tab")
  
  ),
  # Dynamic valueBoxes
  box(title=tagList(tags$p("Steps", style = "font-size: 100%;"),
                     tags$p(icon("arrow-circle-right"), "Upload Data", style = "font-size: 80%;"),
                     tags$p(icon("arrow-circle-right"),"Visualization (Optional)", style = "font-size: 80%;"),     
                     tags$p(icon("arrow-circle-right"),"Create Model", style = "font-size: 80%;")),          
                     width = 4, 
                     height=100,
                     background = "green"
              ),
  valueBoxOutput("fileUploadBox"),
  valueBoxOutput("modelCreatedBox"),

  box(
    title = "Data Summary", 
    status = "primary", 
    solidHeader = TRUE,
    collapsible = FALSE,
    width=5,

    selectInput(
      inputId="dataDisplay",
      label="Data",
      choices=""
      ),
    selectInput(
      inputId="varDisplay",
      label="Variable",
      choices=""
      ),
    
    helpText(id="div_no_data", "No data uploaded yet use sample data ", 
      downloadLink(outputId="sample_data", label="here")),

    uiOutput("summary_home")

  ),

  uiOutput("dashboard_home")
  
  
)




