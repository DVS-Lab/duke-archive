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
#$ -M avu4@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02
sleep 5s

SUBJ=$1

for RUN in 1 4; do 
	MAINDIR=/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis
	SUBJDIR=${MAINDIR}/FSL/${SUBJ}/MELODIC_FLIRT/Smooth_5mm/run${RUN}.ica
	MAINOUTPUT=${MAINDIR}/avu/RT_anticip_FNIRT_lvl1_model4/${SUBJ}/run${RUN}/FEAT
	rm -rf $MAINOUTPUT
	mkdir -p $MAINOUTPUT
	OUTPUT=$MAINOUTPUT/RT_anticipation
	OUTPUTREAL=${OUTPUT}.feat
	rm -rf $OUTPUTREAL

	#

	DATA=${SUBJDIR}/filtered_func_data.nii.gz
	CONFOUNDEVS=${SUBJDIR}/for_confound.txt
	TEMPLATEDIR=${MAINDIR}/avu/models/L1
	TEMPLATE=${TEMPLATEDIR}/L1_RT_anticipation_nocue_orthog.fsf
	
	CONSTANT_EV=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/constant_anticip_newonset_duration_ev_au.txt
	PARAMETRIC_EV=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/parametric_anticip_ev_avgRTs_au.txt
	HIT_OUTCOME=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/hit_outcome.txt
	MISS_OUTCOME=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/miss_outcome.txt
	FACE_OUTCOME=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/face_constant_image.txt
	LAND_OUTCOME=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/land_constant_image.txt
	CUES=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/cues_impulse_au.txt

	cd ${TEMPLATEDIR}
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@CONFOUNDFILE@'$CONFOUNDEVS'@g' \
	-e 's@CONSTANT_EV@'$CONSTANT_EV'@g' \
	-e 's@PARAMETRIC_EV@'$PARAMETRIC_EV'@g' \
	-e 's@HIT_OUTCOME@'$HIT_OUTCOME'@g' \
	-e 's@MISS_OUTCOME@'$MISS_OUTCOME'@g' \
	-e 's@FACE_OUTCOME@'$FACE_OUTCOME'@g' \
	-e 's@LAND_OUTCOME@'$LAND_OUTCOME'@g' \
	<$TEMPLATE> ${MAINOUTPUT}/L1_RT_anticipation_nocue_avgRTs_edited.fsf

	feat ${MAINOUTPUT}/L1_RT_anticipation_nocue_avgRTs_edited.fsf
	cp -r ${MAINDIR}/FSL/${SUBJ}/MELODIC_FNIRT/Smooth_5mm/run${RUN}.ica/reg ${OUTPUTREAL}/.

	OUTDIR=$MAINDIR/avu/Logs
	mkdir -p $OUTDIR
done

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
