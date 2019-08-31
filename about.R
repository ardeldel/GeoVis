
fluidPage(
  
  box(
    # id="about",
    title= tags$p(id="about2", "About", style = "font-size: 125%;", class="boxTitle-bottom"),
    
    solidHeader = FALSE,
    collapsible = TRUE,
    width=12,
    p("GeoVis, created in 2019 by Ardelia Christina, a student at Bina Nusantara (BINUS) University.
      For any feedback please drop an email", 
      a(href="mailto:ardelia_christina@icloud.com?Subject=GWR%20Feedback", target="_top", "here"))  
  
  ),
  box(
    # id="about",
    title= tags$p(id="help", "Help", style = "font-size: 125%;", class="boxTitle-bottom"),
    solidHeader = FALSE,
    collapsible = FALSE,
    width=12,
    p("GeoVis is a web based application created using R Shiny to perform Geographically Weighted Regression (GWR) model. 
      GWR is a local form of linear regression where the model can be different on each location. 
      GWR comes handy when spatial dependency presents. Spatial dependency means that nearby location appear to be correlated.
      This software currently only supports Gaussian Kernel for weighting process."),
    h4("Home"),
    p("On this tab, user can get a brief overview about GeoVis application. Number of data uploaded is diplayed as well as 
    the number of model created. On 'Data Summary' section, select data and variable to view data summary and top five values
    from each input."),
    h4("Upload Data"),
    p("Upload your data on this tab. Simply choose file with csv or xlsx extension and arrange desired columns to upload.
      User can view the data to be uploaded to recheck its validity. Give your data a unique name as this will differentiate
      one data and another. In order to fully use Visualitation and Model function, it is recommended that user uploads 
      the first column as the district names. USer also need to have longitude and latitude data to be used later in modelling GWR.
      Once user has fully completed the upload data form, click upload button and user will get a success message if the data have been successfully uploaded"),
    h4("Upload History"),
    p("For every data user has uploaded, the list will be displayed on Upload History Tab. User can also view the data,
      make changes on the data, and delete data. To view the data, click anywhere in the data row and data will be displayed.
      To edit and delete data, click edit or delete, respectively."
      ),
    h4("Visualization"),
    p("User can visualize the distribution of each variable using Visualization Tab. As mentioned earlier in Upload Data Tab, 
      The data uploaded need to have district names in the first column and inline with the system's embedded district names that
      user can download the list on this tab as well. Choose data and variable to map and click OK. Enjoy the map!"
      ),
    h4("Model"),
    p("The Model Tab is the Heart of GeoVis, providing tools to perform Geographically Weighted Regression modelling.
      Simply select data, dependent variable, independent variables, longtide, latitude, and significance level. 
      Proceed with Run button. Application will display the results per district but user can download the full report by clicking
      Download Full Report. Full Report provides y hat (predicted values), local R-squared, coefficient values, standard error values,
      t values, and p-values."
      )
  
  )
)