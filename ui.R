library(shiny)
ui <- fluidPage(
  
pageWithSidebar(
  headerPanel('TCR database fuzzy search'),
  sidebarPanel(
    textInput('cdr3', 'cdr3 amino acid sequence', value = 'CAVKYGNKLVF'),
    selectInput('chain', 'cdr3 chain', c('cdr3a','cdr3b')),
    selectInput('dist_method','distance measure', c('hamming','levenshtein')),
    sliderInput('dist', 'distance radius', 3, min = 1, max = 10),
    textInput('vgene', 'TRAV or TRBV gene', value = NULL),
    checkboxInput('vfilter', 'Filter by V gene match', value = FALSE),
    downloadButton("downloadData", "Download single chain reults"),
    fileInput("file", "CSV file with 'cdr3a' and/or 'cdr3b' columns.",
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv")),
    #checkboxInput('vfilter_batch', 'Filter by V gene match in batch, requires"va_gene" and/or "vb_gene" columns ', value = FALSE),
    downloadButton("downloadData2", "Download batch reults"),
  ),
  mainPanel(
    plotOutput('plot1'),
    plotOutput('plot2'),
    tableOutput('table')
  )
)
)
