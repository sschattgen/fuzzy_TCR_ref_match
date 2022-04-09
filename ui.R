
ui <- fluidPage(
pageWithSidebar(
  headerPanel('TCR database fuzzy search'),
  sidebarPanel(
    textInput('cdr3', 'cdr3 amino acid sequence'),
    selectInput('chain', 'cdr3 chain', c('cdr3a','cdr3b')),
    selectInput('dist_method','distance measure', c('lv','hamming')),
    sliderInput('dist', 'distance radius', 3, min = 1, max = 12)
  ),
  mainPanel(
    plotOutput('plot1'),
    tableOutput('table')
  )
)
)
