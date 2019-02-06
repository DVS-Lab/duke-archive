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
TASK=SUB_TASK_SUB
SMOOTH=SUB_SMOOTH_SUB


# -- two inputs
S=$SUBJ #subject number
R=$RUN #run number

# -- helpful to have all data under this main directory
MAINDIR=${EXPERIMENT}/Analysis/TaskData
SCRIPTDIR=$MAINDIR/__forHugin


MYOUTDIR=${MAINDIR}/${S}/${TASK}
if [ ${SMOOTH} -eq 6 ]; then
	MYINDIR=${MAINDIR}/${S}/${TASK}/run${R}_smooth
	DATA=${MYOUTDIR}/run${R}_smooth/swacrun${R}.nii.gz
else
	MYINDIR=${MAINDIR}/${S}/${TASK}/run${R}
	DATA=${MYOUTDIR}/run${R}_SUSANprep/swacrun${R}.nii.gz
fi

#rm -rf ${MYINDIR}/run${R}.nii
if [ ! -e ${MYINDIR}/swacrun${R}.nii ]; then
	echo "missing file: ${MYINDIR}/swacrun${R}.nii" >> $MAINDIR/__missingfiles_dirty_new.txt	
else

	# -- set output and remove existing --
	OUTPUT=${MYOUTDIR}/prestats${R}_4mm_SUSAN
	rm -rf ${OUTPUT}.feat
	sleep 5s
	rm -rf ${OUTPUT}.feat
	sleep 5s

	NVOLUMES=`fslnvols $DATA`
	# -- run remaining preprocessing steps and ica --
	TEMPLATE=${SCRIPTDIR}/hp_bet_melodic_smooth.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	<$TEMPLATE> ${MYOUTDIR}/prestats${R}_${SMOOTH}mm_4mmSUSAN.fsf
	feat ${MYOUTDIR}/prestats${R}_${SMOOTH}mm_4mmSUSAN.fsf


	#-- clean up extra files --
	#rm -rf $DATA
	GENDATA=${OUTPUT}.feat/filtered_func_data.nii.gz
	if [ -e $GENDATA ]; then
		rm -rf ${MYINDIR}/crun${R}.nii
	else
		echo "failed: $GENDATA" >> $MAINDIR/__faileddata_dirty_new.txt
	fi

fi

OUTDIR=${MAINDIR}/Logs/fslprestats2_fix_new
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
