#!/bin/bash

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

#
set -e
set -o nounset

# load config
config_file=$1
source ${config_file}

# logfiles
export logfile="${out_dir}/log.txt"

log() {
    echo $(date -u)": "$1 >> $logfile
}

# initialization
rm -r -f ${out_dir}
mkdir -p ${out_dir}

# data process
log "START MEME suite custom..."

# create a list of clusters
cat ${cluster_file} | awk 'NR>1{print $1 "\t" $2}' > ${out_dir}/cluster.txt
clusters=`cat ${out_dir}/cluster.txt | awk '{print $2}' | sort -u | awk 'BEGIN{ORS=" "}{print $0}'`

# run the pipeline for each cluster
for cl in ${clusters}; do
	export cl
	bsub -q ioheavy -R "rusage[mem=1200]" -M 2400 -J AME${cl} ${script_dir}/MEME_custom/ame_ind.sh ${config_file}
done














