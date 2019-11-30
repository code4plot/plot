library(shiny)
library(plotly)
library(shinycssloaders)

#load data file
condo <- readRDS("data/district.rds")
#condo$noOfBedRoom = as.factor(condo$noOfBedRoom)
condo$leaseDate <- as.factor(condo$leaseDate)
condo$rent <- as.numeric(condo$rent)
condo$psf <- as.numeric(condo$psf)

n <- 7

ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Trends: Rental Prices by district in Singapore"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("name",
                     label = "select a district",
                     choices = sort(unique(condo$district)),
                     multiple = F,
                     options = list(maxItems = 1, placeholder = 'Select a district'),
                     selected = "15"),
      uiOutput("rooms"),
      radioButtons("radio",
                   label = "rental price format",
                   choices = list("rent per month" = "rent",
                                  "rent per square feet" = "psf"),
                   selected = "rent"),
      radioButtons("natMed",
                   label = "show/hide national median and quartiles",
                   choices = list("show" = T,
                                  "hide" = F),
                   selected = F)
      ),
    # Show a plot of the generated distribution
    mainPanel(
      withSpinner(plotlyOutput("trendPlot"), type = n)
      #br(),
      #insert legend here
    )
  )
)
)

server <- shinyServer(function(input, output, session) {
  districtDF <- reactive({
    df <- subset(condo, district == input$name)
    df
  })
  output$rooms <- renderUI({
    selectInput("rooms",
                label = 'select no of bedrooms to plot',
                choices = c('All',unique(sort(districtDF()$noOfBedRoom))),
                multiple = F,
                selected = 'All')
  })
  
  output$trendPlot <- renderPlotly({
    df <- districtDF()
    if (nrow(df) == 0) {
      u <- ggplot() + ggtitle("please select a district") + geom_blank()
    } else {
      #District = condo$district[which(condo$project == input$name)][1]
      #plot S$ per square feet (psf)
      if(input$radio == "psf"){
        s <- ggplot(condo, aes(x = leaseDate, y = psf))
        yLabel <- "rent (S$) per square feet"
      } else if(input$radio == "rent") {
        s <- ggplot(condo, aes(x = leaseDate, y = rent))
        yLabel <- "rent (S$) per month"
      }
      if(input$rooms != 'All'){
        df <- subset(df, noOfBedRoom == input$rooms)
      }
      t <- s + geom_violin(data = df, trim = F) + 
        stat_summary(data = df, fun.ymin = function(z) {ymin = quantile(z, 0.25)},
                     fun.ymax = function(z) {ymax = quantile(z, 0.75)},
                     fun.y = function(z) {y = median(z)},
                     geom = "pointrange", color = "red")
      if (input$natMed){
        df2 <- condo
        if(input$rooms != 'All'){
          df2 <- subset(df2, noOfBedRoom == input$rooms)
        }
        t <- t + stat_summary(data = df2, mapping = aes(group = 1), fun.y = "median", geom = "line", color = "black", size = 1.2) +
          stat_summary(data = df2, mapping = aes(group = 1), fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
          stat_summary(data = df2, mapping = aes(group = 1), fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") 
      }
      u <- t + labs(y = yLabel, x = "Lease Date (YY/MM)") +
          ggtitle(paste("DISTRICT |", input$name)) +
          theme_bw() + 
          theme(plot.title = element_text(size = 15, hjust = 0.5), axis.text.x = element_text(angle = 30, hjust = 1, size = 12))
    }
    tryCatch(
      ggplotly(u),
    error = function(e){
      ggplot() + ggtitle("too few observations") + geom_blank()
    }
    )      
  })
})

shinyApp(ui = ui, server = server)
#runGadget(shinyApp(ui = ui, server = server))
