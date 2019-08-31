output$fileUploadBox <- renderValueBox({
        db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
        dataset<- dbGetQuery(db, paste0("select * from datasets where userID='", USER$id,"'"))
        dbDisconnect(db)
        valueBox(
          paste0(nrow(dataset)), "Data Uploaded", icon = icon("file-upload"),
          color = "purple"
        )
      })

