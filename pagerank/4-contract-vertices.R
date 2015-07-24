

library(networkD3)
library(igraph)

# Download prepared igraph file from github
gs <- readRDS("pdb/depGraph-CRAN.rds")

# Remove all nodes with fewer than 50 edges

removeLowDegree <- function(g, threshold, mode = "out"){
  deg <- degree(g, mode = mode)
  idx <- names(which(deg > threshold))
  induced.subgraph(g, idx)
  
}

# gn <- removeLowDegree(gs, 1)


set.seed(42)
cl <- walktrap.community(gs, steps = 5)
str(cl$membership)

# Contract vertices
E(gs)$weight <- 1
V(gs)$weight <- 1
gcon <- contract.vertices(gs, cl$membership, 
                          vertex.attr.comb = list(weight = "sum", name = function(x)x[1], "ignore"))


gcon <- simplify(gcon, edge.attr.comb = list(weight = "sum", function(x)length(x)))
1
gcon
table(degree(gcon))
# plot(gc)


deg <- degree(gcon, mode = "all")
idx <- names(which(deg > 20))
gcc <- induced.subgraph(gcon, idx)
table(degree(gcc))
# plot.igraph(gcc)


#  ------------------------------------------------------------------------


# Extract into data frame and plot
library(visNetwork)
library(magrittr)

V(gcc)$size <- degree(gcc)

gd <- get.data.frame(gcc, what = "both" )
nodes <- with(gd[["vertices"]],
              data.frame(
                id =  name,
                size =  size
              ))

visNetwork(
  nodes = nodes, 
  edges = gd[["edges"]],
  height = 600,
  width = "100%"
) %>% 
  visPhysics(timestep = 0.03) %>% 
  visOptions(highlightNearest = TRUE)
