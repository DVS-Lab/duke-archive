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

MAINDIR=${EXPERIMENT}/Analysis
ANAT=${MAINDIR}/TaskData/$SUBJ/${SUBJ}_anat_brain
if [ $FNIRT -eq 1 ]; then
	PRESTATSREGDIR=${MAINDIR}/TaskData/${SUBJ}/MELODIC_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.ica/reg
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model01_FNIRT/Smooth_${SMOOTH}mm
	mkdir -p ${MAINOUTPUT}
else
	PRESTATSREGDIR=${MAINDIR}/TaskData/${SUBJ}/MELODIC_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.ica/reg
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model01_FLIRT/Smooth_${SMOOTH}mm
	mkdir -p ${MAINOUTPUT}
fi


PRESTATSDATA=${MAINDIR}/TaskData/${SUBJ}/MELODIC_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.ica
DATA=${PRESTATSDATA}/filtered_func_data.nii.gz

OUTPUT=${MAINOUTPUT}/run${RUN}
CONFOUNDEVSFILE=${PRESTATSDIR}/bad_timepoints.txt
if [ -e $CONFOUNDEVSFILE ]; then
	USECONFOUNDEVS=1
else
	USECONFOUNDEVS=0
fi




if [ $GO -eq 1 ]; then
	rm -rf $OUTPUT.feat
fi

if [ -e $OUTPUT.feat/cluster_mask_zstat1.nii.gz ]; then
	echo "previous analysis worked..."
else
	rm -rf $OUTPUT.feat
fi


# 
# if [ -e ${OUTPUT}.feat/mean_func.nii.gz ]; then
# 	echo "exists: ${OUTPUT}.feat/mean_func.nii.gz"
# 	XX=`fslstats ${OUTPUT}.feat/mean_func.nii.gz -m`
# 	if [ $XX == "nan" ]; then
# 		echo "found $XX in the mean func file. deleting and starting over..."
# 		rm -rf ${OUTPUT}.feat
# 	fi
# fi

#numbers below reflect original minus disdaqs
if [ $SUBJ -eq 13282 -a $RUN -eq 1 ]; then
	NVOLUMES=476
elif [ $SUBJ -eq 13282 -a $RUN -eq 2 ]; then
	NVOLUMES=480
elif [ $RUN -eq 5 ]; then
	NVOLUMES=234
else
	NVOLUMES=484
fi


EVFILES=${MAINDIR}/FSL/EV_files/Model_01/${SUBJ}/run${RUN}

FDCUE=${EVFILES}/face_delay_cue.txt
LDCUE=${EVFILES}/land_delay_cue.txt
FVCUE=${EVFILES}/face_value_cue.txt
LVCUE=${EVFILES}/land_value_cue.txt
FACEC=${EVFILES}/face_constant_image.txt
LANDC=${EVFILES}/land_constant_image.txt
HIT=${EVFILES}/hit_outcome.txt
MISS=${EVFILES}/miss_outcome.txt



TEMPLATE=${MAINDIR}/FSL/Templates/L1_model01.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@FDCUE@'$FDCUE'@g' \
-e 's@FVCUE@'$FVCUE'@g' \
-e 's@LVCUE@'$LVCUE'@g' \
-e 's@LDCUE@'$LDCUE'@g' \
-e 's@HIT@'$HIT'@g' \
-e 's@MISS@'$MISS'@g' \
-e 's@LANDC@'$LANDC'@g' \
-e 's@FACEC@'$FACEC'@g' \
-e 's@CONFOUNDEVSFILE@'$CONFOUNDEVSFILE'@g' \
-e 's@USECONFOUNDEVS@'$USECONFOUNDEVS'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

if [ -d ${OUTPUT}.feat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz

CHECKREG=${OUTPUT}.feat/reg/example_func2standard.png
if [ -e $CHECKREG ]; then
	echo "registration is complete..."
else
	rm -rf ${OUTPUT}.feat/reg
	cp -r ${PRESTATSREGDIR} ${OUTPUT}.feat/reg
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
