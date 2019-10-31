library(shiny)
library(plotly)
library(plyr)

##helper functions here
rowMedian = function(df){
  df = apply(df, 1, median)
  return(df)
}

rowRelative = function(df, ref, logScale = F){
  if(tolower(ref) == "none"){
    x = rowMedian(df)
  } else {
    x = df[,ref]
    x[which(x == 0)] = 0.001
  }
  df = df/x
  if(logScale == T){
    df = log(df,2)
  }
  return(df)
}

makeExpressionDF = function(df){
  temp = stack(df, select = -c(gene_name, gene_id))
  times = nrow(temp)/nrow(df)
  result = data.frame(gene_id = rep(df$gene_id, times), gene_name = rep(df$gene_name, times), 
                      reads = temp$values, stage = temp$ind, stringsAsFactors = F)
  return(result)
}

#load data file
rawDat = read.table("data/zfish_expression.txt", header = T, sep = "\t", stringsAsFactors = F)

#load sample-stage file
stages = read.table("data/sample-stage.txt", header = T, sep = "\t", stringsAsFactors = F)
stages = setNames(stages$stage, stages$sample)

#cleanup column names
rawDat = rename(rawDat, replace = stages)

ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Gene Expression over Development (zebrafish)"),
  sidebarLayout(
    sidebarPanel(
      # Select Genes here
      selectizeInput("genes",
                     label = "select genes of interest",
                     choices = c(unique(rawDat$gene_name)),
                     multiple = T,
                     options = list(maxItems = 5, placeholder = 'Select Genes'),
                     selected = c("yap1","wwtr1")),
                    
      radioButtons("absrel",
                   label = "expression format",
                   choices = list("absolute" = "abs",
                                  "relative" = "rel"),
                   selected = "abs"),
      conditionalPanel(condition = "input.absrel == rel",
                       selectInput("type",
                                    label = "reference point",
                                    choices = c("none", colnames(rawDat)[2:(ncol(rawDat)-1)]),
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

server <- shinyServer(function(input, output, session) {
  
  output$trendPlot <- renderPlotly({
    
    if (length(input$genes) == 0) {
      input$genes = c("yap1","wwtr1")
    }
    #subset rawDat by genes
    subDat = subset(rawDat, gene_name %in% input$genes)
    #columns with expression data only
    temp_ind = 2:(ncol(subDat)-1)
    temp_df = subDat[,temp_ind]
    #if user selects relative
    if(input$absrel == "rel"){
      subDat[,temp_ind] = rowRelative(temp_df,input$type,input$logScale)
      yLab = "Relative gene expression"
      if(input$logScale == T){
        yLab = paste("log-scaled", tolower(yLab))
      }
    } else {
      yLab = "Gene expression"
      if(input$logScale == T){
        subDat[,temp_ind] = log(temp_df,10)
        yLab = paste("log-scaled", tolower(yLab))
      }
    }
    plotDat = subDat
    #stack up expression levels for plotting
    plotDat = makeExpressionDF(plotDat)
    
    s = ggplot(plotDat, aes(x = stage, y = reads, color = gene_name, group = gene_name)) +
      geom_line(size = 1.2) +
      labs(y = yLab, x = "developmental stage", color = "gene") +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 12))
    s
  })
})

shinyApp(ui = ui, server = server)