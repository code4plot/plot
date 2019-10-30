shinyServer(function(input, output, session) {
  
  output$trendPlot <- renderPlotly({
    
    if (length(input$name) == 0) {
      input$name = "THE HILLFORD"
    }
    District = condo$district[which(condo$project == input$name)][1]
    #plot S$ per square feet (psf)
    ggplot(subset(condo, district == District), aes(x = as.factor(leaseDate), y = psf, group = 1)) + 
      stat_summary(fun.y = "median", geom = "line", color = "black", size = 1.2) +
      stat_summary(fun.y = function(z) {quantile(z, 0.25) }, geom = "line", color = "grey") +
      stat_summary(fun.y = function(z) {quantile(z, 0.75) }, geom = "line", color = "grey") +
      geom_jitter(data = subset(condo, project == input$name), aes(color = as.factor(noOfBedRoom)), position = position_jitter(0.2), size = 2) +
      labs(y = "S$ per square feet", x = "Lease Date (Quarterly)", color = "# Bed Room") +
      ggtitle(paste("Rental Stats @", input$name)) +
      theme_bw() + 
      theme(plot.title = element_text(size = 20, hjust = 0.5))
  })
})