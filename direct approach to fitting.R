suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(combinat))

parser <- OptionParser(description = "get species and species intersection")
parser <- add_option(parser, c("-p", "--profile"), help="run profile")
parser <- add_option(parser, c("-s", "--species"), help="num mapping species")
parser <- add_option(parser, c("-c", "--correlation"), type="double", default=0.7, help="correlation")
parser <- add_option(parser, c("-t", "--tool"),  help="tool name")
parser <- add_option(parser, c("-o", "--out"),  help="out file name prefix")

parse <- parse_args(parser)
profile_fname <- parse$profile
species_f <- parse$species
corr_num <- parse$correlation
tools <- parse$tool
out_f <- parse$out

profile_f <- read.table(profile_fname, row.names = 1, header = T)
num <- nrow(profile_f)
all_comb <- combn(1:num, 2) 
comb_li <- vector("list", length = ncol(all_comb))
for(i in seq_along(comb_li)) {
  comb_li[[i]] <- all_comb[, i]
} 

get_corr_pvalue <- function(v1, v2) {
  corr <- cor(v1, v2)
  df <- lm(v1 ~ v2) %>% summary()
  pvalue <- df$coefficients[2,4]
  return(c(corr, pvalue))
}
  
corr_pvalue_li <- lapply(comb_li, function(x) {get_corr_pvalue(profile_f[x[1],] %>% as.numeric(), 
                                                             profile_f[x[2],] %>% as.numeric())})

from <- lapply(comb_li, function(x) {x[1]-1}) %>% unlist()
to <- lapply(comb_li, function(x) {x[2]-1}) %>% unlist()
corr <- lapply(corr_pvalue_li, function(x) {x[1]}) %>% unlist()
pvalue <- lapply(corr_pvalue_li, function(x) {x[2]}) %>% unlist()

corr_pvalue_df <- data.frame(from=from, to=to, correlation=corr, pvalue=pvalue)
filter_corr_pvalue_df <- corr_pvalue_df %>% filter(abs(correlation) > corr_num, pvalue<0.01)

num_species <- read_tsv(species_f, col_names = c("num", "species"))

get_num_species <- function(corr_pvalue_df, num_species_df, tool) {
  v_from = vector()
  v_to = vector()
  for(i in 1:nrow(corr_pvalue_df)) {
    from <- num_species_df$species[corr_pvalue_df$from[i]+1]
    to <- num_species_df$species[corr_pvalue_df$to[i]+1]
    if(tool == "kssd") {
      from <- (from %>% str_split(";"))[[1]][7]
      to <- (to %>% str_split(";"))[[1]][7]
    } else {
      from <- (from %>% str_split("s__"))[[1]][2] %>% str_replace("_", " ")
      to <- (to %>% str_split("s__"))[[1]][2] %>% str_replace("_", " ")
    }
    v_from <- append(v_from, from) 
    v_to <- append(v_to, to)
  }
  df <- data.frame(from=v_from, to=v_to, correlation=corr_pvalue_df$correlation, pvalue=corr_pvalue_df$pvalue)
  return(df)
}

# replace node num species
corr_graph_df <- get_num_species(filter_corr_pvalue_df, num_species, tools)
write.csv(corr_graph_df, paste0(out_f, ".csv"), quote = F, row.names = F)
