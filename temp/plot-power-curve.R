# Plot power curve

library(igraph)
gcran <- readRDS("pdb/depGraph-CRAN.rds")
gbioc <- readRDS("pdb/depGraph-BioC.rds")


# Plot power curve for degree distribution --------------------------------

degree.distributiond.df <- function(g){
  x <- degree.distribution(g)
  data.frame(degree = seq_along(x) - 1,
             frequency = x)
}


dat <- degree.distributiond.df(gcran)
dat <- dat[dat$frequency > 0, ]

pwr <- function(x){ifelse(x==0, 0, 3 * + x^-2.5475)}
pwr.dat <- data.frame(degree = 5:100, frequency = pwr(5:100))
library(ggplot2)
ggplot(dat[-1, ], aes(x = degree, y = frequency)) + 
  geom_point() + 
  geom_smooth(method = loess) +
  geom_line(data = pwr.dat, aes(x=degree, y=frequency), col = "red") +
  # stat_function(fun = pwr) +
  scale_x_log10() +
  scale_y_log10(limits = c(1e-4, 1))
# coord_trans(y = "log10", x = "log10")


