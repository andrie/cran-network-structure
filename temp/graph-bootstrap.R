library(igraph)
gc <- readRDS("pdb/depGraph-CRAN.rds")
gb <- readRDS("pdb/depGraph-BioC.rds")


# graph bootstrap ---------------------------------------------------------

boot.graph <- function(graph, f, n = 1000, size = 500, replace = TRUE, ...){
  one <- function(){
    idx <- sample(V(graph)$name, size, replace = replace)
    sub <- induced.subgraph(graph, idx)
    match.fun(f)(sub, ...)
  }
  replicate(n, one())
  
}


md <- boot.graph(gc, function(x)mean(degree(x)))
hist(md, breaks = 50)

md <- boot.graph(gc, assortativity.degree, directed = FALSE)
hist(md, breaks = 50)

md <- boot.graph(gc, transitivity)
hist(md, breaks = 50)

md <- boot.graph(gb, transitivity)
hist(md, breaks = 50)


#  ------------------------------------------------------------------------


boot.multi.graph <- function(g1, g2, f, n = 1000, size = 500, replace = TRUE, ...){
  mc <- match.call()
  gnames <- c(mc[[2]], mc[[3]]) # Extract names of graphs as passed to function
  ret <- lapply(list(g1, g2), boot.graph, f = f, n = n, size = size, replace = replace, ...)
  names(ret) <- gnames
  class(ret) <- "graph.multi.bootstrap"
  ret
}

graph.ks.test <- function(g){
  ks <- ks.test(g[[1]], g[[2]])
  ks$data.name <- paste(names(g), sep = "and")
  ks
}


#  ------------------------------------------------------------------------


x <- boot.multi.graph(gc, gb, f = assortativity.degree)
str(x)
graph.ks.test(x)


x <- boot.multi.graph(gc, gb, f = transitivity)
graph.ks.test(x)


#  ------------------------------------------------------------------------

x <- rnorm(50)
y <- runif(30)
# Do x and y come from the same distribution?
ks.test(x, y)
# Does x come from a shifted gamma distribution with shape 3 and rate 2?
ks.test(x+2, "pgamma", 3, 2) # two-sided, exact
ks.test(x+2, "pgamma", 3, 2, exact = FALSE)
ks.test(x+2, "pgamma", 3, 2, alternative = "gr")
