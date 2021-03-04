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

# paths
input <- commandArgs(trailingOnly=T)[1]
# input <- "/netscratch/dep_psl/grp_psl/ThomasN/MEME_suite/210201project5002rgi/HiSat50/ame_combined_transcription-summary.txt"
map_path <- "/netscratch/dep_psl/grp_psl/ThomasN/resources/Ath_TF_list"

# load
tab <- read.table(file=input,    header=T, sep="\t", row.names=NULL, stringsAsFactors=F)
map <- read.table(file=map_path, header=T, sep="\t", row.names=NULL, stringsAsFactors=F)

# merge
idx <- match(toupper(tab$motif_alt_ID), toupper(map$Gene_ID))
tab$Family <- map$Family[idx]

idx <- is.na(tab$Family)
tab$Family[idx] <- ""

# export
write.table(tab, file=input, col.names=T, row.names=F, sep="\t", quote=F)
