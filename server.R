
server <- function(input, output) {
  keep_cols <- c('UMAP1','UMAP2','epitope_gene','mhc','cluster')
  # Combine the selected variables into a new data frame
  selectedData <- reactive({
    tcr_db[, c(keep_cols, input$chain)]
  })
  
  distData <- reactive({
    selectedData()[which( stringdist(input$cdr3, selectedData()[[input$chain]], method = input$dist_method) <= input$dist),]
  })

  output$plot1 <- renderPlot({
    cpal <- c("#1F77B4", "#AEC7E8", "#FF7F0E", "#FFBB78", "#2CA02C",
              "#98DF8A", "#D62728", "#FF9896","#9467BD", "#C5B0D5",
              "#8C564B", "#C49C94", "#E377C2" ,"#F7B6D2" ,"#7F7F7F", "#C7C7C7",
              "#BCBD22","#DBDB8D" ,"#17BECF" ,"#9EDAE5")
    clusts <- sort(unique(selectedData()[['cluster']]))
    cpal <- cpal[1:length(clusts)]
    names(cpal) <- clusts
    ggplot() +
      geom_point(data= selectedData(), aes(UMAP1, UMAP2, color = factor(cluster)), alpha = 0.4) +
      geom_point(data= distData(), aes(UMAP1, UMAP2), fill = 'red', size = 4, shape = 21) +
      theme_bw() +
      scale_color_manual(values = cpal) +
      theme(legend.position = 'none')
      

  })
  
  output$table <- renderTable(distData()[,c(keep_cols, input$chain)])
  
 
}