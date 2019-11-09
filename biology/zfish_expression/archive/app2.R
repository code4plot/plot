library(shiny)
library(plotly)
library(reshape2)


##helper functions here
rowMedian = function(df){
  result <- numeric(nrow(df))
  for(i in 1:nrow(df)){
    result[i] <- median(as.numeric(df[i,]))
  }
  #df <- sapply(df, median)
  return(result)
}

rowRelative = function(df, ref, logScale = F, zeroCorrect = 0.4416741){
  if(tolower(ref) == "median"){
    x <- rowMedian(df)
    x[which(x == 0)] <- zeroCorrect
  } else {
    x <- df[,ref]
    x[which(x == 0)] <- zeroCorrect
  }
  df <- df/x
  if(logScale == T){
    df <- log(df,2)
  }
  return(df)
}


#load expression file
rawDat <- readRDS("data/rawDat.RDS")

#load sample-stage file
stages <- colnames(rawDat)

#load genes file
genes <- readRDS("data/genes.RDS")

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
                     
                    
      radioButtons("absrel",
                   label = "expression format",
                   choices = list("absolute" = "abs",
                                  "relative" = "rel"),
                   selected = "abs"),
      conditionalPanel(condition = "input.absrel == rel",
                       selectInput("type",
                                    label = "If 'relative', choose a reference point",
                                    choices = c("median", stages),
                                    multiple = F,
                                    selected = "zygote")),
      radioButtons("logScale",
                   label = "log-scaled y-axis?",
                   choices = list("True" = T, "False" = F),
                   selected = T)
    ),
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("trendPlot", height = 500)
    #  br(),
    #  p("figure legend here")
    )
  )
)
)

server <- function(input, output, session) {
  updateSelectizeInput(session = session, inputId = "genes", choices = unique(genes$gene_name), 
                       server = T, selected = c("yap1","wwtr1"))
  df <- reactive({
    if(length(input$genes) == 0){
      plotDat <- c()
    } else {
      subGenes <- subset(genes, gene_name %in% input$genes)
      temp_ind <- genes$gene_name %in% input$genes
      subDat <- rawDat[temp_ind,]
      #if user selects relative
      if(input$absrel == "rel"){
        subDat <- rowRelative(subDat,input$type,input$logScale)
      } else {
        if(input$logScale == T){
          subDat <- log(subDat,10)
        }
      }
      subDat <- cbind(subGenes, subDat)
      plotDat <- melt(subDat)
      colnames(plotDat) <- c("gene_id","gene_name","stage","reads")
    }
  plotDat
  })
  yLab <- reactive({
    if(input$absrel == "rel"){
      y <- "Relative gene expression"
    } else {
      y <- "Gene expression (read counts)"
    }
    if(input$logScale){
      y <- paste("log-scaled", tolower(y))
    }
    y
  })

  output$trendPlot <- renderPlotly({
    df <- df()
    if(length(df) == 0){
      s <- ggplot() + ggtitle("select some genes") +geom_blank()
    } else {
      yLab <- yLab()
      s <- ggplot(df, aes(x = stage, y = reads, color = gene_name, group = gene_id)) +
        geom_path(size = 1.2) +
        labs(y = yLab, x = "developmental stage", color = "gene") +
        scale_color_brewer(palette = "Dark2") +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 12))
    }
    s
  })
}

shinyApp(ui = ui, server = server)