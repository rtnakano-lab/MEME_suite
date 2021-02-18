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

set -e
set -o nounset

# load config
config_file=$1
source ${config_file}

local_log="${out_dir}/${cl}/log.txt"
local_output="${out_dir}/${cl}/output.txt"
logfile="${out_dir}/log.txt"

# log functions
local_log() {
    echo $(date -u)": "$1 >> ${local_log}
}

log() {
    echo $(date -u)": "$1 >> ${log_file}
}

# setup
mkdir -p ${out_dir}/${cl}/${cl}-PBM_transcription
mkdir -p ${out_dir}/${cl}/${cl}-DAP_transcription
mkdir -p ${out_dir}/${cl}/${cl}-PBM_translation
mkdir -p ${out_dir}/${cl}/${cl}-DAP_translation
mkdir -p ${out_dir}/${cl}/${cl}-DREME_transcription
mkdir -p ${out_dir}/${cl}/${cl}-DREME_translation

log "START: MEME suite for the Cluster $cl"

# create gene list
cat ${out_dir}/cluster.txt | awk -v cl="$cl" '$2 == cl {print $1}' > ${out_dir}/${cl}/genes.txt

# create fasta files
cd ${out_dir}/${cl}
perl ${script_dir}/MPextract_seq-flex.pl ${source}/TAIR10/TAIR10_upstream_1000_20101104.fasta genes.txt transcription.fasta
perl ${script_dir}/MPextract_seq-flex.pl ${source}/TAIR10/TAIR10_upstream_1000_translation_start_20101028.fasta genes.txt translation.fasta

local_log "Cluster $cl; ame, transcription initiation sites, PBM"
ame --oc ${out_dir}/${cl}/${cl}-PBM_transcription --control ${source}/TAIR10/TAIR10_upstream_1000_20101104-nuc.fasta ${out_dir}/${cl}/transcription.fasta ${motif_dir}/ArabidopsisPBM_20140210.meme &>> ${local_output}

local_log "Cluster $cl; ame, transcription initiation sites, DAP"
ame --oc ${out_dir}/${cl}/${cl}-DAP_transcription --control ${source}/TAIR10/TAIR10_upstream_1000_20101104-nuc.fasta ${out_dir}/${cl}/transcription.fasta ${motif_dir}/ArabidopsisDAPv1.meme &>> ${local_output}

local_log "Cluster $cl; ame, translation initiation sites, PBM"
ame --oc ${out_dir}/${cl}/${cl}-PBM_translation --control ${source}/TAIR10/TAIR10_upstream_1000_translation_start_20101028-nuc.fasta ${out_dir}/${cl}/translation.fasta ${motif_dir}/ArabidopsisPBM_20140210.meme &>> ${local_output}

local_log "Cluster $cl; ame, translation initiation sites, DAP"
ame --oc ${out_dir}/${cl}/${cl}-DAP_translation --control ${source}/TAIR10/TAIR10_upstream_1000_translation_start_20101028-nuc.fasta ${out_dir}/${cl}/translation.fasta ${motif_dir}/ArabidopsisDAPv1.meme &>> ${local_output}

local_log "Cluster $cl; DREME, transcription initiation sites"
dreme -oc ${out_dir}/${cl}/${cl}-DREME_transcription -n ${source}/TAIR10/TAIR10_upstream_1000_20101104-nuc.fasta -p transcription.fasta -png &>> ${local_output}

local_log "Cluster $cl; DREME, translation initiation sites"
dreme -oc ${out_dir}/${cl}/${cl}-DREME_translation -n ${source}/TAIR10/TAIR10_upstream_1000_translation_start_20101028-nuc.fasta -p translation.fasta -png &>> ${local_output}

log "DONE: MEME suite for the Cluster $cl"

