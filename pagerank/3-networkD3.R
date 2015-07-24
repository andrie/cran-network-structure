

library(networkD3)
library(igraph)

# Download prepared igraph file from github
url <- "https://github.com/andrie/cran-network-structure/blob/master/pdb/depGraph-CRAN.rds?raw=true"
datafile <- tempfile(fileext = ".rds")
download.file(url, destfile = datafile, mode = "wb")
gs <- readRDS(datafile)

# Remove all nodes with fewer than 50 edges
deg <- degree(gs, mode = "out")
idx <- names(which(deg > 50))
gn <- induced.subgraph(gs, idx)

# Extract into data frame and plot
gd <- get.data.frame(gn, what = "edges")
simpleNetwork(gd, fontSize = 12)
