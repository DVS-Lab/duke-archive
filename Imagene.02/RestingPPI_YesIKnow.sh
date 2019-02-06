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


S=$1

MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBDIR=${MAINDIR}/${S}/Resting
DATA=${SUBDIR}/prestats1_4mmSUSAN_clean.feat/filtered_func_data.nii.gz

MAINOUTPUT=${MAINDIR}/PhysioPhysioInt/FSL_split2/${S}
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/L1_m03
rm -rf ${OUTPUT}.feat

EVDIR=${MAINDIR}/PhysioPhysioInt/EVs_nets/${S}
NET01=${EVDIR}/net01.txt
NET02=${EVDIR}/net02.txt
NET03=${EVDIR}/net03.txt
NET04=${EVDIR}/net04.txt
NET05=${EVDIR}/net05.txt
NET06=${EVDIR}/net06.txt
NET07=${EVDIR}/net07.txt
NET08=${EVDIR}/net08.txt
NET09=${EVDIR}/net09.txt
NET10=${EVDIR}/net10.txt


TEMPLATE=${MAINDIR}/PhysioPhysioInt/L1_template_m03.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NET01@'$NET01'@g' \
-e 's@NET02@'$NET02'@g' \
-e 's@NET03@'$NET03'@g' \
-e 's@NET04@'$NET04'@g' \
-e 's@NET05@'$NET05'@g' \
-e 's@NET06@'$NET06'@g' \
-e 's@NET07@'$NET07'@g' \
-e 's@NET08@'$NET08'@g' \
-e 's@NET09@'$NET09'@g' \
-e 's@NET10@'$NET10'@g' \
<$TEMPLATE> ${MAINOUTPUT}/L1_m01.fsf
feat ${MAINOUTPUT}/L1_m01.fsf


rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz

OUTDIR=${MAINDIR}/Logs/MID_L1_m07
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
