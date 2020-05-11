library(shiny)
library(plotly)

#load data file
condo = readRDS("data/condo.rds")
condo$noOfBedRoom = as.factor(condo$noOfBedRoom)
condo$leaseDate = as.factor(condo$leaseDate)

ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Trends: Rental Prices"),
  sidebarLayout(
    sidebarPanel(
      #h3("Search for a condo project"),
      # Select condo name here
      selectizeInput("name",
                     label = "select a condominium",
                     choices = unique(condo$project),
                     multiple = F,
                     options = list(maxItems = 1, placeholder = 'Select a project'),
                     selected = "THE SAIL @ MARINA BAY"),
      radioButtons("radio",
                   label = "rental price format",
                   choices = list("rent per month" = "rent",
                                  "rent per square feet" = "psf"),
                   selected = "rent")
      ),
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("trendPlot"),
      br(),
      p("Individual points is a rental contract signed in the given quarter.  Solid lines represent the", 
        span(strong("median"), style = "color:black"), "(black) and", 
        span(strong("quartiles"), style = "color:grey"),
        "(grey) of rental contracts signed in the same district.")
    )
  )
)
)

server <- shinyServer(function(input, output, session) {
  output$trendPlot <- renderPlotly({
    if (input$name == "") {
      s <- ggplot() + ggtitle("please select a condo") + geom_blank()
    } else {
      District = condo$district[which(condo$project == input$name)][1]
      #plot S$ per square feet (psf)
      if (input$radio == "psf"){
        s = ggplot(subset(condo, district == District), aes(x = leaseDate, y = psf, group = 1))
        yLabel = "rent (S$) per square feet"
      } else if(input$radio == "rent") {
        s = ggplot(subset(condo, district == District), aes(x = leaseDate, y = rent, group = 1))
        yLabel = "rent (S$) per month"
      }
      s <- s + stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
        stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
        stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
        geom_jitter(data = subset(condo, project == input$name), aes(color = noOfBedRoom), position = position_jitter(0.2), size = 2) +
        labs(y = yLabel, x = "Lease Date (Quarterly)", color = "# Bed\nRoom") +
        ggtitle(paste(input$name,"| DISTRICT",as.character(District))) +
        theme_bw() + 
        theme(plot.title = element_text(size = 15, hjust = 0.5), legend.position = "right")
    }
    s
  })
})

shinyApp(ui = ui, server = server)