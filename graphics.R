fluidPage(
  titlePanel("Visualization"),
  box(
    title = "Select Data", 
    status = "primary", 
    width=12,
    solidHeader = TRUE,
    helpText("In order to use Visualization Menu, location name must be inline with regencies listed", 
    	downloadLink(outputId="location_list", label="here")),

    fluidRow(
    	column(2, h5(tags$b("Data"))),
    	column(10, 
    		selectInput(
		      inputId="dataGraphics",
		      label=NULL,
		      choices=""
		      )
    		)
    	),

    fluidRow(
    	column(2, h5(tags$b("Variable"))),
    	column(10, 
    		selectInput(
		      inputId="varGraphics",
		      label=NULL,
		      choices=""
		      )
    		)
    	),

	
	shinyjs::hidden(div(id="graphicsConf", class="red-font", textOutput("validationGraphics"))),
    
    div(
      class="centerButton",
          actionButton(
            inputId="showGraphics", 
            label="OK", 
            class = "btn-success whitefont"
            )
      )
  ),


# Output: Graphics file ----
  shinyjs::hidden(div(id="mapviewBox",
    box(
    title = "Map View", status = "primary", solidHeader = TRUE,
    collapsible = FALSE,
    width=12,
    leaflet::leafletOutput("mapplot")  %>% withSpinner(color="#0dc5c1")
    )
  )
  )


  
  
)
