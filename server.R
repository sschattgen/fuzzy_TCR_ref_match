if(!require(shiny, quietly = TRUE)) {
  install.packages("shiny", repos = 'https://cloud.r-project.org/')
  require(shiny, quietly = TRUE)
}
if(!require(ggplot2, quietly = TRUE)) {
  install.packages("ggplot2", repos = 'https://cloud.r-project.org/')
  require(ggplot2, quietly = TRUE)
}
if(!require(stringdist, quietly = TRUE)) {
  install.packages("stringdist", repos = 'https://cloud.r-project.org/')
  require(stringdist, quietly = TRUE)
}
if(!require(dplyr, quietly = TRUE)) {
  install.packages("dplyr", repos = 'https://cloud.r-project.org/')
  require(dplyr, quietly = TRUE)
}
if(!require(patchwork, quietly = TRUE)) {
  install.packages("patchwork", repos = 'https://cloud.r-project.org/')
  require(patchwork, quietly = TRUE)
}
if(!require(magrittr, quietly = TRUE)) {
  install.packages("magrittr", repos = 'https://cloud.r-project.org/')
  require(magrittr, quietly = TRUE)
}

# setup ====
tcr_db <- read.delim('data/new_paired_tcr_db_for_matching_nr.tsv.clustered.tsv')

cpal <- c("#1F77B4", "#AEC7E8", "#FF7F0E", "#FFBB78", "#2CA02C",
          "#98DF8A", "#D62728", "#FF9896","#9467BD", "#C5B0D5",
          "#8C564B", "#C49C94", "#E377C2" ,"#F7B6D2" ,"#7F7F7F", "#C7C7C7",
          "#BCBD22","#DBDB8D" ,"#17BECF" ,"#9EDAE5")
clusts <- sort(unique(tcr_db[['cluster']]))
cpal2 <- cpal[1:length(clusts)]
names(cpal2) <- clusts

# functions in the server ====
filter_v_gene <- function(df, 
                         chain, 
                         filter = FALSE, 
                         vgene = NULL)
  {
  
  filter_col <- ifelse(chain == 'cdr3a','va_gene','vb_gene')
  if (filter == TRUE){
    vgene <- ifelse(grepl("[*]0[1-9]$", vgene) == FALSE,
                    paste0(vgene,'*01'), vgene)
    df2 <- df %>%
      filter(.data[[filter_col]] == vgene) 
  }
  return(df2)
}
  
select_in_radius <- function(df, 
                             in_cdr,
                             chain, 
                             dist_method, 
                             dist_thr, 
                             filter = FALSE, 
                             vgene = NULL)
  {
  if( filter ==TRUE & !is.null(vgene)){
    df_out <- filter_v_gene(df, chain , filter, vgene)
  } else{
    df_out <- df
  }
  
  distv <- stringdist(toupper(in_cdr), df_out[[chain]], method = dist_method)
  df_out <- df_out %>%
    mutate(dist = distv) %>%
    filter(dist <= dist_thr)
  return(df_out)

}

make_sub_hist <- function(df, 
                          col, 
                          fill, 
                          title)
  {
  
  p <- ggplot() +
    geom_histogram(data = df, stat="count",
                   aes_string(col), binwidth = 1, 
                   fill = fill, color = 'black') +
    theme_bw() +
    labs(title = title)+
    xlab("") +
    theme(axis.text.x = element_text( size = 12, angle = 90, hjust = 1, vjust = 0.5))
  
  return(p)
  
}

run_batch_analysis <- function(file, 
                               dist_thr, 
                               dist_method)
  {
  
  user_df <- read.csv(file)
  chain_dfs = list()
  for (chain in c('cdr3a','cdr3b')) {

    if(any(grepl(chain,colnames(tcr_db))) == FALSE)
      next
    
    usr_chains <- user_df[[chain]] %>% unique()
    names(usr_chains) <- paste('input', rep(chain, length(usr_chains)), seq(length(usr_chains)), sep = '_')
    
    out_chain_list <- list()
    for (i in seq(usr_chains)){
      out_chain_list[[i]] <- select_in_radius(tcr_db, usr_chains[i], chain, dist_method, dist_thr) %>%
        mutate(search_chain = chain) %>%
        mutate(input_cdr_name = names(usr_chains)[i]) %>%
        mutate(inupt_cdr_seq = usr_chains[i])
      
    }
    chain_dfs[[chain]] <- do.call(bind_rows, out_chain_list)
  }

  merged_df <- do.call(bind_rows, chain_dfs)
  return(merged_df)

}

# server ====
server <- function(input, output) {

  dist_method <- reactive({
    ifelse(input$dist_method == 'levenshtein', 'lv','hamming')
  })
  
  distData <- reactive({
    select_in_radius(tcr_db, 
                     input$cdr3, 
                     input$chain, 
                     dist_method(), 
                     input$dist,
                     input$vfilter,
                     input$vgene)
  })
  
  output$plot1 <- renderPlot({

    ggplot() +
      geom_point(data= tcr_db, aes(UMAP1, UMAP2, color = factor(cluster)), alpha = 0.4) +
      geom_point(data= distData(), 
                 aes(UMAP1, UMAP2), fill = 'red', size = 4, shape = 21) +
      theme_bw() +
      scale_color_manual(values = cpal2) +
      labs(title = 'Projection of paired epitope-specific TCRs based on similarity', 
           color = 'TCR cluster')

  })
  
  output$plot2 <- renderPlot({
    p1 <- make_sub_hist( distData(),'dist',"#FF0000", paste0(input$dist_method,' distance') )
    p2 <- make_sub_hist( distData(),'epitope_gene',"#00A08A", 'Epitope gene' )
    p3 <- make_sub_hist( distData(),'mhc',"#F2AD00", 'MHC' )
    p1+p2+p3 + plot_layout(widths = c(1,2,1))
  })
  
  output$table <- renderTable(
   distData() %>% 
     arrange(., dist) %>%
     select(dist,va_gene,cdr3a,vb_gene,cdr3b,epitope_gene,epitope_species,mhc,cluster)
  )
  
  output$downloadData <- downloadHandler(
    filename = paste0(input$cdr3,'_results.csv'), content = function(file) {
      write.csv(distData(), file, row.names = FALSE)
    }
  )
  
  runBatch <- eventReactive(input$file, {
    req(input$file)
    run_batch_analysis(input$file$datapath, input$dist, dist_method()) 
  })
  
  output$downloadData2 <- downloadHandler(
    filename = 'batch_results.csv', content = function(file) {
      write.csv(runBatch(), file, row.names = FALSE)
    }
  )
  
#end server
}