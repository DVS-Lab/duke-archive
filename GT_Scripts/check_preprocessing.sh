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
GO=SUB_GO_SUB
FNIRT=SUB_FNIRT_SUB
SETORIGIN=SUB_SETORIGIN_SUB



MAINDIR=${EXPERIMENT}/Analysis


if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
else
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/run${RUN}
fi


FAIL=0

FILE_TO_CHECK=${OUTPUT}.feat/prestats_phase2_2resample.ica/filtered_func_data.nii.gz
if [ -e ${FILE_TO_CHECK} ]; then
	echo "exists: ${OUTPUT}.feat/filtered_func_data.nii.gz"
	XX=`fslstats ${OUTPUT}.feat/filtered_func_data.nii.gz -m`
	if [ $XX == "nan" ]; then
		echo "found $XX in the filtered func file. deleting and starting over..."
		rm -rf ${OUTPUT}.feat
		FAIL=1
		OUTDIR=$MAINDIR/FSL/Logs/nandata
		mkdir -p $OUTDIR
	fi
else
	if [ -d ${OUTPUT}.feat ]; then
		rm -rf ${OUTPUT}.feat
	fi
	FAIL=1
	echo "missing: $FILE_TO_CHECK"
	OUTDIR=$MAINDIR/FSL/Logs/missingdata
	mkdir -p $OUTDIR
fi


#generate confoundevs
if [ -e ${OUTPUT}.feat/bad_timepoints.txt ]; then
	echo "found bad_timepoints file..."
else
	echo "$SUBJ run $RUN is missing bad_timepoints.txt" >> $MAINDIR/FSL/Logs/missing_badtimepoints.txt
fi

if [ $FAIL -eq 0 ]; then
	CHECKREG=${OUTPUT}.feat/reg/PNG_images/example_func2standard.png
	if [ -e $CHECKREG ]; then
		echo "registration is complete..."
	else
		echo "registration fail..."
		rm -rf ${OUTPUT}.feat
		FAIL=1
		OUTDIR=$MAINDIR/FSL/Logs/regfail
		mkdir -p $OUTDIR
	fi
fi

FEATOUTPUT=${OUTPUT}.feat
if [ $FAIL -eq 0 ]; then
	if [ -e ${FEATOUTPUT}/pmcfdata_4D_dSD.nii.gz ]; then
		echo "found physio SD file... not rerunning..."
	else
		echo "missing: ${FEATOUTPUT}/pmcfdata_4D_dSD.nii.gz"
		OUTDIR=$MAINDIR/FSL/Logs/physiofail
		mkdir -p $OUTDIR
		FAIL=1
		rm -rf ${OUTPUT}.feat
	fi
fi


OUTPUT=${FEATOUTPUT}/prestats_phase2_2resample
if [ $FAIL -eq 0 ]; then
	if [ -d ${OUTPUT}.ica ]; then
		echo "this one is already done"
	else
		echo "missing: ${OUTPUT}.ica"
		OUTDIR=$MAINDIR/FSL/Logs/missingICA
		mkdir -p $OUTDIR
		FAIL=1
		rm -rf ${OUTPUT}.feat
	fi
fi


if [ $FAIL -eq 0 ]; then
	if [ -e ${OUTPUT}.ica/filtered_func_data.nii.gz ]; then
		echo "yay, everything worked... clean up intermediate files to save space..."
		OUTDIR=$MAINDIR/FSL/Logs/preprocessingsuccess
		mkdir -p $OUTDIR
	else
		echo "still missing data..."
		echo "need: ${OUTPUT}.ica/filtered_func_data.nii.gz"
		OUTDIR=$MAINDIR/FSL/Logs/missinglastpart
		mkdir -p $OUTDIR
		rm -rf ${OUTPUT}.feat
	fi
fi



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
