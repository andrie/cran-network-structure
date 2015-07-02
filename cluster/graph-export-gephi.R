## Determine CRAN package clusters (communities)


library(miniCRAN)
library(igraph)
library(magrittr)


# Download matrix of available packages at specific date ------------------

repo <- c("CRAN", "BIOC")
repo <- repo[1]

pdbFile   <- sprintf("pdb/pdb-%s.rds", repo)
graphFile <- sprintf("pdb/depGraph-%s.rds", repo)
outfile   <- sprintf("%s.GraphML", repo)
walktrap.steps <- 5

p <- readRDS(pdbFile)
gs <- readRDS(graphFile)


# Use the page.rank algorithm in igraph -----------------------------------

pr <- gs %>%
  page.rank(directed = TRUE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")


# Determine communities using walktrap algorithm --------------------------

set.seed(42)
cl <- walktrap.community(gs, steps = walktrap.steps)

topClusters <- table(cl$membership) %>% 
  sort(decreasing = TRUE) %>% 
  head(10)

topClusters[1:10]
plot(topClusters, main="Cluster size", ylab="Number of members", type="b", lwd=2)

# Compute page rank

pr <- gs %>%
  page.rank(directed = FALSE) %>%
  use_series("vector") %>%
  sort(decreasing = TRUE) %>%
  as.matrix %>%
  set_colnames("page.rank")

# Create combined graph with pagerank and community -----------------------

cl$page.rank <- pr[match(cl$names, rownames(pr)), 1]
cl$page.rank %>% sort(decreasing = TRUE) %>% head
cl$cluster <- unname(ave(cl$page.rank, cl$membership, 
                           FUN=function(x)names(x)[which.max(x)])
                           )

topGroups <- sort(table(cl$cluster), decreasing = TRUE)[1:10]
head(cl$cluster)
cl$cluster[!cl$cluster %in% names(topGroups)] <- "Other"
sort(table(cl$cluster), decreasing = TRUE)
V(gs)$cluster <- cl$cluster
V(gs)$page.rank <- cl$page.rank

# Analyse clusters --------------------------------------------------------

# Helper function to extract names of a specific cluster
clusterMembers <- function(i, clusters, pagerank, n=10){
  group <- clusters$names[clusters$membership == i]
  pagerank[group, ] %>% sort(decreasing = TRUE) %>% head(n)
}

# Display members of cluster "3"
clusterMembers(1, cl, pr)
clusterMembers("ape", cl, p)
clusterMembers(3, cl, pr, n = 1)

# Display members of top 10 clusters
z <- lapply(names(topClusters)[1:10], clusterMembers, clusters=cl, pagerank=pr, n=20)
z

table(cl$cluster)

# Export to excel

# write.table(file="clipboard", as.data.frame(sapply(z, names)), sep="\t", row.names= FALSE)
write.table(file="clipboard", data.frame(package = head(rownames(pr), 10), pagerank = head(pr, 10)), sep="\t", row.names= FALSE)



# Keep only some nodes

toKeep <- V(gs)[degree(gs) > 1]

vids <- V(gs)[toKeep]
gs <- induced.subgraph(gs, vids = toKeep)



write.graph(gs, file=outfile, format="graphml")