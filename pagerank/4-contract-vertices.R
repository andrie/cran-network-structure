library(igraph)

# Download prepared igraph file from github
gs <- readRDS("pdb/depGraph-CRAN.rds")


set.seed(42)
# Compute communities (clusters)
cl <- walktrap.community(gs, steps = 5)
cl$degree <- (degree(gs)[cl$names])

# Assign node with highest degree as name for each cluster
cl$cluster <- unname(ave(cl$degree, cl$membership, 
                         FUN=function(x)names(x)[which.max(x)])
)
V(gs)$name <- cl$cluster

# Contract graph ----------------------------------------------------------

# Contract vertices
E(gs)$weight <- 1
V(gs)$weight <- 1
gcon <- contract.vertices(gs, cl$membership, 
                          vertex.attr.comb = list(weight = "sum", name = function(x)x[1], "ignore"))

# Simplify edges
gcon <- simplify(gcon, edge.attr.comb = list(weight = "sum", function(x)length(x)))

gcc <- induced.subgraph(gcon, V(gcon)$weight > 20)
V(gcc)$degree <- unname(degree(gcc))

#  ------------------------------------------------------------------------

set.seed(42)
par(mar = rep(0.1, 4)) 
g.layout <- layout.kamada.kawai(gcc)
plot.igraph(gcc, edge.arrow.size = 0.1, layout = g.layout, vertex.size = 0.5 * (V(gcc)$degree))
1


#  ------------------------------------------------------------------------


# # Extract into data frame and plot
#
# library(networkD3)
# library(visNetwork)
# library(magrittr)
# 
# V(gcc)$size <- degree(gcc)
# 
# gd <- get.data.frame(gcc, what = "both" )
# nodes <- with(gd[["vertices"]],
#               data.frame(
#                 id =  name,
#                 size =  size
#               ))
# 
# visNetwork(
#   nodes = nodes, 
#   edges = gd[["edges"]],
#   height = 500,
#   width = 500
# ) %>% 
#   visPhysics(timestep = 0.03) %>% 
#   visOptions(highlightNearest = TRUE)
