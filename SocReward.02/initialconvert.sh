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


SUBJ_FULL=$1
SUBJ=$2

MAINFUNCDIR=${EXPERIMENT}/Data/Func
MAINANATDIR=${EXPERIMENT}/Data/Anat
NEWANATDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}
mkdir -p $NEWANATDIR

NRUNS=5


cd $MAINANATDIR/${SUBJ_FULL}/series002 #the good anat is always **series002** because series200 has uneven intensities
rm -rf ${SUBJ}_reoriented_anat.bxh
rm -rf ${SUBJ}_reoriented_anat.dat
bxhreorient --orientation LAS series002.bxh ${SUBJ}_reoriented_anat.bxh
rm -rf $NEWANATDIR/${SUBJ}_anat.nii.gz
bxh2analyze -s -b --niigz ${SUBJ}_reoriented_anat.bxh $NEWANATDIR/${SUBJ}_anat
rm -rf ${SUBJ}_reoriented_anat.bxh
rm -rf ${SUBJ}_reoriented_anat.dat
cd $NEWANATDIR
bet ${SUBJ}_anat ${SUBJ}_anat_brain -R


RUN_PREFIX=run004
for RUNS in `seq $NRUNS`; do

	let RUN=$RUNS+1
	RUN=`printf %02d $RUN`
	FUNCOUTDIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}
	mkdir -p ${FUNCOUTDIR}
	cd ${MAINFUNCDIR}/${SUBJ_FULL}/${RUN_PREFIX}_${RUN}
	rm -rf reoriented_run${RUN}.bxh
	rm -rf reoriented_run${RUN}.dat

	bxhreorient --orientation LAS ${RUN_PREFIX}_${RUN}.bxh reoriented_run${RUN}.bxh
	extractsliceorder --fsl --overwrite reoriented_run${RUN}.bxh ${FUNCOUTDIR}/so_run${RUNS}.txt

	rm -rf ${FUNCOUTDIR}/run${RUNS}.nii.gz
	rm -rf ${FUNCOUTDIR}/run${RUNS}.bxh
	bxh2analyze -s --niigz reoriented_run${RUN}.bxh ${FUNCOUTDIR}/run${RUNS}
	BXHCMD="bxh2analyze -s --niigz reoriented_run${RUN}.bxh ${FUNCOUTDIR}/run${RUNS}"
	echo $BXHCMD
	rm -rf reoriented_run${RUN}.bxh
	rm -rf reoriented_run${RUN}.dat

done

OUTDIR=${EXPERIMENT}/Analysis/FSL/Logs/initialconvert
mkdir -p $OUTDIR

# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
