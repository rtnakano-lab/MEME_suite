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

# logfiles
export logfile="${out_dir}/log.txt"

log() {
    echo $(date -u)": "$1 >> $logfile
}

log "Post processing of MEME results..."

# create a list of clusters
clusters=`cat ${out_dir}/cluster.txt | awk '{print $2}' | sort -u | awk 'BEGIN{ORS=" "}{print $0}'`

# initialization
rm -r -f ${out_dir}/ame_combined_translation_temp.txt
rm -r -f ${out_dir}/ame_combined_transcription_temp.txt 
cp ${script_dir}/MEME_custom/MEME_header.txt ${out_dir}/ame_combined_translation.txt
cp ${script_dir}/MEME_custom/MEME_header.txt ${out_dir}/ame_combined_transcription.txt
cp ${script_dir}/MEME_custom/MEMEsummary_header.txt ${out_dir}/ame_combined_translation-summary.txt
cp ${script_dir}/MEME_custom/MEMEsummary_header.txt ${out_dir}/ame_combined_transcription-summary.txt

# merge
for cl in ${clusters}; do
	ls ${out_dir}/${cl}/*translation/ame.tsv | xargs grep -h -v -e "^#" -e "rank" | awk -v cl=$cl '{print cl "\t" $0}' >> ${out_dir}/ame_combined_translation_temp.txt
	ls ${out_dir}/${cl}/*transcription/ame.tsv | xargs grep -h -v -e "^#" -e "rank" | awk -v cl=$cl '{print cl "\t" $0}' >> ${out_dir}/ame_combined_transcription_temp.txt
done
awk '$3!="" {print $0}' ${out_dir}/ame_combined_translation_temp.txt | sort -u >> ${out_dir}/ame_combined_translation.txt
awk '$3!="" {print $0}' ${out_dir}/ame_combined_transcription_temp.txt | sort -u >> ${out_dir}/ame_combined_transcription.txt

awk '{if(NR>1) print $1 "\t" $2 "\t" $5}' ${out_dir}/ame_combined_translation.txt | sort -u >> ${out_dir}/ame_combined_translation-summary.txt
awk '{if(NR>1) print $1 "\t" $2 "\t" $5}' ${out_dir}/ame_combined_transcription.txt | sort -u >> ${out_dir}/ame_combined_transcription-summary.txt

# clean up
rm -r -f ${out_dir}/ame_combined_translation_temp.txt
rm -r -f ${out_dir}/ame_combined_transcription_temp.txt 


# 
${R_PATH}/Rscript ${script_dir}/MEME_custom/ame_post.R ${out_dir}/ame_combined_translation-summary.txt
${R_PATH}/Rscript ${script_dir}/MEME_custom/ame_post.R ${out_dir}/ame_combined_transcription-summary.txt

# copy to biodata
mkdir -p ${results}
cp ${out_dir}/ame_combined_translation.txt ${results}/
cp ${out_dir}/ame_combined_translation-summary.txt ${results}/

cp ${out_dir}/ame_combined_transcription.txt ${results}/
cp ${out_dir}/ame_combined_transcription-summary.txt ${results}/


log "MEME suite: All Done!!"

