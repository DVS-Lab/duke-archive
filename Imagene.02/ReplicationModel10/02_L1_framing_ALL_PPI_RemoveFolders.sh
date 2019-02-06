# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
# #$ -m ea
# -- END GLOBAL DIRECTIVE -- 

# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
 
# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
# #$ -M rosa.li@duke.edu
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

EXPERIMENT=~/experiments/Imagene.02

for SUBJ in 10156 10168 10181 10199 10255 10264 10265 10279 10280 10281 10286 10287 10294 10304 10305 10306 10314 10315 10335 10350 10351 10358 10359 10414 10415 10416 10424 10425 10472 10482 10483 10512 10515 10521 10523 10525 10565 10583 10602 10605 10615 10657 10659 10665 10670 10696 10697 10698 10699 10706 10746 10749 10757 10785 10793 10794 10795 10817 10827 10844 10845 10858 10890 11021 11022 11024 11029 11059 11065 11066 11067 11154 11171 11176 11209 11210 11212 11215 11216 11217 11232 11233 11243 11245 11264 11266 11272 11273 11274 11291 11292 11293 11326 11327 11328 11335 11363 11364 11366 11371 11373 11393 11394 11402 11430 11473 11479 11511 11525 11578 11584 11605 11625 11660 11692 11738 11762 11878 11941 11950 12015 12071 12082 12089 12097 12132 12159 12175 12280 12294 12372 12380 12383 12393 12400 12411 12412 12444 12459 12460 12476 12496 12541 12550 12564 12596 12606 12614 12629 12664 12665 12677 12678 12679 12711 12717 12731 12742 12755 12756 12757 12766 12780 12789 12791 12802 12815 12816 12817 12828 12839 12850 12873 12874 12875 12879 12880 12893 12894 12896 12905 12907 12923 12960 12961 12988 12989 13011

do 
  


	    #directory for file removal
	    FILEDIR=${EXPERIMENT}/Analysis/Framing/FSL/${SUBJ}/NoLapses_PPI

	    #clean up unwanted files
	    if [ -e $FILEDIR ]; then
	      rm -r $FILEDIR
	    else
	      echo "$FILEDIR does not exist"
	    fi
	    #ls ${FILEDIR}
     
done


#log directory and files
#LOGDIR=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/NoLapses_PPI/model10/L_iFG_func_5mm/${CON}/run${run}.feat/report_log.html