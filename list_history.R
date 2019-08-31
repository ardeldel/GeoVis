


df <- reactiveValues()
db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
df$data<- data.table(
    dbGetQuery(db, paste0("select * from datasets where userID='", USER$id,"'"))
  )
dbDisconnect(db) 

output$list_history <- DT::renderDataTable({

      if(nrow(df$data)!=0){
        df$data$datasetName<- sub(".csv","", df$data$datasetName)
        DT<- df$data[,c(3,4)]
        colnames(DT)<- colnames(df$data[,c(3,4)])
        DT[["Actions"]]<-
          paste0('
          <div class="btn-group" role="group" aria-label="Basic example">
          <button type="button" class="btn btn-primary historyBtn" id=deleteDataUploaded_',1:nrow(df$data),'>Delete</button>
          <button type="button" class="btn btn-primary historyBtn"id=edit_',1:nrow(df$data),'>Edit</button></div>
          ')
        DT::datatable(DT,selection = 'single', escape = FALSE,options = list( 
              pageLength = 5,
              lengthMenu = c(5, 10, 30, 50)
              ))
        }else{
          DT<- data.frame(datasetName=character(), dateUploaded=character(), stringsAsFactors=FALSE)
        }
      
      })


observeEvent(input$lastClick, {
   if (input$lastClick !=0 & input$lastClickId%like%"deleteDataUploaded_"){
    #cat(input$lastClickId, "lastClickId %like% deleteDataUploaded_\n")
     row_to_del=as.numeric(gsub("deleteDataUploaded_","",input$lastClickId))
     confirmSweetAlert(
      session = session,
      inputId = "deleteData",
      type = "warning",
      title = paste("Are you sure to delete?", df$data$datasetName[row_to_del]),
      danger_mode = TRUE
    )
     
   }
   else if (input$lastClick !=0 & input$lastClickId %like% "edit_"){
    cat(input$lastClickId, "lastClickId %like% edit_\n")
      modal_modify=modalDialog(
        fluidPage(
          h3(strong("Edit Data Info"),align="center"),
          hr(),
          dataTableOutput('row_edit'),
          actionButton("save_changes","Save changes")
        ),
        tags$script(HTML("$(document).on('click', '#save_changes', function () {
          var list_value=[]
          for (i = 0; i < $( '.new_input' ).length; i++)
          {
          list_value.push($( '.new_input' )[i].value)
          }
          Shiny.onInputChange('newValue', list_value)
          });")),
        size="l"
      )
      showModal(modal_modify)

      observeEvent(input$newValue,{
        newValue=lapply(input$newValue, function(col) {
        if (suppressWarnings(all(!is.na(as.numeric(as.character(col)))))) {
        as.numeric(as.character(col))
        } else {
        col
        }
        })
        DF=data.frame(lapply(newValue, function(x) t(data.frame(x))))
        colnames(DF)=colnames(df$data[,c(3)])
        db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
        dataset<- dbSendQuery(db, paste0("update datasets set datasetName='", paste0(DF$datasetName, ".csv") ,"' where datasetID='", df$data$datasetID[as.numeric(gsub("edit_","",input$lastClickId))],"'"))
        dbDisconnect(db) 
        file.rename(paste0("data/", USER$id,"/", df$data$datasetName[as.numeric(gsub("edit_","",input$lastClickId))],".csv"),
          paste0("data/", USER$id,"/", DF$datasetName,".csv"))
        df$data[as.numeric(gsub("edit_","",input$lastClickId)), c(3)]<-DF
        removeModal()
        source("fileUploadBox.R", local=TRUE)$value 
        source("updateDataInput.R", local=TRUE)$value 
      })
      

   }
 })

##### Delete Data Controller ####
  observeEvent(input$deleteData, {
    cat(input$deleteData, "delete button clicked\n")
    if (input$lastClick !=0 & isTRUE(input$deleteData)) {
      cat(input$deleteData, "delete conf true\n")
      row_to_del=as.numeric(gsub("deleteDataUploaded_","",input$lastClickId))
      db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
      dataset<- dbSendQuery(db, paste0("delete from datasets where datasetID='", df$data$datasetID[row_to_del],"'"))
      dbDisconnect(db) 
      # cat(paste0("data/", USER$id,"/", df$data$datasetName[row_to_del], ".csv"), "cat1\n")
      unlink(paste0("data/", USER$id,"/", df$data$datasetName[row_to_del],".csv"))
      df$data=df$data[-row_to_del,]
      source("fileUploadBox.R", local=TRUE)$value 
      source("updateDataInput.R", local=TRUE)$value 
      list_history_rows_selected <- NULL
      shinyjs::hide(id="dataHistoryBox")


    } 
  })#, ignoreNULL = TRUE)




output$row_edit<-renderDataTable({
      selected_row=as.numeric(gsub("edit_","",input$lastClickId))
      old_row=df$data[selected_row, c(3)]
      row_change=list()
      for (i in colnames(old_row))
      {
        if (is.numeric(df$data[[i]]))
        {
          row_change[[i]]<-paste0('<input class="new_input" type="number" id=new_',i,'><br>')
        }
        else
        row_change[[i]]<-paste0('<input class="new_input" type="text" id=new_',i,'><br>')
      }
      row_change=as.data.table(row_change)
      setnames(row_change,colnames(old_row))
      DT=rbind(old_row,row_change)
      rownames(DT)<-c("Current values","New values")
      DT
      
    },escape=F,options=list(dom='t',ordering=F),selection="none"
    )



observeEvent(input$list_history_rows_selected,{
  shinyjs::show(id="dataHistoryBox")
  })

output$contents_history = DT::renderDataTable(
  options = list(
    scrollX = TRUE, 
    pageLength = 5,
    lengthMenu = c(5, 10, 30, 50)
    ),
  selection = 'none',
  {
    s = input$list_history_rows_selected
    if (length(s)) {
      data<- read.csv(paste0("data/", USER$id,"/" ,df$data$datasetName[s], ".csv"))
      data[,-1]
    }
  })



