# Different types of random graph -----------------------------------------

library(igraph)

# Preferential attachment
g1 <- aging.prefatt.game(100, pa.exp=1, aging.exp=0, aging.bin=1000)
plot(degree.distribution(g1))
plot(g1)

# Constant degree
g2 <- erdos.renyi.game(100, 1/100)
plot(degree.distribution(g2))
plot(g2)

# Exponential 
g3 <- barabasi.game(100)
plot(degree.distribution(g3))
plot(g3)

igraph:::aging.barabasi.game(100)
