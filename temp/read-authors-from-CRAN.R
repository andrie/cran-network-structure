# Read authors from CRAN

description <- sprintf("%s/web/packages/packages.rds",
                       getOption("repos")["CRAN"])
con <- if(substring(description, 1L, 7L) == "file://") {
  file(description, "rb")
} else {
  url(description, "rb")
}
db <- as.data.frame(readRDS(gzcon(con)),stringsAsFactors=FALSE)
close(con)
rownames(db) <- NULL

head(db$Author)
head(db$"Authors@R")
str(db)


#  ------------------------------------------------------------------------


getAuthor <- function(x){
  if(is.na(x)) return(NA)
  a <- textConnection(x)
  on.exit(close(a))
  dget(a)
}
authors <- lapply(db$"Authors@R", getAuthor)
head(authors)

missing <- sapply(authors, function(x)any(is.na(x)))
db$Author[missing]
length(which(missing))
head(missing)

authors[[1]] <- "test"

