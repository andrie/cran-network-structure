

library(igraph)
library(miniCRAN)
makeDepGraph()
miniCRAN:::plot.pkgDepGraph


# make list of CRAN and BIOC
gg <- list(
  CRAN = readRDS("pdb/depGraph-CRAN.rds"),
  BIOC = readRDS("pdb/depGraph-BIOC.rds")
)

pdb <- readRDS("pdb/pdb-BIOC.rds")

# Extract some basic statistics
lapply(gg, function(x)table(degree(x)))
lapply(gg, function(x)length(V(x)))


g2 <- gg[[2]]
g1 <- gg[[1]]
cranOnBioc <- V(g1)[V(g1)$name %in% V(g2)$name]

foo <- V(g2)[!V(g2)$name %in% V(g1)$name]
foo
bar <- match(foo, V(g2))
V(g2)[bar]
z <- g2[, bar]
g2[[bar]]
str(z)

w <- which(V(g2)$name %in% V(g1)$name)
w
g <- delete.vertices(g2, w)
V(g)$name



