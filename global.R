library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyalert)
library(RSQLite)
library(V8)
library(mapview)
library(rgdal)
library(data.table)
library(DT)
library(tools)
library(shinycssloaders)
library(writexl)
library(rgeos)
library(spgwr)
library(readxl)
library(DBI)
library(sodium)
library(ggplot2)

# cat("loading .rda\n")
# load(file = "indo.rda")
load(file = "gispedia.rda")

shinyInput <- function(FUN, len, id) {
      inputs <- character(len)
      for (i in seq_len(len)) {
        inputs[i] <- as.character(FUN(paste0(id, i)))
      }
      inputs
    }

b<- NULL
countBeta<- function(mgwr){
  idx<- (length(names(mgwr$SDF))-6) /3
  for(i in 2:(idx+1)){
    names<- names(mgwr$SDF)[i]
    b<- cbind(b, mgwr$SDF@data[,names])
  }
  return(b)
}
se<- NULL
countSE<- function(mgwr){
  idx<- (length(names(mgwr$SDF))-6) /3
  for(i in (idx+2):  (2*idx+1)){
    names<- names(mgwr$SDF)[i]
    se<- cbind(se, mgwr$SDF@data[,names])
  }
  return(se)
}