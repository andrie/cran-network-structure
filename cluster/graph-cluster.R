## Determine CRAN package clusters (communities)


library(miniCRAN)
library(igraph)
library(magrittr)


# Download matrix of available packages at specific date ------------------

MRAN <- "http://mran.revolutionanalytics.com/snapshot/2014-12-01/"

pdb <- MRAN %>%
  contrib.url(type = "source") %>%
  available.packages(type="source", filters = NULL)


# Use miniCRAN to build a graph of package dependencies -------------------


g <- pdb[, "Package"] %>%
  makeDepGraph(availPkgs = pdb, suggests=FALSE, enhances=TRUE, includeBasePkgs = FALSE)


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

vids <- V(g)[toKeep]
gs <- induced.subgraph(g, vids = toKeep)


# Determine communities using walktrap algorithm --------------------------


cl <- walktrap.community(gs, steps = 3)

# Define ob
topClusters <- table(cl$membership) %>% 
  sort(decreasing = TRUE) %>% 
  head(25)

topClusters[1:10]
plot(topClusters, main="Cluster size", ylab="Number of members", type="b", lwd=2)


# Analyse clusters --------------------------------------------------------

# Helper function to extract names of a specific cluster
cluster <- function(i, clusters, pagerank, n=10){
  group <- clusters$names[clusters$membership == i]
  pagerank[group, ] %>% sort(decreasing = TRUE) %>% head(n)
}

# Display members of cluster "3"
# cluster(3, cl, pr) 

# Display members of top 10 clusters
z <- lapply(names(topClusters)[1:10], cluster, clusters=cl, pagerank=pr, n=20)
z


# Export to excel

write.table(file="clipboard", as.data.frame(sapply(z, names)), sep="\t", row.names= FALSE)

