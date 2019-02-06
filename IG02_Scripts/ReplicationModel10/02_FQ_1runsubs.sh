#!/bin/sh

# This is a BIAC template script for jobs on the cluster
# You have to provide the Experiment on command line  
# when you submit the job the cluster.
#
# >  qsub -v EXPERIMENT=Dummy.01  script.sh args
#
# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 

# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
# #$ -m ea
# -- END GLOBAL DIRECTIVE -- 

# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}

source /etc/biac_sge.sh

EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}

if [ $EXPERIMENT = "ERROR" ]
then
	exit 32
else 
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 
# -- END PRE-USER --
# **********************************************************

# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
# #$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here



SUBJ=SUB_SUBNUM_SUB
GO=SUB_GO_SUB
MODEL=10

for COPENUM in `seq 20`; do
	
	
	MAINDIR=${EXPERIMENT}/Analysis/Framing/FSL
	
	if [ $SUBJ -eq 10426 ] || [ $SUBJ -eq 10782 ] || [ $SUBJ -eq 11058 ] || [ $SUBJ -eq 11372 ] || [ $SUBJ -eq 11659 ] || [ $SUBJ -eq 11865 ] || [ $SUBJ -eq 11878 ] || [ $SUBJ -eq 12768 ] || [ $SUBJ -eq 12840 ]; then
	  COPE=${MAINDIR}/${SUBJ}/NoLapses_RL/model${MODEL}/run1.feat/
	  STATS=stats/cope${COPENUM}
	  STATS_Z=stats/zstat${COPENUM}
	elif [ $SUBJ -eq 12176 ]; then
	  COPE=${MAINDIR}/${SUBJ}/NoLapses_RL/model${MODEL}/run2.feat/
	  STATS=stats/cope${COPENUM}
	  STATS_Z=stats/zstat${COPENUM}
	elif [ $SUBJ -eq 10360 ] || [ $SUBJ -eq 10474 ] || [ $SUBJ -eq 12314 ]; then
	  COPE=${MAINDIR}/${SUBJ}/NoLapses_RL/model${MODEL}/run3.feat/
	  STATS=stats/cope${COPENUM}
	  STATS_Z=stats/zstat${COPENUM}
	else
	  COPE=${MAINDIR}/${SUBJ}/NoLapses_RL/model${MODEL}.gfeat/cope${COPENUM}.feat
	  STATS=stats/pe1
	  STATS_Z=stats/zstat1
	fi

# 	for MASKNAME in "lTPJ_charself_5mm" "lTPJ_charself_10mm" "midTG_charself_5mm" "midTG_charself_10mm"; do
 	for MASKNAME in "lPCC_gainloss_5mm" "lSFG_gainloss_5mm" "ldmPFC_lossgain_5mm"; do

		MASK=${MAINDIR}/ROIs/L3_n217_RL/${MASKNAME}.nii.gz

		if [ $GO -eq 1 ]; then
			rm -rf $COPE/${MASKNAME}_${COPENUM}_FQ
		fi

		if [ ! -s $COPE/${MASKNAME}_${COPENUM}_FQ/report.txt ]; then
			rm -rf $COPE/${MASKNAME}_${COPENUM}_FQ
		fi

		if [ -d $COPE/${MASKNAME}_${COPENUM}_FQ ]; then
			echo "FQ output exists! skipping...."
		else
			featquery 1 ${COPE} 1  ${STATS} ${MASKNAME}_${COPENUM}_FQ -p ${MASK}
		fi
		
# 		if [ $GO -eq 1 ]; then
# 			rm -rf $COPE/${MASKNAME}_${COPENUM}_FQ_z
# 		fi
# 
# 		if [ ! -s $COPE/${MASKNAME}_${COPENUM}_FQ_z/report.txt ]; then
# 			rm -rf $COPE/${MASKNAME}_${COPENUM}_FQ_z
# 		fi
# 
# 		if [ -d $COPE/${MASKNAME}_${COPENUM}_FQ_z ]; then
# 			echo "FQ_z output exists! skipping...."
# 		else
# 			CMD="featquery 1 ${COPE} 1  ${STATS_Z} ${MASKNAME}_${COPENUM}_FQ_z -p ${MASK}"
# 			echo $CMD
# 			eval $CMD
# 		fi
# 	
# 		if [ $GO -eq 1 ]; then
# 			rm -rf $COPE/${MASKNAME}_${COPENUM}_FQ_noPercent
# 		fi
# 
# 		if [ ! -s $COPE/${MASKNAME}_${COPENUM}_FQ_noPercent/report.txt ]; then
# 			rm -rf $COPE/${MASKNAME}_${COPENUM}_FQ_noPercent
# 		fi
# 
# 		if [ -d $COPE/${MASKNAME}_${COPENUM}_FQ_noPercent ]; then
# 			echo "FQ_noPercent output exists! skipping...."
# 		else
# 			CMD="featquery 1 ${COPE} 1  ${STATS} ${MASKNAME}_${COPENUM}_FQ_noPercent ${MASK}"
# 			echo $CMD
# 			eval $CMD
# 		fi

	done
done


OUTDIR=${EXPERIMENT}/Analysis/Framing/Logs/01Replication_RL/FQ/1RunSubs
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 

mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
