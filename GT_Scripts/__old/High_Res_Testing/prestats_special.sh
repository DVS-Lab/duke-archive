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


SUBJ=48344
RUN=1
SMOOTH=6
GO=1
TASK=Framing

FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


if [ $SUBJ -eq 47964 ]; then
	exit
fi


MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/PreStatsOnly/Smooth_${SMOOTH}mm
mkdir -p ${MAINOUTPUT}

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi

ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
DATA=${SUBJDIR}/${TASK}/run${RUN}.nii.gz
OUTPUT=${MAINOUTPUT}/run${RUN}


if [ "$TASK" == "Framing" ]; then
	NVOLUMES=180
elif [ "$TASK" == "Gambling" ]; then
	NVOLUMES=180
elif [ "$TASK" == "MID" ]; then
	NVOLUMES=212
elif [ "$TASK" == "Resting" ]; then
	NVOLUMES=180
fi


if [ "$TASK" == "Framing" ] && [ $SUBJ -eq 47731 ] && [ $RUN -eq 1 ]; then
	NVOLUMES=134
fi


if [ "$TASK" == "Gambling" ] && [ $SUBJ -eq 47725 ]; then
	NVOLUMES=134
fi


NDISDAQS=6
TEMPLATEDIR=${MAINDIR}/Templates/DVS
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@SMOOTH_CR@'$SMOOTH'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@NDISDAQS@'$NDISDAQS'@g' \
<prestats.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf

	#create masked data for proper registrations
	F_VALUE=0.4
	cd $OUTPUTREAL
	DATA=${MAINOUTPUT}/run${RUN}.feat/filtered_func_data.nii.gz
	BETINPUT=mean_func.nii.gz
	BETOUTPUT=new
	BETCMD="bet $BETINPUT $BETOUTPUT -f ${F_VALUE} -m"
	eval $BETCMD
	rm -f new.nii.gz 
	fslmaths filtered_func_data.nii.gz -mas new_mask.nii.gz new_filtered_func_data
	
fi



ROIDIR=${MAINDIR}/ROIs

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	cd $OUTPUTREAL
	MASKNAME="air4.hdr"
	MASK=${ROIDIR}/${MASKNAME}
	fslmeants -i filtered_func_data.nii.gz -o air_regressor.txt -m ${MASK}

	if [ -e new_filtered_func_data.nii.gz ]; then
		rm -rf filtered_func_data.nii.gz
	fi

else
	echo "wtf... this file should be there"
fi



OUTDIR=${MAINOUTPUT}/Logs
mkdir -p $OUTDIR

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
