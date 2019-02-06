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
#$ -m ea
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
#$ -M smith@biac.duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

SUBJ=$1
MODEL=$2
j=$3

if [ "$MODEL" == "Model8_faces_NoMotor_6mm_ST" ] || [ "$MODEL" == "Model8_faces_NoMotor_6mm_ST_TD" ] || [ "$MODEL" == "Model8_faces_6mm_ST" ] || [ "$MODEL" == "Model8_faces_6mm_ST_TD" ]; then

	OPTION="faces"

elif [ "$MODEL" == "Model9_faces_NoMotor_6mm_ST" ] || [ "$MODEL" == "Model9_faces_NoMotor_6mm_ST_TD" ] || [ "$MODEL" == "Model9_faces_6mm_ST" ] || [ "$MODEL" == "Model9_faces_6mm_ST_TD" ]; then

	OPTION="faces"

else

	OPTION="money"

fi

MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask
MODELDIR=${MAINDIR}/${SUBJ}/${SUBJ}_${MODEL}/${SUBJ}_2ndlevel_${OPTION}.gfeat
echo $MODELDIR


COPE=${MODELDIR}/cope${j}.feat
MASKDIR=${MAINDIR}/ROIs_functional

cd $MASKDIR
ls -1 *.hdr > roifile
cd $COPE

cat $MASKDIR/roifile|while read LINE; do
	
	MASKNAME=$LINE
	MASK=${MAINDIR}/ROIs_functional/${MASKNAME}

	if [ -d $COPE/${MASKNAME}_featquery ]; then
		echo "this one is done!"
	else
		featquery 1 ${COPE} 1  stats/pe1 ${MASKNAME}_featquery -p ${MASK}
	fi

done



OUTDIR=$MAINDIR/Featquery_Logs_new500/${MODEL}
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 

mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
