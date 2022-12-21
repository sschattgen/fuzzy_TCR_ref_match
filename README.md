# fuzzy TCR database reference match
shiny app for matching single TCRs to reference db with a fuzzy match by hamming or levenshtein distance. 
It has options for gene usage restrictions.

I wrote it as a little tool for the lab, and for fun, but probably won't update or do much with it.

## Requires stringdist, ggplot2, and shiny packages
```
library(shiny)
runApp("~/fuzzy_TCR_ref_match/")
````
