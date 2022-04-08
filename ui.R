
ui <- fluidPage(
pageWithSidebar(
  headerPanel('reference TCRdist clustered'),
  sidebarPanel(
    textInput('cdr3', 'cdr3 amino acid sequence'),
    selectInput('chain', 'cdr3 chain', c('cdr3a','cdr3b')),
    numericInput('dist', 'Dist threshold', 3, min = 1, max = 12)
  ),
  mainPanel(
    plotOutput('plot1'),
    tableOutput('table')
  )
)
)
