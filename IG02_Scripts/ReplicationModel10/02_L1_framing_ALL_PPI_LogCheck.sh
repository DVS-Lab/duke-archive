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
OUTDIR=${EXPERIMENT}/Analysis/Framing/Logs/NoLapses_PPI/OutputCheck
EXAMPLEFILEDIR=${EXPERIMENT}/Analysis/Framing/FSL/10156/NoLapses_PPI/model10/lTPJ_charself_5mm/interaction/run1.feat/report_log.html
NoMissWarn=`grep "Warning" $EXAMPLEFILEDIR`

for SUBJ in 10156 10168 10181 10199 10255 10264 10265 10279 10280 10281 10286 10287 10294 10304 10305 10306 10314 10315 10335 10350 10351 10352 10358 10359 10360 10387 10414 10415 10416 10424 10425 10426 10472 10474 10482 10483 10512 10515 10521 10523 10524 10525 10558 10560 10565 10583 10602 10605 10615 10657 10659 10665 10670 10696 10697 10698 10699 10705 10706 10707 10746 10747 10749 10757 10762 10782 10783 10785 10793 10794 10795 10817 10827 10844 10845 10858 10890 11021 11022 11024 11029 11058 11059 11065 11066 11067 11171 11176 11196 11209 11210 11212 11215 11216 11217 11232 11233 11235 11243 11245 11264 11266 11272 11273 11274 11291 11292 11293 11326 11327 11328 11335 11363 11364 11366 11371 11372 11373 11383 11393 11394 11402 11430 11473 11479 11511 11545 11578 11584 11602 11605 11625 11659 11660 11692 11738 11762 11865 11878 11941 11950 12015 12071 12082 12089 12097 12132 12159 12165 12175 12176 12280 12294 12314 12360 12372 12380 12383 12393 12400 12411 12412 12444 12459 12460 12476 12496 12541 12550 12551 12564 12596 12606 12614 12629 12664 12665 12677 12678 12679 12711 12717 12731 12742 12755 12756 12757 12758 12766 12768 12780 12789 12791 12802 12815 12816 12817 12828 12839 12840 12850 12873 12874 12875 12879 12880 12893 12894 12896 12905 12907 12923 12960 12961 12988 12989 13011;

do 
  for run in 1 2 3
  do
      for CON in interaction
      do
	for GO in 2 3
	do
	  for ROI in lTPJ_charself_5mm midTG_charself_5mm lPCC_charself_5mm; do


	    #directory for feat log
	    FEATFILEDIR=${EXPERIMENT}/Analysis/Framing/FSL/${SUBJ}/NoLapses_PPI/model10/${ROI}/${CON}/run${run}.feat/report_log.html
	    LOGFILEDIR=${EXPERIMENT}/Analysis/Framing/Logs/NoLapses_PPI/L1_m10_go_${GO}/${SUBJ}/ppi_L1m_10_${SUBJ}_0${run}_${ROI}_${CON}*.out

 	    echo "Sub $SUBJ, $ROI, $CON, run$run, go$GO" >> ${OUTDIR}/L1_PPI_LogCheck.txt

	    if grep "Misses for" $LOGFILEDIR ; then
 	      echo "HAS MISSES" >> ${OUTDIR}/L1_PPI_LogCheck.txt 
		if grep "Warning" $FEATFILEDIR; then
# 			echo "Sub $SUBJ,  $CON, run$run, go$GO"		
			grep "Warning" $FEATFILEDIR >> ${OUTDIR}/L1_PPI_LogCheck.txt
 		else
 			echo "ALL CLEAR" >> ${OUTDIR}/L1_PPI_LogCheck.txt
		fi
	    else
 	      echo "Has no misses" >> ${OUTDIR}/L1_PPI_LogCheck.txt
 	      message=`grep "Warning" $FEATFILEDIR`
# 		message="Warning: at least one EV is (close to) a linear combination of the others."
		if [[ $message == $NoMissWarn ]]; then
  	      		echo "ALL CLEAR" >> ${OUTDIR}/L1_PPI_LogCheck.txt
 		else
# 			echo "Sub $SUBJ,  $CON, run$run, go$GO"
			grep "Warning" $FEATFILEDIR >> ${OUTDIR}/L1_PPI_LogCheck.txt
		fi	
	    fi
      	    
	    if grep "ERROR" $FEATFILEDIR; then
# 		echo "Sub $SUBJ,  $CON, run$run, go$GO"
		grep "ERROR" $FEATFILEDIR >> ${OUTDIR}/L1_PPI_LogCheck.txt
	    fi

	    if grep "Error" $FEATFILEDIR; then
# 		echo "Sub $SUBJ,  $CON, run$run, go$GO"
		grep "Error" $FEATFILEDIR >> ${OUTDIR}/L1_PPI_LogCheck.txt
	    fi
	    #ls ${FILEDIR}
	    done
	done
      done
   done
done