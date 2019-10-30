shinyUI(fluidPage(
  
  # Application title
  titlePanel("Condo Rental psf"),
  sidebarLayout(
    sidebarPanel(
      #h3("Search for a condo project"),
      # Select condo name here
      selectizeInput("name",
                   label = "condo project",
                   choices = unique(condo$project),
                   multiple = F,
                   options = list(maxItems = 5, placeholder = 'Select a name'),
                   selected = "THE HILLFORD")
      ),
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("trendPlot")
    )
  )
)
)