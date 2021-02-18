# MEME_suite

bash script to run AME and DREME using the MEME suite for given gene clusters  
Originally by Ryohei Thomas Nakano; nakano@mpipz.mpg.de  
17 Feb 2021  

usage:  
1) Copy config file to your local data directory and edit it as necessary  
2) Log in to an HPC cluster node  
3) Activate LSF system by lsfenv  
4) Initiate the pipeline by:  
   /biodata/dep_psl/grp_psl/ThomasN/scripts/MEME_custom/ame.sh /path/to/your/config/ame_config.sh  
5) Once all done, process the result files by:  
   /biodata/dep_psl/grp_psl/ThomasN/scripts/MEME_custom/ame_post.sh /path/to/your/config/ame_config.sh  
