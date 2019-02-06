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

MAINDIR=${EXPERIMENT}/Analysis/ANTS
OUTPUTDIR=$TMPDIR/T1s_1.8mm_brain_ANTS_test4_n5
mkdir $OUTPUTDIR

#smb://munin.biac.duke.edu/Huettel/HighRes.01/Analysis/NIFTI/1005/1005_anat.nii.gz

for SUBJ in 1002 1005 1006 1007 1008; do
	MAINOUTPUT=${EXPERIMENT}/Analysis/FSL/${SUBJ}/wholebrainEPI_0mm_smooth
	IMAGE=${MAINOUTPUT}/run3.feat/reg/highres2standard.nii.gz
	cp $IMAGE $OUTPUTDIR/${SUBJ}_T1_brain.nii.gz
done
cd $OUTPUTDIR

#sh ./buildtemplateparallel.sh -d 3 -c 1 -o w -n 0 -i 5   -z /home/crlab/dukeants/template.nii.gz  $m*.nii.gz
#sh $ANTSPATH/buildtemplateparallel.sh -d 3 -c 2 -j 2 -o w -n 0 -i 5 -z $MAINDIR/${OUTPREFIX}_n${N}_${TYPE}.nii.gz *_${FLIRTOUTEXT}_${TYPE}.nii.gz
#sh $ANTSPATH/buildtemplateparallel.sh -d 3 -c 2 -j 2 -o w -n 0 -i 5 *_${FLIRTOUTEXT}_${TYPE}.nii.gz
sh ${ANTSPATH}buildtemplateparallel.sh -d 3 -c 0 -o diffeo -n 0 -i 5 *_brain.nii.gz

mv ${OUTPUTDIR} ${MAINDIR}/.

OUTDIR=$MAINDIR/Logs
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
