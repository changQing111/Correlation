suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(Rcpp)) 

parser <- OptionParser(description = "intersection ratio")
parser <- add_option(parser, c("-l", "--links"), help="different links file, sep=, ")
parser <- add_option(parser, c("-s", "--species"), help="different species file, sep=, ")
parser <- add_option(parser, c("-n", "--name_list"), default = "kssd,metaphlan4", 
                     help="different name, sep=, default:kssd,metaphlan4")
parser <- add_option(parser, c("-p", "--prefix"), help="file name prefix")
parser <- add_option(parser, c("-o", "--out_dir"), help="out dir")
parse <- parse_args(parser)
links_li <- parse$links
species_li <- parse$species
n_li <- parse$name_list
n_prefix <- parse$prefix
outdir <- parse$out_dir

#print("hello")
links_f <- str_split(links_li, ",") %>% unlist()
#print(links_f)
#species_li="fastspar_difference_cohort/kssd_s7/cirrhosis_species.txt,fastspar_difference_cohort/metaphlan4/cirrhosis_species.txt"
species_f <- str_split(species_li, ",") %>% unlist()
#print(species_f)
tools_n <- str_split(n_li, ",") %>% unlist()
#print(tools_n)
#n_li <- c("kssd", "metaphlan4")
# read links
links_li <- lapply(links_f, function(x) {read_csv(x, col_names = T)})
names(links_li) <- tools_n

# read species
species_li <- lapply(species_f, function(x) {read_tsv(x, col_names = c("num", "species"))})
names(species_li) <- tools_n

# shape kssd and metaphlan4 species names
kssd_links <- links_li[["kssd"]]
kssd_links$from <- lapply(kssd_links$from, function(x) {sub("[0-9]+_?", "", x)}) %>% unlist()
kssd_links$to <- lapply(kssd_links$to, function(x) {sub("[0-9]+_?", "", x)}) %>% unlist()
kssd_species <- species_li[["kssd"]]$species
kssd_species <- lapply(kssd_species, function(x) {sub("[0-9]+_?", "", x)}) %>% unlist()

#nrow(metaphlan_links)
# read metaphlan4 links
metaphlan_links <- links_li[["metaphlan4"]]

replace_sp <- function(sp) {
  sim_sp <- sub("k__.+s__", "", sp)
  last_sp <- sub("_", " ", sim_sp)
  return(last_sp)
} 
metaphlan_links$from <- lapply(metaphlan_links$from, function(x) {replace_sp(x)}) %>% unlist()
metaphlan_links$to <- lapply(metaphlan_links$to, function(x) {replace_sp(x)}) %>% unlist()
metaphlan_species <- species_li[["metaphlan4"]]$species
metaphlan_species <- lapply(metaphlan_species, function(x) {replace_sp(x)}) %>% unlist()
# sort links
get_sort_links <- function(links_df) {
  links <- vector(length = nrow(links_df))
  for(i in 1:nrow(links_df)) {
    sort_link <- sort(c(links_df$from[i], links_df$to[i]))
    links[i] <- paste(sort_link[1], sort_link[2]) 
  }
  return(links)
}

kssd_links$links <- get_sort_links(kssd_links)
metaphlan_links$links <- get_sort_links(metaphlan_links)
#kssd_links %>% head()
#metaphlan_links %>% head()

# get kssd and metaphlan4 same links
get_kmer <- function(string, k=5) {
  string <- strsplit(string, "")[[1]]
  n <- length(string) - k + 1
  kmer_v <- vector(length = n)
  for(i in 1:n) {
    kmer_v[i] <- string[i:(i+k-1)] %>% str_flatten()
  }
  return(kmer_v)
}

#jaccard <- function(set1, set2) {
#  union_len <- base::union(set1, set2) %>% length()
#  inter_len <- base::intersect(set1, set2) %>% length()
#  return(inter_len/union_len)
#}

kssd_kmer_li <- lapply(kssd_links$links, get_kmer)
metaphlan_kmer_li <- lapply(metaphlan_links$links, get_kmer)
kssd_species_li <- lapply(kssd_species, get_kmer)
metaphlan_species_li <- lapply(metaphlan_species, get_kmer)

sourceCpp("./quick_seek_same_links.cpp")
#my_jaccard(kssd_kmer_li[[14]], metaphlan_kmer_li[[6]])
len <- max(length(metaphlan_kmer_li), length(kssd_kmer_li))
index_kssd <- rep(0, len) 
index_metaphlan <- rep(0, len)
#start_time <- Sys.time()  
seek_same_links(kssd_kmer_li, metaphlan_kmer_li, length(kssd_kmer_li), length(metaphlan_kmer_li), index_kssd, index_metaphlan)
#end_time <- Sys.time() 
#end_time - start_time # Time difference of 39.36217 mins # Time difference of 9.74962 mins
len <- max(length(kssd_species_li), length(metaphlan_species_li))
index_kssd_sp <- rep(0, len)
index_metaphlan_sp <- rep(0, len)
seek_same_links(kssd_species_li, metaphlan_species_li, length(kssd_species_li), length(metaphlan_species_li), index_kssd_sp, index_metaphlan_sp)

tmp <- function() {
  start_time <- Sys.time() 
  n <- 0
  for(i in seq_along(kssd_kmer_li)) {
    for(j in seq_along(metaphlan_kmer_li)) {
      if(jaccard(kssd_kmer_li[[i]], metaphlan_kmer_li[[j]]) > 0.85) {
        n <- n + 1
        index_kssd[n] <- i
        index_metaphlan[n] <- j
      }
    }
  }
  end_time <- Sys.time()
  end_time - start_time 
}

kssd_sub <- kssd_links[index_kssd[which(index_kssd!=0)],] %>% select(-links) 
names(kssd_sub) <- paste0("kssd_",names(kssd_sub))  
metaphlan_sub <- metaphlan_links[index_metaphlan[which(index_metaphlan!=0)],] %>% select(-links) 
names(metaphlan_sub) <- paste0("metaphlan_", names(metaphlan_sub))
sub_same_links <- cbind(kssd_sub, metaphlan_sub) 

sub_kssd_sp <- kssd_species[index_kssd_sp[which(index_kssd_sp!=0)]]
sub_metaphlan_sp <- metaphlan_species[index_metaphlan_sp[which(index_metaphlan_sp!=0)]]
sub_same_species <- data.frame(kssd=sub_kssd_sp, metaphlan4=sub_metaphlan_sp) 

if(!dir.exists(outdir)) {
  dir.create(outdir)
}
same_links_n <- paste0(outdir, "/", n_prefix, "_", "kssd_metaphlan4_links.csv")
write.csv(sub_same_links, same_links_n, row.names = F, quote = F)

same_sp_n <- paste0(outdir, "/", n_prefix, "_", "kssd_metaphlan4_species.csv")
write.csv(sub_same_species, same_sp_n, row.names = F, quote = F)
