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
# #$ -M jac44@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


ls /mnt/BIAC/munin3.dhe.duke.edu/Huettel/Imagene.02
sleep 5s

FSLDIR=/usr/local/packages/fsl-4.1.8
 . ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH


SUBJ=$1
TASK=$2
RUN=$3
GO=1


DATADIR=/mnt/BIAC/munin3.dhe.duke.edu/Huettel/Imagene.02/Analysis/TaskData/${SUBJ}/${TASK}/MELODIC_FLIRT/Smooth_6mm/run${RUN}.ica
DATA=${DATADIR}/unconfounded_data.nii.gz

MAINDIR=/mnt/BIAC/munin3.dhe.duke.edu/Huettel/Imagene.02/Analysis/AU_connectivity/DVS/TPJparcellation
for MODELS in A B C; do

	EV1_PARA=${MAINDIR}/TPJparcEVs/${SUBJ}/run${RUN}/${SUBJ}_m${MODELS}_para_run${RUN}.txt
	if [ ! -e $EV1_PARA ]; then
		echo "skipping $SUBJ $RUN"
		continue
	fi

	EV2_CONS=${MAINDIR}/TPJparcEVs/${SUBJ}/run${RUN}/${SUBJ}_m${MODELS}_cons_run${RUN}.txt
	
	EV3_MISS=${MAINDIR}/TPJparcEVs/${SUBJ}/run${RUN}/${SUBJ}_m${MODELS}_miss_run${RUN}.txt
	if [ -s $EV3_MISS ]; then
		EV3_SHAPE=3
	else
		EV3_SHAPE=10
		echo "no lapses"
	fi
	
	MAINOUTPUT=${MAINDIR}/FEAT_modelsABC/${SUBJ}
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/L1m${MODELS}_run${RUN}
	TEMPLATE=${MAINDIR}/TPJmodelsABC_230vols.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@EV1_PARA@'$EV1_PARA'@g' \
	-e 's@EV2_CONS@'$EV2_CONS'@g' \
	-e 's@EV3_MISS@'$EV3_MISS'@g' \
	-e 's@EV3_SHAPE@'$EV3_SHAPE'@g' \
	-e 's@DATA@'$DATA'@g' \
	<${TEMPLATE}> ${OUTPUT}.fsf
	feat ${OUTPUT}.fsf
	rm ${OUTPUT}.feat/filtered_func_data.nii.gz
	rm ${OUTPUT}.feat/stats/res4d.nii.gz
	rm ${OUTPUT}.feat/stats/corrections.nii.gz
	cp -r ${DATADIR}/reg ${OUTPUT}.feat/.
done


OUTDIR=${MAINDIR}/Logs_dvs
mkdir -p $OUTDIR

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
