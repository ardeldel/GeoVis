
server <- function(input, output, session) {

USER<- reactiveValues(logged=FALSE, role="", email="", password="", register="FALSE")

labelMandatory<- function(label){
  tagList(
    label,
    span("*", class="red-font")
  )
}

##### Register Controller ####
observeEvent(input$registerBtn,{
  USER$register<- TRUE
  output$body_UI<- renderUI({
            fluidRow(
              column(width = 4),
              column(width = 8,
                box(
                title = "Register", status = "success", solidHeader = TRUE,
                textInput("fullname", labelMandatory("Full Name")),
                textInput("email", labelMandatory("Email")),
                passwordInput("password", labelMandatory("Password")),
                passwordInput("passwordConfirmation", labelMandatory("Confirmation Password")),
                shinyjs::hidden(div(id="mandatoryConf", class="red-font", textOutput("validation"))),
                div(class="centerButton",
                  actionButton(inputId="registerData", label="Register", class = "btn-success whitefont")
                  ),
                div(class="centerButton",
                  h6("Already registered?")
                  ),
                div(class="centerButton",
                  actionButton(inputId="loginBack", label="Login", class = "btn-primary btn-sm whitefont")
                  )

                )
              )
            )  
          })

  })

observeEvent(input$registerData,{
  db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
  registeredEmail<- dbGetQuery(db, paste0("select * from users where email='", input$email, "'"))
  
  if(nchar(input$fullname)==0){
    output$validation<- renderText({"Full name must be filled"})
    shinyjs::show(id="mandatoryConf")
  }else if(nchar(input$email)==0){
    output$validation<- renderText({"Email must be filled"})
    shinyjs::show(id="mandatoryConf")
  }else if(nrow(registeredEmail)==1){
    output$validation<- renderText({"Email has been registered"})
    shinyjs::show(id="mandatoryConf")
  }else if(nchar(input$password)==0){
    output$validation<- renderText({"Password must be filled"})
    shinyjs::show(id="mandatoryConf")
  }else if(input$password != input$passwordConfirmation){
    output$validation<- renderText({"Password and Confirmation Password do not match"})
    shinyjs::show(id="mandatoryConf")
  }else{
    USER$fullname<- isolate(input$fullname)
    USER$email<- isolate(input$email)
    USER$password<- password_store(isolate(input$password))
    ## addUSer
    register_user<- dbSendQuery(db, paste0("INSERT INTO users(fullname, email, password, role) VALUES ('", 
      USER$fullname ,"', '", USER$email ,"', '", USER$password, "', 'user')"))
    
    sendSweetAlert(
      session = session,
      title = "Success !!",
      text = "You have been registered",
      type = "success"
    )
    USER$register<- FALSE
  }
  dbDisconnect(db)
  
})


observeEvent(input$loginBack,{
    USER$register<- FALSE
  })

##### Login Controller ####
observeEvent(input$login,{
  USER$email<- isolate(input$email)
  USER$password<- isolate(input$password)
  db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
  # user<- dbGetQuery(db, paste0("select * from users where email='", USER$email,
  #   "' and password='", USER$password, "'"))
  user<- dbGetQuery(db, paste0("select * from users where email='", USER$email,"'"))
  dbDisconnect(db)
  if(USER$register==FALSE){
    if(nchar(USER$email)== 0 & nchar(USER$password) == 0){
      shinyjs::show(id="mandatory")
    }else if(nrow(user)==1 && password_verify(user$password,USER$password)){
      ##login()
      USER$logged<- TRUE
      USER$role<- user$role
      USER$fullname<- user$fullname
      USER$id<- user$userID

    }else if(nrow(user)!=1 || (nrow(user)==1 && password_verify(user$password,USER$password)==FALSE)){
          sendSweetAlert(
            session = session,
            title = "Oops !!",
            text = "Incorrect email or password",
            type = "error"
          )
          
      }
  }

  })

  ##### Login UI Controller ####
  observe({
      if(USER$logged==FALSE & USER$register== FALSE){
          # js$hidehead('none')
          shinyjs::runjs("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'hidden';") 
          shinyjs::addClass(selector = "body", class = "sidebar-collapse")
          output$body_UI<- renderUI({
            fluidRow(
              column(width = 4),
              column(width = 8,
                box(
                title = "Login", status = "primary", solidHeader = TRUE,
                textInput("email", tagList(icon("user"),labelMandatory("Email"))),
                passwordInput("password", tagList(icon("unlock-alt"), labelMandatory("Password:"))),
                shinyjs::hidden(div(id="mandatory", class="red-font", h6("Please fill email and password"))),
                div(class="centerButton",
                  actionButton(inputId="login", label="Login", class = "btn-primary whitefont btnOther")
                  ),
                div(class="centerButton",
                  h6("First time?")
                  ),
                div(class="centerButton",
                  actionButton(inputId="registerBtn", label="Register", class = "btn-success btn-sm whitefont")
                  )

                )
              )
            )  
          })
      }else if(USER$logged==TRUE){
        shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
        shinyjs::runjs("document.getElementsByClassName('sidebar-toggle')[0].style.visibility = 'visible';") 

        # UI Controller
        output$sideBar_menu_UI <- renderMenu({
          sidebarMenu(
            id="tabs",
            menuItem("Home", tabName = "home", icon = icon("home")),
            menuItem("Upload Data", tabName = "upload_data", icon = icon("file-upload")),
            menuItem("Upload History", tabName = "upload_history", icon = icon("history")),
            menuItem("Visualization", tabName = "graphics", icon = icon("globe-americas")),
            menuItem("Model", tabName = "model", icon = icon("chart-line")),
            menuItemOutput("menuAdmin"),
            menuItem("About", tabName = "about", icon = icon("info-circle")),
            menuItem("Log out", tabName = "Logout", icon = icon("sign-out-alt"))
            
          )
        }) 

        output$body_UI <- renderUI ({
          tabItems(
            tabItem(tabName = "home", selected=TRUE,
                    source("home.R", local=TRUE)$value
            ),
            tabItem(tabName = "upload_data",
                    source("upload_data.R", local=TRUE)$value
            ),
            tabItem(tabName = "upload_history",
                    source("upload_history.R", local=TRUE)$value
            ),
            tabItem(tabName = "graphics",
              source("graphics.R", local=TRUE)$value
            ),
            tabItem(tabName = "model",
                    source("model.R", local=TRUE)$value
            ),
            tabItem(tabName = "admin",
                    source("admin.R", local=TRUE)$value
            ),
            tabItem(tabName = "about",
                    source("about.R", local=TRUE)$value
            )
        
          )

          })

        db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
        dataset<- dbGetQuery(db, paste0("select * from datasets where userID='", USER$id,"'"))
        dbDisconnect(db)
        source("updateDataInput.R", local=TRUE)$value 

        # output$colnames<- renderText({
        #   dataName<- isolate(input$dataDisplay)
        #   db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
        #   dataset<- dbGetQuery(db, paste0("select * from users u join datasets d on u.userID=d.userID ", 
        #     "join columns c on d.datasetID=c.datasetID where u.userID='", 
        #     USER$id,"' and d.datasetName='", dataName ,".csv'"))
        #   dbDisconnect(db)
        #   dataset$columnName
        #   })
        
        source("list_history.R", local=TRUE)$value 
        output$summary_home<- NULL


      }
      
  })
  
  


  observeEvent(input$dataDisplay,{
    req(input$dataDisplay)
    if(input$dataDisplay != ""){
      dataName<- isolate(input$dataDisplay)
      df<- read.csv(paste0("data/", USER$id,"/", dataName, ".csv"))
      hide(id="div_no_data")

      updateSelectInput(
            session,
            inputId="varDisplay",
            choices= sub(".csv", "", colnames(df)[which(lapply(df, class)%in% c("integer", "numeric"))[-1]])
            )

      

      output$dashboard_home <- renderUI({
        tagList(
          box(
            title=paste0("Top 5 ", input$varDisplay),
            width=7,
            status = "primary", 
            solidHeader = FALSE,
            collapsible = FALSE,
            plotOutput("top", height="300")
            )

          )
        })

      
      observeEvent(input$varDisplay,{
        req(input$varDisplay)
        output$top<- renderPlot({
        data<- head(df[order(df[,input$varDisplay], decreasing =T),], n=5)
        ggplot(data=data, 
               aes(x=reorder(data[,2], data[,input$varDisplay]), y=data[,input$varDisplay], fill=data[,input$varDisplay])) +
          geom_bar(stat="identity") +
          geom_text(aes(label=round(data[,input$varDisplay], digits=3)), vjust=0.5, hjust=-0.1) + 
          theme(axis.title.y = element_blank(), axis.title.x = element_blank())+
          scale_fill_gradient(low = "red", high = "blue")+
          coord_flip(ylim = c(0,max(data[,input$varDisplay])+max(data[,input$varDisplay])/5))+
          theme(axis.text = element_text(size = 12), legend.position = "none")
        })

        output$summary_home <- renderUI({        
        tagList(
              box(title=tagList(tags$p(round(min(df[,input$varDisplay]), digits=2), style = "font-size: 80%;"),
                     tags$p("Min", style = "font-size: 70%;")),     
                     width = 12, 
                     height=50,
                     background = "red"
              ),
              box(title= tagList(tags$p(round(mean(df[,input$varDisplay]), digits=2), style = "font-size: 80%;"),
                     tags$p("Mean", style = "font-size: 70%;")),     
                     width = 12, 
                     height=50,
                     background = "green"
              ),
              box(title=tagList(tags$p(round(max(df[,input$varDisplay]), digits=2), style = "font-size: 80%;"),
                     tags$p("Max", style = "font-size: 70%;")),     
                     width = 12, 
                     height=50,
                     background = "blue"
              )
            )

        })



        })
      

    }
    
    })

  observeEvent(input$tabs, {
    if(input$tabs=="Logout"){
      confirmSweetAlert(
      session = session,
      inputId = "logoutConfirmation",
      type = "warning",
      title = "Are you sure to log out?",
      danger_mode = TRUE
    )
    }

    })

  ##### Logout Controller ####

  observeEvent(input$logoutConfirmation, {
    if (isTRUE(input$logoutConfirmation)) {
      USER$logged<- FALSE
      shinyjs::hide(id="mapviewBox")
      output$top<- NULL
      output$summary_home<- NULL
      reset("dataDisplay")
      reset("varDisplay")
    } else {
      USER$logged<- TRUE
    }
  }, ignoreNULL = TRUE)


  observe({
      if(USER$role=="admin"){
       output$menuAdmin<- renderMenu({
      menuItem("Admin", tabName = "admin", icon = icon("user-cog"))
      })
    }else {
        output$menuAdmin<- NULL
       }
    })

  

  output$titlePanel<- renderText({paste0("Welcome, ",USER$fullname, "!")})

  
  ## Input File Controller
  observeEvent(input$file1,{
    data <- reactiveValues()
    req(input$file1)
    inputFile<- input$file1
    
    ext <- tools::file_ext(inputFile$name)
    if(ext == "csv"){
      # output$separator<- renderUI({
      #   radioButtons("sep", "Separator",
      #              choices = c(Comma = ",",
      #                          Semicolon = ";",
      #                          Tab = "\t"),
      #              selected = ",")
      #   })
      # data$df <- read.csv(inputFile$datapath, sep=input$sep)
      data$df <- read.csv(inputFile$datapath)
    }else if(ext %in% c("xlsx", "xls")){
      data$df <- read_excel(inputFile$datapath, 1)
      updateSelectizeInput(
        session, 
        inputId="columns",
        choices = colnames(data$df),
        selected = colnames(data$df),
        server=TRUE
      )
    }

    updateSelectizeInput(
        session, 
        inputId="columns",
        choices = colnames(data$df),
        selected = colnames(data$df),
        server=TRUE
      )

    # observeEvent(input$sep,{
    #   data$df <- read.csv(inputFile$datapath, sep=input$sep)
    #   updateSelectizeInput(
    #     session, 
    #     inputId="columns",
    #     choices = colnames(data$df),
    #     selected = colnames(data$df),
    #     server=TRUE
    #   )
    #   })

    shinyjs::show(id="dataBox")

    

    updateTextInput(
      session, 
      inputId="dataName",
      value = if(sub(".csv", "", inputFile$name)==inputFile$name){
          sub(".xlsx", "", inputFile$name)
        }else{
          sub(".csv", "", inputFile$name)
        }
      )
    
    
    observeEvent(input$columns, {
      output$contents <- DT::renderDataTable(
          options = list(
            scrollX = TRUE, 
            pageLength = 5,
            lengthMenu = c(5, 10, 30, 50)
            ),
          selection = 'none',{  
            if(! tools::file_ext(inputFile$name) %in% c("csv","xls","xlsx")){
              output$uploadValidation<- renderText({"Please choose CSV or XLSX file"})
              shinyjs::show(id="uploadVal")
              return(NULL)
            }else{
              return_data<- as.data.frame(data$df[,input$columns]) 
              colnames(return_data)<- input$columns
              return(return_data)
            }
              

          })
      })
   

    shinyjs::hide(id="uploadVal")

    })


  

  #### Upload Controller ####
  observeEvent(input$upload,{
    
    db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
    q<- paste0("SELECT * FROM datasets WHERE userID='", USER$id, "' and datasetName='", input$dataName  ,".csv'")
    datasetSameName<- dbGetQuery(db, q)
    # req(input$file1)
    dbDisconnect(db)

    if (is.null(input$file1)) {
      sendSweetAlert(
        session = session,
        title = "File not selected !!",
        type = "error"
      )
    }else if(input$dataName == "" | length(input$columns)==0){
      output$uploadValidation<- renderText({"Please fill all fields"})
      shinyjs::show(id="uploadVal")
    }else if(nrow(datasetSameName)==1){
      output$uploadValidation<- renderText({"This file name has been taken. Please try another name."})
      shinyjs::show(id="uploadVal")
    }else if(! tools::file_ext(input$file1$name) %in% c("csv","xls","xlsx")){
      output$uploadValidation<- renderText({"Please choose CSV or XLSX file"})
      shinyjs::show(id="uploadVal")
    }else{
      shinyjs::hide(id="uploadVal")
      if (!file.exists(paste0("data/",USER$id))){
        dir.create(file.path(paste0("data/",USER$id)))
      }
      ext <- tools::file_ext(input$file1$name)
      if(ext == "csv"){
        # df <- read.csv(input$file1$datapath, sep=input$sep)
        df <- read.csv(input$file1$datapath)
      }else if(ext %in% c("xlsx", "xls")){
        df <- read_excel(input$file1$datapath, 1)
      } 

      write.csv(df[,input$columns], file = paste0("data/",USER$id, "/",input$dataName,".csv"))
      db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
      q<- paste0("INSERT INTO datasets (userID, datasetName, dateUploaded)",
        " VALUES (", USER$id, ",'", input$dataName  ,".csv', '", Sys.time(),"')")
      
      insertDataset<- dbSendQuery(db, q)
      datasetID<- dbGetQuery(db, paste0("SELECT datasetID FROM datasets WHERE userID='", USER$id, 
        "' and datasetName='",input$dataName ,".csv'"))

      for(i in 1:length(input$columns)){
        q<- paste0("INSERT INTO columns(datasetID,columnName) VALUES (", datasetID ,", '", input$columns[i] ,"')")
        insertColumns<- dbSendQuery(db, q)
      }

      dbDisconnect(db)

      sendSweetAlert(
        session = session,
        title = "Success !!",
        text = "Data uploaded",
        type = "success"
      )
      shinyjs::reset("file1")
      shinyjs::reset("dataName")
      shinyjs::reset("columns")
      shinyjs::reset("upload")
      updateSelectizeInput(
        session, 
        inputId="columns",
        choices = "",
        server=FALSE
      )

      
      # sub("\\..*" --> get until last . sub(.csv) --> get until .csv
      source("updateDataInput.R", local=TRUE)$value 

      shinyjs::hide(id="dataBox")
      shinyjs::runjs("window.scrollTo(0,0)")
      
      source("fileUploadBox.R", local=TRUE)$value 
      source("list_history.R", local=TRUE)$value 
      
    }

    })

  source("fileUploadBox.R", local=TRUE)$value 
  

  output$modelCreatedBox <- renderValueBox({
    db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
    model<- dbGetQuery(db, 
      paste0("select * from users u join datasets d on u.userID=d.userID ", 
        "join models m on d.datasetID=m.datasetID where u.userID='", 
        USER$id,"'"))
    dbDisconnect(db)
    valueBox(
      paste0(nrow(model)), "Model Created", icon = icon("chart-line"),
      color = "yellow"
    )
  })

  
  # Graphics Controller
  observeEvent(input$showGraphics,{
      dataName<- isolate(input$dataGraphics)
      varname<- isolate(input$varGraphics)
      df<- read.csv(paste0("data/", USER$id,"/", dataName, ".csv"))
      df <- merge(ind, df, by.x='KabKota', by.y = colnames(df)[2])
      # cat("deleting NA\n")
      idx<- which(is.na(df@data[,6]))
      df<- df[-idx,]
      rm(idx)
      rownames(df@data)<- NULL
      if(nrow(df)!=0){
        shinyjs::hide(id="graphicsConf")
        shinyjs::show(id="mapviewBox")
        # cat("df merged\n")
        shinyjs::runjs("window.scrollTo(0,document.body.scrollHeight+5)")
        m<- mapview(df, zcol=varname)
        # cat("m created\n")
        output$mapplot<- leaflet::renderLeaflet({
          m@map
          })
        # cat("m@map rendered\n")
      }else{
        output$validationGraphics<- renderText({"No data to map"})
        shinyjs::show(id="graphicsConf")
      }

      
    })

  #Download list of location
  output$location_list <- downloadHandler(
    filename = function() {
      paste('location.csv', sep='')
    },
    content = function(file) {
      data<- read.csv("location.csv")
      write.csv(data, file)
    }
  )

  #Download sample data
  output$sample_data <- downloadHandler(
    filename = function() {
      paste('data_sample.csv', sep='')
    },
    content = function(file) {
      data<- read.csv("data_sample.csv")
      write.csv(data, file, row.names=FALSE)
    }
  )

   
   observeEvent(input$dataGraphics, {
    if(input$dataGraphics != ""){
      dataName<- isolate(input$dataGraphics)
      df<- read.csv(paste0("data/", USER$id,"/", dataName, ".csv"))
      ### FROM 2 BECAUSE index 1 is number of obs (-1 bcs index 1 is no of obs)
      idx<- which(sapply(df, class) == "numeric" | sapply(df, class) == "integer")[-1]
      updateSelectizeInput(
            session, 
            inputId="varGraphics",
            choices = colnames(df)[idx],
            server=FALSE
          )
    }

    })

   source("model_controller.R", local=TRUE)$value


   output$list_user <- DT::renderDataTable({
    db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
    user<- dbGetQuery(db, "select userID, fullname, email, role from users")
    dbDisconnect(db)
    user  
    })




}
