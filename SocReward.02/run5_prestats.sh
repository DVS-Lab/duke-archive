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

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here



SUBJ=$1
RUN=5
SMOOTH=5

MAINDIR=${EXPERIMENT}/Analysis/FSL
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}



ANAT=${SUBJDIR}/${SUBJ}_anat_brain
ANATH=${SUBJDIR}/${SUBJ}_anat
DATA=${SUBJDIR}/run${RUN}
OUTPUT=${MAINOUTPUT}/unconfounded_run${RUN}
OUTPUTREAL=${OUTPUT}.ica
SO_FILE=${SUBJDIR}/so_run${RUN}.txt

NVOLUMES=242
NDISDAQS=6

STANDARD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz

TEMPLATEDIR=${MAINDIR}/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@NDISDAQS@'$NDISDAQS'@g' \
-e 's@SO_FILE@'$SO_FILE'@g' \
-e 's@STANDARD@'$STANDARD'@g' \
<melodic_SR02.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi


cp $OUTPUTREAL/mc/prefiltered_func_data_mcf.par $OUTPUTREAL/MOTIONconfoundevs.txt
echo "LOOKING FOR BAD TIME POINTS ----------- HERE -----------"
if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
	echo "Exists: ${OUTPUTREAL}/bad_timepoints.txt"
	OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_SUCCESS/GO_${GO}
else
	fsl_motion_outliers ${DATA} ${NDISDAQS} ${OUTPUTREAL}/bad_timepoints.txt
	if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
		OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_SUCCESS/GO_${GO}
	else
		OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_FAIL/GO_${GO}
	fi
fi


INDATA=${OUTPUTREAL}/filtered_func_data.nii.gz
NVOLUMES=`fslnvols $INDATA`
OUTDATA=${OUTPUTREAL}/unconfounded_data.nii.gz
preMAT=${OUTPUTREAL}/for_confound.txt
paste -d '\0' $OUTPUTREAL/bad_timepoints.txt $OUTPUTREAL/MOTIONconfoundevs.txt > ${preMAT}
postMAT=${OUTPUTREAL}/for_unconfound.mat
TEMPLATEDIR=${MAINDIR}/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$INDATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@UNCONFOUNDFILE@'$preMAT'@g' \
<make_confoundmat.fsf> ${OUTPUTREAL}/for_unconfound.fsf
feat_model ${OUTPUTREAL}/for_unconfound ${preMAT}
unconfound ${INDATA} ${OUTDATA} ${postMAT}


mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
