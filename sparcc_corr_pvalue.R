suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(optparse))

parser <- OptionParser(description = "SparCC corrleation pvalue")
parser <- add_option(parser, c("-c", "--corr"), help="SprCC corrletion file")
parser <- add_option(parser, c("-i", "--ncbi_id"), help="NCBI id")
#parser <- add_option(parser, c("-t", "--tools"), help="kssd or metaphlan3")
parser <- add_option(parser, c("-p", "--pvalue"), help="SprCC pvalue file")
parser <- add_option(parser, c("--corr_num"), type="double", default=0.3, help="correlation")
parser <- add_option(parser, c("-o", "--out"),  help="out file name prefix")

parse <- parse_args(parser)
corr_fname <- parse$corr
species_f <- parse$ncbi_id
#tool <- parse$tools
pvalue_f <- parse$pvalue
corr_num <- parse$corr_num
out_f <- parse$out

suffix <- corr_fname %>% str_sub(-3, -1)
if(suffix == "csv") {
  corr_f <- read.csv(corr_fname, row.names = 1, header = T)
  pvalue_df <- read.csv(pvalue_f, row.names = 1, header = T)
} else {
  corr_f <- read.table(corr_fname, row.names = 1, header = F)
  pvalue_df <- read.table(pvalue_f, row.names = 1, header = F)
}

sp <- read_tsv(species_f, col_names = c("num", "species"))

species <- sp$species

mat_df <- function(mat, col_name) {
  row.names(mat) <- col_name
  colnames(mat) <- col_name
  mat[lower.tri(mat, diag = T)]=NA
  ind <- which(is.na(mat)==F,arr.ind = T)
  df <- data.frame(from = colnames(mat)[ind[,1]], 
                   to = colnames(mat)[ind[,2]], corr = mat[ind],stringsAsFactors = F)
  return(df)
}
corr_df <- mat_df(corr_f, species)

corr_df$pvalue <- mat_df(pvalue_df, species)[,3]

result <- corr_df %>% filter(abs(corr) > corr_num, pvalue < 0.05)

write.csv(result, paste0(out_f, ".csv"), quote = F, row.names = F)
