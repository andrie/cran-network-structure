# singleton analysis ------------------------------------------------------

plot(degree.distribution(gc), log = "x", type = "b")
plot(degree.distribution(gb), log = "x", type = "b")

plot(degree.distribution(gc), log = "xy", type = "b")
plot(degree.distribution(gb), log = "xy", type = "b")

degree(gb)
gc


gc[[1:3]]
sum(degree(gb) == 0)
head(degree(gb, mode = "in"), 20)
singletons <- unname(which(degree(gb, mode = "in") == 1))
singletons
x <- gb[[, singletons]]
str(x)
y <- unlist(unname(x))
sort(table(y))
sort(table(V(gb)$name[y]))


