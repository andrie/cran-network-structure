# Create summary statistics for a graph

library(igraph)
gcran <- readRDS("pdb/depGraph-CRAN.rds")
gbioc <- readRDS("pdb/depGraph-BioC.rds")


# Create summary statistics -----------------------------------------------

graphSummary <- function(g){
  pl <- power.law.fit(degree(g))
  data.frame(
    nodes = length(V(g)),
    edges = length(E(g)),
    average.path.length = average.path.length(g),
    assortativity.degree = assortativity.degree(g),
    no.clusters = no.clusters(g),
    transitivity = transitivity(g),
    power.law.fit = pl$alpha,
    power.law.xmin = pl$xmin,
    power.law.KS.p = pl$KS.p
  )
}

gg <- list(gcran = gcran, gbioc = gbioc)
do.call(rbind, lapply(gg, graphSummary))
