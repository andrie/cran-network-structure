library(igraph)
# ?page.rank

set.seed(1)

g <- random.graph.game(5, 0.3, directed=TRUE)
set.seed(42); plot(g, main = "Randomly generated graph")
page.rank(g)$vector

g$page.rank <- page.rank(g)$vector

set.seed(42); plot(g, vertex.size =  100 * g$page.rank, 
                   main = "Simple graph with vertex size\nproportional to page.rank")
