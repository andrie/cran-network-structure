## Determine CRAN package clusters (communities)


library(miniCRAN)
library(igraph)
# library(rgexf)
library(magrittr)


# Download matrix of available packages at specific date ------------------

repo <- c("CRAN", "BIOC")
repo <- repo[1]

pdbFile   <- sprintf("pdb/pdb-%s.rds", repo)
graphFile <- sprintf("pdb/depGraph-%s.rds", repo)
outfile   <- sprintf("%s.GraphML", repo)


p <- readRDS(pdbFile)
g <- readRDS(graphFile)


# Use the page.rank algorithm in igraph -----------------------------------

pr <- g %>%
  page.rank(directed = FALSE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")


# Extract top 80% of packages ---------------------------------------------


cutoff <- quantile(pr[, "page.rank"], probs = 0.2)
popular <- pr[pr[, "page.rank"] >= cutoff, ] 
toKeep <- names(popular)


# toKeep <- V(g)[degree(g) > 0]
# 
# vids <- V(g)[toKeep]
# gs <- induced.subgraph(g, vids = toKeep)
# gs

gs <- g

# Determine communities using walktrap algorithm --------------------------

set.seed(42)
cl <- walktrap.community(gs, steps = 5)

# Define ob
topClusters <- table(cl$membership) %>% 
  sort(decreasing = TRUE) %>% 
  head(10)
# names(topClusters)
# names(topClusters) <- LETTERS[seq_along(topClusters)]


topClusters[1:10]
plot(topClusters, main="Cluster size", ylab="Number of members", type="b", lwd=2)


pr <- gs %>%
  page.rank(directed = FALSE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")


# Analyse clusters --------------------------------------------------------

# Helper function to extract names of a specific cluster
cluster <- function(i, clusters, pagerank, n=10){
  group <- clusters$names[clusters$membership == i]
  pagerank[group, ] %>% sort(decreasing = TRUE) %>% head(n)
}

# Display members of cluster "3"
cluster(1, cl, pr)
cluster(3, cl, pr, n = 1)

foo <- setNames(LETTERS[seq_along(topClusters)], 
                as.character(names(topClusters)))
cl$cluster <- as.character(foo[cl$membership])
cl$cluster[is.na(cl$cluster)] <- "Other"

oldClusterNames <- sort(unique(cl$cluster))
newClusterNames <-sapply(names(topClusters), function(x)names(cluster(x, clusters=cl, pagerank=pr, n = 1)), USE.NAMES = FALSE)

newClusterNames
newClusterNames <- c(newClusterNames, "Other")


cl$cluster <- newClusterNames[match(cl$cluster, oldClusterNames)]

# Display members of top 10 clusters
z <- lapply(names(topClusters)[1:10], cluster, clusters=cl, pagerank=pr, n=20)
z

cl$membership

# Export to excel

# write.table(file="clipboard", as.data.frame(sapply(z, names)), sep="\t", row.names= FALSE)


# Create combined graph with pagerank and community -----------------------

pr <- gs %>% page.rank(directed=FALSE) %>% use_series("vector")
V(gs)$page.rank <- pr[V(gs)$name]
V(gs)$community <- paste("cluster ", cl$membership)
V(gs)$cluster <- cl$cluster


toKeep <- V(gs)[degree(gs) > 2]

vids <- V(gs)[toKeep]
gs <- induced.subgraph(gs, vids = toKeep)



write.graph(gs, file=outfile, format="graphml")
