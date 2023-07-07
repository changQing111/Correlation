suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(VennDiagram))

parser <- OptionParser(description = "VennDiagram")
parser <- add_option(parser, c("--set1"), type = "integer", help="set1 size")
parser <- add_option(parser, c("--set2"), type = "integer", help="set2 size")
parser <- add_option(parser, c("--inter"), type = "integer", help="inter size cannot greater than 676")
parser <- add_option(parser, c("-o", "--out"), help="out file prefix")
parse <- parse_args(parser)
s1 <- parse$set1
s2 <- parse$set2
inter <- parse$inter
out_f <- parse$out

all_comb <- vector()
#inter_set <- letters[1:inter]
for(i in letters[1:26]) {
  for(j in letters[1:26]) {
    all_comb <- c(all_comb, paste0(i, j))
  }
}

inter_set <- all_comb[1:inter]  
tmp1 <- 1:(s1 - inter)
tmp2 <- (s1 - inter + 1):(s1 - inter + (s2-inter))

venn.diagram(x=list(c(tmp1, inter_set), c(tmp2, inter_set)), 
             category.names = c("kssd", "metaphlan3"),
             cat.dist = 0.03,
             cat.pos = -180,
             cat.cex = 1.5,
             cex = 1.5,
             col = c("red", "yellow"),
             fill = c("red", "yellow"),
             filename = paste0(out_f, ".png"))
