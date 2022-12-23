# fuzzy TCR database reference match
shiny app for matching single TCRs to reference db with a fuzzy match by hamming or levenshtein distance. 
It has options for gene usage restrictions.

I wrote it as a little tool for the lab, and for fun, but probably won't update or do much with it.
A new database could be supplied and the umap embedding rerun using `make_ref_umap.py` to customize it.

### clone this repo then run code below in R.
```
library(shiny)
runApp("path_to_folder/fuzzy_TCR_ref_match/")
````
