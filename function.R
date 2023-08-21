read_gold_std <- function(file_name) {
  gold_profile <- read_tsv(file_name, col_names = F)
  gold_profile <- gold_profile %>% select(X1, X5) 
  names(gold_profile) <- c("ncbi_id", "ratio")
  return(gold_profile)
}

read_metaphlan <- function(file_name) {
  metaphlan_profile <- read_tsv(file_name, col_names = F)
  ncbi_id <- lapply(metaphlan_profile$X2, function(x) {(x %>% strsplit("[|]"))[[1]][7]}) %>% unlist() %>% as.numeric()
  metaphlan_profile <- tibble(ncbi_id=ncbi_id, ratio=metaphlan_profile$X3)
  return(metaphlan_profile)
}

read_profile <- function(file_name, tool) {
  if(tool=="metaphlan") {
    species_profile <- read_metaphlan(file_name)
  } else {
    species_profile <- read_gold_std(file_name)
  }
  return(species_profile)
}

containment <- function(profile_1, profile_2) {
  #ncbi_id_union <- union(profile_1$ncbi_id, profile_2$ncbi_id) %>% length()
  ncbi_id_inter <- intersect(profile_1$ncbi_id, profile_2$ncbi_id) %>% length()
  diff_ncbi_id <- nrow(profile_2) - ncbi_id_inter 
  c_index <- round(diff_ncbi_id/nrow(profile_2), 3)
  return(c_index)
}

L1_norm <- function(profile_1, profile_2, type="intersect") {
  names(profile_1)[2] <- "golden"
  names(profile_2)[2] <- "other"
  if(type=="intersect") {
    profile <- merge(profile_1, profile_2, by="ncbi_id")  
  } else {
    profile <- full_join(profile_1, profile_2, by="ncbi_id")
    profile[, 2][is.na(profile[,2])]  <- 0
    profile[, 3][is.na(profile[,3])]  <- 0
  }
  err <- (abs(profile[,2] - profile[,3]) / 100) %>% sum() 
  return(err)
}

reads_num <- function(profile_df, num) {
  profile_df$ratio <- floor(profile_df$ratio*num/100) 
  return(profile_df)
}

plot_venn <- function(set1, set2, n1, n2, out_f) {
  venn.diagram(x=list(set1, set2), 
               category.names = c(n1, n2),
               cat.dist = 0.03,
               cat.pos = -180,
               cat.cex = 1.5,
               cex = 1.5,
               col = c("red", "yellow"),
               fill = c("red", "yellow"),
               filename = paste0(out_f, ".png"))
}

norm_sample <- function(profile_li) {
  for(i in 1:length(profile_li)) {
    profile_li[[i]]$ratio <- profile_li[[i]]$ratio/sum(profile_li[[i]]$ratio)*100
  }
  return(profile_li)
}

my_theme <- theme(panel.background = element_blank(), 
                  legend.key = element_blank(),
                  legend.title=element_blank(),
                  plot.title = element_text(hjust = 0.5),
                  axis.text.x = element_text(size = 12, colour = "black"),
                  axis.title.x = element_text(size=14),
                  axis.text.y = element_text(size=12, colour = "black"),
                  axis.title.y = element_text(size=14),
                  strip.text.x = element_text(size = 14), 
                  panel.border = element_rect(colour = "black", fill=NA, linewidth = 1))

plot_box <- function(df, y_title="", main_title="") {
  p <- ggplot(df, aes(x=metric, y=number, fill=tools)) +
    geom_boxplot(width=0.5,position=position_dodge(0.9), alpha=0.5, outlier.shape = NA) +
    geom_jitter(aes(colour=tools), position = position_jitterdodge(dodge.width = 0.9), size=1) +
    labs(x="", y=y_title, title = main_title) +
    my_theme
  return(p)
}
