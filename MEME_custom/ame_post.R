#!/netscratch/dep_psl/grp_psl/ThomasN/tools/bin/bin/Rscript

# bash script to run AME and DREME using the MEME suite for given gene clusters
# Originally by Ryohei Thomas Nakano; nakano@mpipz.mpg.de
# 17 Feb 2021

# usage:
# 1) Copy config file to your local data directory and edit it as necessary
# 2) Log in to an HPC cluster node
# 3) Activate LSF system by lsfenv
# 4) Initiate the pipeline by:
#    /biodata/dep_psl/grp_psl/ThomasN/scripts/MEME_custom/ame.sh /path/to/your/config/ame_config.sh
# 5) Once all done, process the result files by:
#    /biodata/dep_psl/grp_psl/ThomasN/scripts/MEME_custom/ame_post.sh /path/to/your/config/ame_config.sh

rm(list=ls())

library(dplyr,   quietly=T, warn.conflicts=F)
library(stringr, quietly=T, warn.conflicts=F)

# paths
input_path   <- commandArgs(trailingOnly=T)[1]
cluster_path <- commandArgs(trailingOnly=T)[2]

# input <- "/netscratch/dep_psl/grp_psl/ThomasN/MEME_suite/210201project5002rgi/HiSat50/ame_combined_transcription-summary.txt"
map_path <- "/netscratch/dep_psl/grp_psl/ThomasN/resources/Ath_TF_list"


# load
tab     <- read.table(file=input_path,   header=T, sep="\t", row.names=NULL, stringsAsFactors=F)
cluster <- read.table(file=cluster_path, header=F, sep="\t", row.names=NULL, stringsAsFactors=F)
map     <- read.table(file=map_path,     header=T, sep="\t", row.names=NULL, stringsAsFactors=F)

# merge
idx <- match(toupper(tab$motif_alt_ID), toupper(map$Gene_ID))
tab$Family <- map$Family[idx]

idx <- is.na(tab$Family)
tab$Family[idx] <- ""

# remove duplicates
tab <- tab %>% group_by(Cluster, motif_alt_ID, Family) %>% summarise(rank=min(rank))

# sort
idx <- order(tab$Cluster, tab$rank)
tab <- tab[idx, c("Cluster", "rank", "motif_alt_ID", "Family")]

tab$Cluster <- factor(tab$Cluster, levels=unique(cluster$V2))
idx <- order(tab$Cluster)
tab <- tab[idx,]

# export
write.table(tab, file=input_path, col.names=T, row.names=F, sep="\t", quote=F)
