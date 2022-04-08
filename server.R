
server <- function(input, output) {
  
  # Combine the selected variables into a new data frame
  selectedData <- reactive({
    tcr_db[, c('UMAP1','UMAP2','epitope_gene','mhc', input$chain)]
  })
  
  distData <- reactive({
    selectedData()[which( stringdist(input$cdr3, selectedData()[[input$chain]], method = 'lv') <= input$dist),]
  })
  
  output$plot1 <- renderPlot({
    
    ggplot() +
      geom_point(data= selectedData(), aes(UMAP1, UMAP2), color = 'blue', alpha = 0.4) +
      geom_point(data= distData(), aes(UMAP1, UMAP2), fill = 'red', size = 4, shape = 21) +
      theme_bw()

  })
  
  output$table <- renderTable(distData()[,c(input$chain,'epitope_gene','mhc')])
  
 
}