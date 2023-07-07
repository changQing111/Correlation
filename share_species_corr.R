suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(optparse))

parser <- OptionParser(description = "seek share species intersection")
parser <- add_option(parser, c("--c1"), help="corr1")
parser <- add_option(parser, c("--c2"), help="corr2")
parser <- add_option(parser, c("-o", "--out"),  help="out file name")

parse <- parse_args(parser)
kssd_corr_f <- parse$c1
metap_corr_f <- parse$c2
out <- parse$out

get_kmer <- function(string, k=3) {
  string <- strsplit(string, "")[[1]]
  n <- length(string) - k + 1
  kmer_v <- vector(length = n)
  for(i in 1:n) {
    kmer_v[i] <- string[i:(i+k-1)] %>% str_flatten()
  }
  return(kmer_v)
}

jaccard <- function(set1, set2) {
  union_len <- base::union(set1, set2) %>% length()
  inter_len <- base::intersect(set1, set2) %>% length()
  return(inter_len/union_len)
}


cirr_y_kssd <- read.csv(kssd_corr_f, header = T)
species1 <- paste(cirr_y_kssd$from, cirr_y_kssd$to)

cirr_y_metap <- read.csv(metap_corr_f, header =  T)
species2 <- paste(cirr_y_metap$from, cirr_y_metap$to)

kmer_1 <- lapply(species1, get_kmer)
kmer_2 <- lapply(species2, get_kmer)

df <- data.frame()  
for(i in seq_along(kmer_1)) {
  for(j in seq_along(kmer_2)) {
    if(jaccard(kmer_1[[i]], kmer_2[[j]]) > 0.7 ) {
      df <- rbind(df, cbind(cirr_y_kssd[i,], cirr_y_metap[j,]))  
    }
  }
}
if(length(names(df))==8) {
  names(df) <- c("kssd_from", "kssd_to", "kssd_corr", "kssd_pvalue", 
                 "metaphlan_from", "metaphlan_to", "metaphlan_corr", "metaphlan_pvalue")
} else{
  names(df) <- c("kssd_from", "kssd_to", "kssd_corr",  
                 "metaphlan_from", "metaphlan_to", "metaphlan_corr")
}

write.csv(df, out, quote = F, row.names = F)