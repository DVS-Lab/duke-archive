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


SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=SUB_SMOOTH_SUB
TASK=SUB_TASK_SUB
GO=SUB_GO_SUB



if [ $SUBJ -eq 47964 ]; then #why is this true? FATASS didn't fit in the scanner
	exit
fi

if [ $SUBJ -eq 47945 ] && [ $RUN -eq 3 ] && [ "$TASK" == "MID" ]; then
	echo "this run was never there..."
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48152 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48150 ]; then
	echo "Resting DNE"
	exit
fi


if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48156 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48061 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48271 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48123 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48129 ]; then
	echo "Resting DNE"
	exit
fi

if [ "$TASK" == "Gambling" ] && [ $RUN -eq 3 ] && [ $SUBJ -eq 48129 ]; then
	echo "gambling run 3 DNE"
	exit
fi

if [ "$TASK" == "Resting" ] && [ $SUBJ -eq 48197 ]; then
	echo "Resting DNE"
	exit
fi


MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC_150/Smooth_${SMOOTH}mm
mkdir -p ${MAINOUTPUT}


OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica
FILE_TO_CHECK=${OUTPUTREAL}/filtered_func_data.nii.gz
if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi
if [ ! -e $FILE_TO_CHECK ]; then
	rm -rf ${OUTPUTREAL}
fi


ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
# if [ $GO -eq 1 ]; then
# 	rm -rf ${ANAT}
# 	NEWANATDIR=${EXPERIMENT}/Analysis/TaskData/${SUBJ}
# 	cd $NEWANATDIR
# 	$FSLDIR/bin/bet ${SUBJ}_anat ${SUBJ}_anat_brain -f 0.35
# fi

DATA=${SUBJDIR}/${TASK}/run${RUN}.nii.gz
OUTPUT=${MAINOUTPUT}/run${RUN}
SO_FILE=${SUBJDIR}/${TASK}/so_run${RUN}.txt


if [ "$TASK" == "Framing" ]; then
	NVOLUMES=180
	#echo "Framing " ${DATA}
	#fslhd ${DATA} 
	#fslnvols ${DATA}
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

if [ "$TASK" == "Framing" ] && [ $SUBJ -eq 47731 ] && [ $RUN -eq 1 ]; then
	NVOLUMES=134
fi

if [ "$TASK" == "Gambling" ] && [ $SUBJ -eq 47725 ]; then
	NVOLUMES=134
fi

if [ "$TASK" == "Gambling" ] && [ $SUBJ -eq 48152 ] && [ $RUN -eq 1 ]; then
	#NVOLUMES=212 
	fslroi $DATA $DATA 0 180
fi


NDISDAQS=6
TEMPLATEDIR=${MAINDIR}/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@NDISDAQS@'$NDISDAQS'@g' \
-e 's@SO_FILE@'$SO_FILE'@g' \
<melodic_IG1_150.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

cd ${MAINOUTPUT}
if [ -d "$OUTPUTREAL" ]; then
	echo "That one is already done!"
else
	

	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
# 	#improve masked data for proper registrationss
# 	F_VALUE=0.4
# 	cd $OUTPUTREAL
# 	BETINPUT=mean_func.nii.gz
# 	BETOUTPUT=new_mean_func
# 	BETCMD="bet $BETINPUT $BETOUTPUT -f ${F_VALUE} -m"
# 	eval $BETCMD
# 	#rm -f new.nii.gz 
# 	rm -rf stats
# 	mv new_mean_func_mask.nii.gz new_mask.nii.gz
# 	$FSLDIR/bin/fslmaths filtered_func_data.nii.gz -mas new_mask.nii.gz new_filtered_func_data
	
fi

# 
# ROIDIR=${MAINDIR}/ROIs
# 
# OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat
# cd ${MAINOUTPUT}
# if [ -d "$OUTPUTREAL" ]; then
# 	cd $OUTPUTREAL
# # 	MASKNAME="air4.hdr"
# # 	MASK=${ROIDIR}/${MASKNAME}
# # 	$FSLDIR/bin/fslmeants -i filtered_func_data.nii.gz -o air_regressor.txt -m ${MASK}
# 	#$FSLDIR/bin/fslmeants -i filtered_func_data.nii.gz -o wb_raw.txt -m mask.nii.gz
# # 	if [ -e new_filtered_func_data.nii.gz ]; then
# # 		rm -rf filtered_func_data.nii.gz
# # 	fi
# 	#rm -rf stats
# 
# else
# 	echo "wtf... this file should be there"
# fi

cp $OUTPUTREAL/mc/prefiltered_func_data_mcf.par $OUTPUTREAL/MOTIONconfoundevs.txt



echo "LOOKING FOR BAD TIME POINTS ----------- HERE -----------"
DATA=${SUBJDIR}/${TASK}/run${RUN}.nii.gz
NDISDAQS=6
if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
	echo "bad_timepoints.txt exists..."
	OUTDIR=${MAINDIR}/MELODIC_150_logs_SUCCES/GO_${GO}
else
	fsl_motion_outliers ${DATA} ${NDISDAQS} ${OUTPUTREAL}/bad_timepoints.txt
	OUTDIR=${MAINDIR}/MELODIC_150_logs_previousFAIL/GO_${GO}
fi


mkdir -p $OUTDIR

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
if [ -e $OUTDIR/$JOB_NAME.$JOB_ID.out ]; then
rm $HOME/$JOB_NAME.$JOB_ID.out
fi
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
