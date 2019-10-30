library(plotly)
library(shiny)
#choose condo project to visualize

#load raw data
rawDat = "rawDat_191028.csv"
rawDat = read.csv(rawDat, stringsAsFactors = F)

#subset to analyze condominiums and executive condominiums
condo = subset(rawDat, propertyType %in% c("Non-landed Properties", "Executive Condominium"))

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Condo Project"),
  
  sidebarPanel(
    h3("Search for a condo project"),
    # Select Justices name here
    selectizeInput("name",
                   label = "condo project",
                   choices = unique(condo$project),
                   multiple = F,
                   options = list(maxItems = 5, placeholder = 'Select a name'),
                   selected = "THE HILLFORD"),
    # Term plot
    #plotOutput("termPlot", height = 200),
    #helpText("Data: Bailey, Michael, Anton  Strezhnev and Erik Voeten. Forthcoming.  'Estimating Dynamic State Preferences from United Nations Voting Data.' Journal of Conflict Resolution. ")
    #),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("trendPlot")
    )
  )
)
)


District = condo$district[which(condo$project == projectName)][1]
#plot S$ per square feet (psf)
s = ggplot(subset(condo, district == District), aes(x = as.factor(leaseDate), y = psf, group = 1)) + 
	stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
	stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
	stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
	geom_jitter(data = subset(condo, project == projectName), aes(color = as.factor(noOfBedRoom)), position = position_jitter(0.2), size = 2) +
	labs(y = "S$ per square feet", x = "Lease Date (Quarterly)", color = "# Bed Room") +
	ggtitle(paste("Rental Stats @", projectName)) +
	theme_bw() + 
	theme(plot.title = element_text(size = 20, hjust = 0.5))
dev.new(width = 20, height = 12, unit = "cm")
s
#ggsave("hillford_rent.png", width = dev.size("cm")[1], height = dev.size("cm")[2], units = "cm")

#plot rent per month
t = ggplot(subset(condo, district == District), aes(x = as.factor(leaseDate), y = rent, group = 1)) + 
	stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
	stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
	stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
	geom_jitter(data = subset(condo, project == projectName), aes(color = as.factor(noOfBedRoom)), position = position_jitter(0.2), size = 2) +
	labs(y = "S$ per month", x = "Lease Date (Quarterly)", color = "# Bed Room") +
	ggtitle(paste("Rental Stats @", projectName)) +
	theme_bw() + 
	theme(plot.title = element_text(size = 20, hjust = 0.5))
dev.new(width = 20, height = 12, unit = "cm")
t
#ggsave("hillford_rent2.png", width = dev.size("cm")[1], height = dev.size("cm")[2], units = "cm")

