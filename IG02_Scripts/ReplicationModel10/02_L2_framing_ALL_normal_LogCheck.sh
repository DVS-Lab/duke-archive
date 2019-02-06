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
OUTDIR=${EXPERIMENT}/Analysis/Framing/Logs/01Replication_RL/OutputCheck

for SUBJ in 10156 10168 10181 10199 10255 10264 10265 10279 10280 10281 10286 10287 10294 10304 10305 10306 10314 10315 10335 10350 10351 10358 10359 10414 10415 10416 10424 10425 10472 10482 10483 10512 10515 10521 10523 10525 10558 10560 10565 10583 10602 10605 10657 10659 10665 10670 10697 10698 10699 10706 10746 10749 10757 10785 10793 10795 10817 10827 10844 10845 10890 11021 11022 11024 11029 11059 11065 11066 11067 11171 11176 11209 11212 11215 11216 11217 11232 11243 11245 11264 11266 11272 11273 11291 11292 11293 11326 11327 11328 11335 11363 11364 11366 11371 11373 11393 11394 11402 11430 11473 11479 11511 11545 11578 11584 11605 11625 11660 11692 11738 11762 11941 11950 12015 12071 12082 12089 12097 12159 12175 12280 12294 12372 12380 12383 12393 12400 12411 12412 12444 12459 12460 12476 12496 12541 12550 12564 12596 12606 12614 12629 12664 12677 12678 12679 12711 12717 12731 12742 12755 12756 12757 12766 12780 12791 12802 12815 12816 12817 12828 12839 12850 12873 12874 12875 12879 12880 12893 12894 12896 12905 12907 12923 12960 12961 12988 12989 13011 10387 10705 10747 10762 11196 11210 11274 11383 12165 12360 12665 12758 12789 10352 10707 11235 10524 10615 10696 10783 10794 10858 11233 11602 12132 12551 10426 10782 11058 11372 11659 11865 11878 12768 12840 12176 10360 10474 12314

do 
	    CONFILEDIR=${EXPERIMENT}/Analysis/Framing/FSL/${SUBJ}/NoLapses_RL/model10.gfeat/report_log.html
  echo "Sub $SUBJ" >> ${OUTDIR}/L2.txt
      for GO in 1 2
      do
	for COPE in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
	do

	    #directory for feat logs
	    COPEFILEDIR=${EXPERIMENT}/Analysis/Framing/FSL/${SUBJ}/NoLapses_RL/model10.gfeat/cope${COPE}.feat/report_log.html
	 
	    echo "$GO, $COPE" >> ${OUTDIR}/L2.txt

	    grep "ERROR" $CONFILEDIR >> ${OUTDIR}/L2.txt
	    grep "Warning" $CONFILEDIR >> ${OUTDIR}/L2.txt
	    grep "WARNING" $CONFILEDIR >> ${OUTDIR}/L2.txt
	    grep "ERROR" $COPEFILEDIR >> ${OUTDIR}/L2.txt
	    grep "Warning" $COPEFILEDIR >> ${OUTDIR}/L2.txt
	    grep "WARNING" $COPEFILEDIR >> ${OUTDIR}/L2.txt




	    #ls ${FILEDIR}
	done
      done
done


#log directory and files
#LOGDIR=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}/NoLapses_PPI/model10/L_iFG_func_5mm/${CON}/run${run}.feat/report_log.html