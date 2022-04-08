tcr_db <- readRDS('data/db.rds')
library(shiny)
library(tidyverse)
library(stringdist)

# ui <- fluidPage(
#   
#   pageWithSidebar(
#     headerPanel('Iris k-means clustering'),
#     sidebarPanel(
#       textInput('cdr3', 'cdr3 amino acid sequence'),
#       selectInput('chain', 'cdr3 chain',  c('cdr3a','cdr3b')),
#       numericInput('dist', 'Dist threshold', 10, min = 1, max = 40)
#     ),
#     mainPanel(
#       plotOutput('plot1')
#     )
#   )
# )
# 
# server <- function(input, output) {
#   
#   # Combine the selected variables into a new data frame
#   selectedData <- reactive({
#     tcr_db[, c('UMAP1','UMAP2','epi_source', 'HLA',input$chain)]
#   })
#   
#   distData <- reactive({
#     selectedData()[which( stringdist(input$cdr3, selectedData()[[input$chain]], method = 'lv') <= input$dist),]
#   })
#   
#   output$plot1 <- renderPlot({
#     
#     ggplot() +
#       geom_point(data= selectedData(), aes(UMAP1, UMAP2), color = 'blue') +
#       geom_point(data= distData(), aes(UMAP1, UMAP2), fill = 'red', size = 2, shape = 21) +
#       theme_bw()
#     
#   })
#   
# }
shinyApp(ui = ui, server = server)
