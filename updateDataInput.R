db<- dbConnect(RSQLite::SQLite(), dbname = "sqlite/prod.db")
dataset<- dbGetQuery(db, paste0("select * from datasets where userID='", USER$id,"'"))


updateSelectInput(
            session,
            inputId="dataDisplay",
            choices= sub(".csv", "", dataset$datasetName)
            )

updateSelectInput(
	session,
	inputId="dataGraphics",
	choices= sub(".csv", "", dataset$datasetName)
	)

updateSelectInput(
	session,
	inputId="dataModel",
	choices= sub(".csv", "", dataset$datasetName)
	)

dbDisconnect(db)