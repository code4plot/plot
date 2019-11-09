library(shiny)
library(plotly)
library(plyr)

##helper functions here
rowMedian = function(df){
  df = apply(df, 1, median)
  return(df)
}

rowRelative = function(df, ref, logScale = F){
  if(tolower(ref) == "median"){
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

getData = function(x, suf = "zfish_", ext = ".txt", fromDir = "data/", id = "gene_id"){
  if(id == "gene_id"){
    y = 1
  } else {
    y = 2
  }
  ind = unique(x$fileIndex)
  for(i in ind){
    genes = x[which(x$fileIndex %in% i), id]
    i = as.character(i)
    fileName = paste(fromDir,suf,i,ext,sep = "")
    temp = read.table(fileName, header = F, sep = "\t", stringsAsFactors = F)
    if(!exists("results")){
      results = subset(temp, temp[,y] %in% genes)
    } else {
      results = rbind(results, subset(temp, temp[,y] %in% genes))
    }
  }
  return(results)
}

relcomp <- function(a, b) {
  
  comp <- vector()
  
  for (i in a) {
    if (i %in% a && !(i %in% b)) {
      comp <- append(comp, i)
    }
  }
  
  return(comp)
}

#load genes file
gfile = read.table("data/zfish_genes.txt", header = T, sep = "\t", stringsAsFactors = F)

#load sample-stage file
stages = read.table("data/sample-stage.txt", header = T, sep = "\t", stringsAsFactors = F)
stages = c("gene_id", "gene_name", stages$stage)

#cleanup column names
#rawDat = rename(rawDat, replace = stages)

ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Gene Expression over Development (zebrafish)"),
  sidebarLayout(
    sidebarPanel(
      # Select Genes here
      selectizeInput("genes",
                     label = "select genes of interest",
                     choices = c(unique(gfile$gene_name)),
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
                                    label = "If 'relative', choose a reference point",
                                    choices = c("median", stages[-c(1,2)]),
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
  currentGenes <- reactive({
    toPlot = subset(gfile, gene_name %in% input$genes)
    subDat = getData(toPlot, id = "gene_name")
    #assign column names
    colnames(subDat) = stages
    return(subDat)
  })

  output$trendPlot <- renderPlotly({
    subDat = currentGenes()
    #columns with expression data only
    temp_ind = -c(1,2)
    temp_df = subDat[,temp_ind]
    #if user selects relative
    if(input$absrel == "rel"){
      subDat[,temp_ind] = rowRelative(temp_df,input$type,input$logScale)
      yLab = "Relative gene expression"
      if(input$logScale == T){
        yLab = paste("log-scaled", tolower(yLab))
      }
    } else {
      yLab = "Gene expression (read counts)"
      if(input$logScale == T){
        subDat[,temp_ind] = log(temp_df,10)
        yLab = paste("log-scaled", tolower(yLab))
      }
    }
    plotDat = subDat
    #stack up expression levels for plotting
    plotDat = makeExpressionDF(plotDat)
    plotDat$stage = as.factor(plotDat$stage)
    s = ggplot(plotDat, aes(x = stage, y = reads, color = gene_name, group = gene_id)) +
      geom_line(size = 1.2) +
      labs(y = yLab, x = "developmental stage", color = "gene") +
      scale_color_brewer(palette = "Dark2") +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 12))
    s
  })
})

shinyApp(ui = ui, server = server)