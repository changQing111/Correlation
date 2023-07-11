suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(optparse))

parser <- OptionParser(description = "get species reads counts")
parser <- add_option(parser, c("-l", "--list"), help="disease list")
parser <- add_option(parser, c("-d", "--dir"), help="profile dir")
parser <- add_option(parser, c("-n", "--num"), help="reads num")
parser <- add_option(parser, c("-t", "--tool"),  help="tool name")
parser <- add_option(parser, c("-o", "--out"),  help="out dir name")

parse <- parse_args(parser)

# receiving args
disease_li <- parse$list
disease_profile_dir <- parse$dir
nreads_f <- parse$num
tools <- parse$tool
outdir <- parse$out

if(tools=="kssd") {
  colname <- c("ratio", "superkingdom", "phylum", "class", "order", "family", "genus", "species")
} else {colname <- c("species", "ratio")}


run_li <- read_tsv(disease_li, col_names = c("run_accession"))
#disease_profile_dir <- "cirrhosis_PRJEB6337_thr_12/"
metaph_cirr_li <- lapply(paste0(disease_profile_dir,
                                run_li$run_accession, ".txt"), 
                         function(x) {read_tsv(x, col_names =colname)})
#nreads_f <- "metaphlan3/cirrhosis_PRJEB6337_nreads.txt"
metaph_cirr_nreads <- read_csv(nreads_f, col_names = "num")

for(i in seq_along(metaph_cirr_li)) {
  metaph_cirr_li[[i]]$ratio <- metaph_cirr_li[[i]]$ratio * metaph_cirr_nreads$num[i]
}

if(!dir.exists(outdir)) {
  dir.create(outdir)
}

for(i in seq_along(metaph_cirr_li)) {
  write.table(metaph_cirr_li[[i]], 
              file = paste0(outdir, "/", run_li$run_accession[i], ".txt"),
              quote = F, row.names = F, col.names = F, sep = "\t")
}
