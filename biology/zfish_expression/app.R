library(shiny)
library(plotly)
library(reshape2)
library(plyr)
library(shinycssloaders)


##helper functions here
makeRelative <- function(x, ref){
  for(i in ref$gene_name){
    x$value[x$gene_name == i] <- x$value[x$gene_name == i]/ref$value[ref$gene_name == i]
  }
  x
}

rowRelative = function(df, ref, logScale = F, zeroCorrect = 0.4416741){
  if(tolower(ref) == "median"){
    x <- ddply(df, ~gene_name, summarize, value = median(value))
    x$value[x$value == 0] <- zeroCorrect
    df <- makeRelative(df, x)
  } else {
    r <- subset(df, variable == ref)
    r$value[r$value == 0] <- zeroCorrect
    df <- makeRelative(df, r)
  }
  if(logScale == T){
    df$value <- log(df$value,2)
  }
  return(df)
}


#load expression file
rawDat <- readRDS("data/rawDat3.RDS")

#load sample-stage file
stages <- read.table("data/sample-stage.txt", header = T, stringsAsFactors = F, sep = "\t")
stages <- stages$stage

#choose a random number for spinner type
n <- 7

ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Gene Expression over Development (zebrafish)"),
  sidebarLayout(
    sidebarPanel(
      # Select Genes here
      selectizeInput(inputId= "genes",
                     label = "select genes of interest (max 5)",
                     choices = NULL,
                     multiple = T,
                     options = list(maxItems = 5, placeholder = 'Select Genes')),
                     
      #choose absolute or relative                    
      radioButtons("absrel",
                   label = "expression format",
                   choices = list("absolute" = "abs",
                                  "relative" = "rel"),
                   selected = "abs"),
      # if relative, show options here
      uiOutput('rel'),
      #output log-scaled graph?
      radioButtons("logScale",
                   label = "log-scaled y-axis?",
                   choices = list("True" = T, "False" = F),
                   selected = T)
    ),
    # Show a plot of the generated distribution
    mainPanel(
      withSpinner(plotlyOutput("trendPlot", height = 500), type = n)
    )
  )
)
)

server <- function(input, output, session) {
  updateSelectizeInput(session = session, inputId = "genes", choices = rawDat$gene_name, 
                       server = T, selected = c("yap1","wwtr1"))
  df <- reactive({
    if(length(input$genes) == 0){
      subDat <- c()
    } else {
      #subGenes <- subset(genes, gene_name %in% input$genes)
      subDat <- filter(rawDat, gene_name %in% input$genes)
      subDat <- melt(subDat, id = c("gene_name", "gene_id"))
    }
    subDat
  })
  output$rel <- renderUI({
    if(input$absrel == "rel"){
      selectInput("type",
                  label = "If 'relative', choose a reference point",
                  choices = c("median", stages),
                  multiple = F,
                  selected = "zygote")
    }
  })
  output$trendPlot <- renderPlotly({
    subDat <- df()
    if(length(subDat) == 0){
      s <- ggplot() + ggtitle("select some genes") +geom_blank()
    } else {
      #if user selects relative
      if(input$absrel == "rel"){
        subDat <- rowRelative(subDat,input$type,input$logScale)
        yLab <- "Relative gene expression"
        if(input$logScale == T){
          yLab <- paste("log-scaled", tolower(yLab))
        }
     } else {
        yLab <- "Gene expression (read counts)"
        if(input$logScale == T){
          subDat$value <- log(subDat$value,10)
          yLab <- paste("log-scaled", tolower(yLab))
        }
      }
      plotDat <- subDat
      colnames(plotDat) <- c("gene_name","gene_id","stage","reads")
      s <- ggplot(plotDat, aes(x = stage, y = reads, color = gene_name, group = gene_id)) +
        geom_path(size = 1.2) +
        labs(y = yLab, x = "developmental stage", color = "gene") +
        scale_color_brewer(palette = "Dark2") +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 12))
    }
    ggplotly(s)
  })
}

shinyApp(ui = ui, server = server)