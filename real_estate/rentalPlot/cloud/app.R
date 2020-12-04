#load libraries
library(DBI)
library(shiny)
library(plotly)
library(dplyr)
library(dbplyr)

con <- DBI::dbConnect(odbc::odbc(),
                      Driver   = "MySQL ODBC 8.0 Unicode Driver",
                      Server   = "ura-rent.cm0lezxudqaz.ap-southeast-1.rds.amazonaws.com",
                      UID      = "admin",
                      PWD      = "UKhmpajsMYzn2AhNFD5v",
                      Port     = 3306,
                      Database = 'ura_rent')

project <- dbGetQuery(con, 'select project from condo_info 
                      where propertyType = "Non-landed Properties"')
project_names <- project$project


ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Trends: Rental Prices"),
  sidebarLayout(
    sidebarPanel(
      #h3("Search for a condo project"),
      # Select condo name here
      selectizeInput("name",
                     label = "select a condominium",
                     choices = project_names,
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
    #ch <- idaConnect(conn_path)
    #idaInit(ch)
    
    #load URA_rental table
    #ura <- ida.data.frame("URA_RENTAL")
    
    #get condos only
    #condo <- ura[ura$propertyType == "Non-landed Properties" | ura$propertyType == "Executive Condominium",
     #            c("PROJECT","areaSqft","leaseDate","DISTRICT","noOfBedRoom","RENT","PSF")]
    if (local(input$name) == "") {
      s <- ggplot() + ggtitle("please select a condo") + geom_blank()
    } else {
      dis <- tbl(con, 'condo_info') %>%
        filter(project == local(input$name)) %>%
        select('district', 'CONDOID') %>%
        collect()
      District <- dis$district[1]
      #District = project$DISTRICT[project$PROJECT == input$name]
      print("district done")
      #plot S$ per square feet (psf)
      condo_district <- dbGetQuery(con, paste('select r.CONDOID,r.noOfBedRoom,r.leaseDate,r.rent,r.psf
                                   from rent_info r left join 
                                   (select CONDOID from condo_info where district = ', District, ') c 
                                   on r.CONDOID=c.CONDOID',sep = ""))
      #condo_district <- as.data.frame(condo[condo$DISTRICT == District,])
      condo_district$noOfBedRoom = as.factor(condo_district$noOfBedRoom)
      condo_district$leaseDate = as.factor(condo_district$leaseDate)
      condo_district$rent = as.numeric(condo_district$rent)
      condo_district$psf = as.numeric(condo_district$psf)
      #idaClose(ch)
      print("condo_district done")
      if (input$radio == "psf"){
        s <- ggplot(condo_district, aes(x = leaseDate, y = psf, group = 1))
        yLabel = "rent (S$) per square feet"
      } else if(input$radio == "rent") {
        s <- ggplot(condo_district, aes(x = leaseDate, y = rent, group = 1))
        yLabel = "rent (S$) per month"
      }
      condo_subset <- subset(condo_district, CONDOID == dis$CONDOID[1])
      print("condo_subset done")
      s <- s + stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
        stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
        stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
        geom_jitter(data = condo_subset, aes(color = noOfBedRoom), position = position_jitter(0.2), size = 2) +
        labs(y = yLabel, x = "Lease Date (Quarterly)", color = "# Bed\nRoom") +
        ggtitle(paste(local(input$name),"| DISTRICT", District)) +
        theme_bw() + 
        theme(plot.title = element_text(size = 15, hjust = 0.5), legend.position = "right")
    }
    s
  })
})

shinyApp(ui = ui, server = server)

