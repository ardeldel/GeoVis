observeEvent(input$dataModel, {
    if(input$dataModel != ""){
      dataName<- isolate(input$dataModel)
      df<- read.csv(paste0("data/", USER$id,"/", dataName, ".csv"))
      
      ### FROM 2 BECAUSE index 1 is number of obs (-1 bcs index 1 is no of obs)
      idx<- which(sapply(df, class) == "numeric" | sapply(df, class) == "integer")[-1]
      
      updateSelectizeInput(
            session, 
            inputId="varDepModel",
            choices = colnames(df)[idx],
            server=FALSE
          )
      updateSelectizeInput(
        session, 
        inputId="varIndepModel",
        choices = colnames(df)[idx],
        selected = colnames(df)[idx],
        server=FALSE
      )
      
      updateSelectizeInput(
            session, 
            inputId="longitude",
            choices = colnames(df)[idx],
            server=FALSE
          )
      updateSelectizeInput(
            session, 
            inputId="latitude",
            choices = colnames(df)[idx],
            server=FALSE
          )

    }

    })


model<- reactiveValues()
df<- reactiveValues()

observeEvent(input$runModel,{
    dataName<- isolate(input$dataModel)
    varDep<- isolate(input$varDepModel)
    varIndep<- isolate(input$varIndepModel) # array of indep var name
    longitude<- isolate(input$longitude)
    latitude<- isolate(input$latitude)
    df$alpha<- isolate(input$alpha)
    df$data<- read.csv(paste0("data/", USER$id,"/", dataName, ".csv"))
    location_colname<- colnames(df$data)[2]
    df$data<- df$data[,c(location_colname,longitude, latitude, varDep,varIndep)]
    print(df$data)

    shinyjs::show("model_result")
    
    updateSelectizeInput(
            session, 
            inputId="location",
            choices = df$data[,1],
            server=FALSE
          )
    
    
    formula <- as.formula(paste(varDep," ~ ", paste(varIndep, collapse= "+")))
    location<- cbind(df$data[,longitude],df$data[,latitude])
    col.bw <- gwr.sel(formula, data=df$data, gweight = gwr.Gauss, coords = location, method = "cv", verbose=F)
    model$mgwr<- gwr(formula, data=df$data, hatmatrix = TRUE, 
           gweight = gwr.Gauss, bandwidth = col.bw, coords=location)
    
    output$gwrtest<- renderPrint({
        bfc<- BFC02.gwr.test(model$mgwr)
        bfc 
      })

    output$gwrtestInterpret<- renderText({
        bfc<- BFC02.gwr.test(model$mgwr)
        if(bfc$p.value< df$alpha){
          "Result Interpretation: GWR model is better than global regression model (OLS)"
        }else{
          "Result Interpretation: GWR model is not better than global regression model (OLS)"
        }
      })

    # shinyjs::runjs("window.scrollTo(0,document.documentElement.scrollHeight)")
    db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
    
    datasetID<- dbGetQuery(db, paste0("SELECT datasetID FROM datasets WHERE userID='", USER$id, 
        "' and datasetName='",dataName ,".csv'"))
    print(datasetID)
    countModel<- dbGetQuery(db, paste0("SELECT count(*) FROM users u left join datasets d on u.userID=d.userID",
      " join models m on d.datasetID=m.datasetID WHERE u.userID='", USER$id, "'"))
    print(countModel)
    q<- paste0("INSERT INTO models (datasetID, modelName, dateCreated)",
        " VALUES (", datasetID, ",'model", countModel  , "', '", Sys.time(),"')")
    print(q)
    insertDataset<- dbSendQuery(db, q)
    dbDisconnect(db) 
    output$modelCreatedBox <- renderValueBox({
        valueBox(
          paste0(countModel+1), "Model Created", 
          icon = icon("chart-line"),
          color = "yellow"
        )
      })


  })

observeEvent(input$location,{
    idx<- which(df$data[,1] == input$location)

    output$model_table<- DT::renderDataTable(
      options = list(
        pageLength = 10,
        lengthMenu = c(5, 10, 30, 50)
        ),{
      df$se<- countSE(model$mgwr)
      df$b<- countBeta(model$mgwr)
      df$t<- df$b/df$se
      edf<-  model$mgwr$results$edf
      df$pval<- 2*pt(-abs(df$t),df=edf)< df$alpha
      Variable<- c("Intercept",colnames(df$data)[5:ncol(df$data)])
      Coefficient<- round(df$b[idx,], digits=3)
      Significant<- ifelse((df$pval[idx,]) == TRUE, "Yes", "No")
      
      df$result<- data.table(cbind(Variable, Coefficient, Significant))
      df$result

      })    

    

    

    if(input$runModel==T){
      shinyjs::delay(150, shinyjs::runjs("window.scrollTo(0,document.body.scrollHeight)"))
    }
    

  })

observeEvent(input$cbshp,{
  if(input$cbshp == TRUE){
    disable(id="longitude")
    disable(id="latitude")
  }else{
    enable(id="longitude")
    enable(id="latitude")
  }

  })



output$exportCSV <- downloadHandler(
  filename = function() {
      paste("Full_Report", ".xlsx", sep = "")
    },
    content = function(file) {
      
      y_hat<- model$mgwr$SDF$pred
      residuals<- model$mgwr$SDF$gwr.e 
      localR2<- model$mgwr$SDF$localR2

      df$b<- as.data.frame(df$b)
      colnames(df$b)[1]<- "beta_Intercept"

      df$se<- as.data.frame(df$se)
      colnames(df$se)[1]<- "se_Intercept"

      df$t<- as.data.frame(df$t)
      colnames(df$t)[1]<- "t_Intercept"

      pval<- as.data.frame(2*pt(as.matrix(-abs(df$t)),df=model$mgwr$results$edf))

      for(i in 2: ncol(df$t)){
        colnames(df$b)[i]<- paste0("beta_", colnames(df$data)[i+3])
        colnames(df$se)[i]<- paste0("se_", colnames(df$data)[i+3])
        colnames(df$t)[i]<- paste0("t_", colnames(df$data)[i+3])
        colnames(pval)[i]<- paste0("pval_", colnames(df$data)[i+3])
      }

      description<- c(
        "Data Points",
        "Fixed Bandwidth", 
        "Effective degrees of freedom",
        "Residual sum of squares",
        "R2"
        )
      result<- c(
        model$mgwr$results$n,
        model$mgwr$bandwidth,
        model$mgwr$results$edf,
        model$mgwr$results$rss,
        1 - (model$mgwr$results$rss/model$mgwr$gTSS)
        )


      summary<- as.data.frame(cbind(description, result))

      prepared_data<- as.data.frame(
        cbind(
          seq_len(nrow(df$data)), # index number
          df$data[,c(1,2,3)], # Location name, longitude, latitude
          y_hat,
          residuals,
          localR2,
          df$b, # beta
          df$se, #standard errors
          df$t,
          pval
          )
      )

      colnames(prepared_data)[1]<- c("No")
      
      write_xlsx(
        x=list("summary" = summary, "detail"= prepared_data), 
        path=file, 
        col_names=TRUE, 
        format_headers=TRUE
        )
    }
    )

