bioc <- local({
  env <- new.env()
  on.exit(rm(env))
  evalq(source("http://bioconductor.org/biocLite.R", local=TRUE), env)
  biocinstallRepos()
})

bioc
bioc[grep("BioC", names(bioc))]


# index <- function(url, type="source", filters=NULL, head=5, cols=c("Package", "Version")){
#   contribUrl <- contrib.url(url, type=type)
#   p <- available.packages(contribUrl, type=type, filters=filters)
#   p[1:head, cols]
# }
# 
# index(bioc["BioCsoft"])

url <- bioc["BioCsoft"]
type <- "source"
contribUrl <- contrib.url(url, type=type)
p <- available.packages(contribUrl, type=type)
head(p)

saveRDS(p, "pdb/pdb-BIOC.rds")


#  ------------------------------------------------------------------------

pdb <- readRDS("pdb/pdb-BIOC.rds")

g <- pdb[, "Package"] %>%
  makeDepGraph(availPkgs = pdb, suggests=FALSE, enhances=TRUE, includeBasePkgs = FALSE)

saveRDS(g, file = "pdb/depGraph-BIOC.rds")
