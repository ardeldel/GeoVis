ui<- dashboardPage(
  dashboardHeader(title = "GeoVis"),
  dashboardSidebar(sidebarMenuOutput("sideBar_menu_UI")),
  dashboardBody(
    uiOutput("body_UI"),
    shinyjs::useShinyjs(),
    useShinyalert(),
    tags$head(
                tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
              ),
    
    tags$script(HTML("$(document).on('click', '.historyBtn', function () {
      Shiny.setInputValue('lastClickId',this.id);
      Shiny.setInputValue('lastClick', Math.random())
      });")),
    tags$script(HTML("$(document).on('click', '.btnOther', function () {
      Shiny.setInputValue('lastClickId','0');
      Shiny.setInputValue('lastClick', '0')
      });"))


  )
)

