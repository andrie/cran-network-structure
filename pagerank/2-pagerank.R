## Analyze R packages for popularity, using pagerank algorithm

# Inspired by Antonio Piccolboni, http://piccolboni.info/2012/05/essential-r-packages.html

library(miniCRAN)
library(igraph)
library(magrittr)


# Download matrix of available packages at specific date ------------------

g <- readRDS("pdb/depGraph-CRAN.rds")
g <- readRDS("pdb/depGraph-BIOC.rds")

# Use the page.rank algorithm in igraph -----------------------------------

pr <- g %>%
  page.rank(directed = FALSE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")


# Display results ---------------------------------------------------------

head(pr, 25)


# build dependency graph of top packages ----------------------------------

set.seed(42)
pr %>%
  head(25) %>%
  rownames %>%
  makeDepGraph(pdb) %>%
  plot(main="Top packages by page rank", cex=0.5)
