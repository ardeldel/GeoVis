fluidPage(
  titlePanel("Admin"),
  box(
    title = "User", 
    status = "primary", 
    width=12,
    solidHeader = TRUE,
    DT::dataTableOutput("list_user")%>% withSpinner(color="#0dc5c1")
  )
  
)
