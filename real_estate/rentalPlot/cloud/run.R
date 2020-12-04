install.packages("ibmdbR", dependencies=TRUE, repos = 'https://cran.revolutionanalytics.com/')
library(shiny)  
port <- Sys.getenv('PORT')


shiny::runApp(  
  appDir = getwd(),
  host = '0.0.0.0',
  port = as.numeric(port)
)