## Analyze R packages for popularity, using pagerank algorithm

# Inspired by Antonio Piccolboni, http://piccolboni.info/2012/05/essential-r-packages.html

library(miniCRAN)
library(igraph)
library(magrittr)


# Download matrix of available packages at specific date ------------------

MRAN <- "http://mran.revolutionanalytics.com/snapshot/2015-06-25/"

pdb <- MRAN %>%
  contrib.url(type = "source") %>%
  available.packages(type="source", filters = NULL)


# Use miniCRAN to build a graph of package dependencies -------------------

# Note that this step takes a while, expect ~15-30 seconds

g <- pdb[, "Package"] %>%
  makeDepGraph(availPkgs = pdb, suggests=FALSE, enhances=TRUE, includeBasePkgs = FALSE)


saveRDS(pdb, file = "pdb/pdb-CRAN.rds")
saveRDS(g, file = "pdb/depGraph-CRAN.rds")
