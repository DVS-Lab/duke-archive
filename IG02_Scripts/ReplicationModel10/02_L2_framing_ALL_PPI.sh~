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
# #$ -M rosa.li@duke.edu
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


# FSLDIR=/usr/local/fsl-4.1.4-centos4_64
# export FSLDIR
# source $FSLDIR/etc/fslconf/fsl.sh


SUBJ=SUB_SUBNUM_SUB
ROI=SUB_ROI_SUB
MODEL=SUB_MODEL_SUB
GO=SUB_GO_SUB
CON=SUB_CON_SUB

#data location and other variables
MAINOUTPUT=$EXPERIMENT/Analysis/Framing/FSL/${SUBJ}
OUTPUT=${MAINOUTPUT}/NoLapses_PPI/model${MODEL}/${ROI}/${CON}

OUTDIR=$EXPERIMENT/Analysis/Framing/Logs/NoLapses_PPI/L2_m${MODEL}_go_${GO}/$SUBJ
mkdir -p $OUTDIR


if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.gfeat
fi

NCOPES=4
if [ -d $OUTPUT.gfeat ]; then
	cd $OUTPUT.gfeat
	for C in `seq $NCOPES`; do
		CHECK_FILE=$OUTPUT.gfeat/cope${C}.feat/cluster_mask_zstat1.nii.gz
		if [ -e $CHECK_FILE ]; then
			COPE1_GOOD=1
		else
			COPE1_GOOD=0
			cd $EXPERIMENT
			rm -rf $OUTPUT.feat
		fi
	done
fi


 if [ $SUBJ -eq 10387 ] || [ $SUBJ -eq 10705 ] || [ $SUBJ -eq 10747 ] || [ $SUBJ -eq 10762 ] || [ $SUBJ -eq 11196 ] || [ $SUBJ -eq 11210 ] || [ $SUBJ -eq 11274 ] || [ $SUBJ -eq 11383 ] || [ $SUBJ -eq 12165 ] || [ $SUBJ -eq 12360 ] || [ $SUBJ -eq 12665 ] || [ $SUBJ -eq 12758 ] || [ $SUBJ -eq 12789 ]; then
	FEAT1=${OUTPUT}/run1.feat
	FEAT2=${OUTPUT}/run2.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_4copes_2runs_RL.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf

elif [ $SUBJ -eq 10524 ] || [ $SUBJ -eq 10615 ] || [ $SUBJ -eq 10696 ] || [ $SUBJ -eq 10783 ] || [ $SUBJ -eq 10794 ] || [ $SUBJ -eq 10858 ] || [ $SUBJ -eq 11233 ] || [ $SUBJ -eq 11602 ] || [ $SUBJ -eq 12132 ] || [ $SUBJ -eq 12551 ]; then
	FEAT1=${OUTPUT}/run1.feat
	FEAT2=${OUTPUT}/run3.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_4copes_2runs_RL.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf

elif [ $SUBJ -eq 10352 ] || [ $SUBJ -eq 10707 ] || [ $SUBJ -eq 11235 ]; then
	FEAT1=${OUTPUT}/run2.feat
	FEAT2=${OUTPUT}/run3.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_4copes_2runs_RL.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf

else
	FEAT1=${OUTPUT}/run1.feat
	FEAT2=${OUTPUT}/run2.feat
	FEAT3=${OUTPUT}/run3.feat
	TEMPLATE=$EXPERIMENT/Analysis/Framing/Templates/L2_4copes_3runs_RL.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@FEAT1@'$FEAT1'@g' \
	-e 's@FEAT2@'$FEAT2'@g' \
	-e 's@FEAT3@'$FEAT3'@g' \
	<$TEMPLATE> ${OUTPUT}.fsf

fi

#run the newly created fsf files
if [ -d $OUTPUT.gfeat ]; then
	echo "$OUTPUT.gfeat exists! skipping to the next one"
else
	$FSLDIR/bin/feat ${OUTPUT}.fsf
fi

#no copes!
for COPE in `seq $NCOPES`; do
	cd ${OUTPUT}.gfeat
	cd cope${COPE}.feat
	rm -f filtered_func_data.nii.gz
	rm -f var_filtered_func_data.nii.gz
	rm -f stats/res4d.nii.gz 
done


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
