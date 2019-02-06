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
TASK=MID

# -- two inputs
S=$SUBJ #subject number
R=$RUN #run number

MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBDIR=${MAINDIR}/${S}/MID
DATA=${SUBDIR}/prestats${R}_6mm_clean.feat/filtered_func_data.nii.gz
NVOLUMES=`fslnvols ${DATA}`

MAINOUTPUT=${MAINDIR}/StrParc/FSL/${S}
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/L1_run${R}_6mm_m03_ppi
rm -rf ${OUTPUT}.feat

EVDIR=${MAINDIR}/StrParc/EV_files_new3
ZGMAX=${EVDIR}/${S}_gmax${R}.txt
ZVMIN=${EVDIR}/${S}_vmin${R}.txt
ZLMIN=${EVDIR}/${S}_lmin${R}.txt
ZPMAX=${EVDIR}/${S}_pmax${R}.txt
ZCONTROL=${EVDIR}/${S}_zero${R}.txt
ZTARGET=${EVDIR}/${S}_target${R}.txt
ZCUE=${EVDIR}/${S}_cue${R}.txt
ZMISS=${EVDIR}/${S}_miss${R}.txt
ZHIT=${EVDIR}/${S}_hit${R}.txt

NETSDIR=${MAINDIR}/StrParc/EVs_nets/${S}
ZNET01=${NETSDIR}/net01_run${R}.txt
ZNET02=${NETSDIR}/net02_run${R}.txt
ZNET03=${NETSDIR}/net03_run${R}.txt
ZNET04=${NETSDIR}/net04_run${R}.txt
ZNET05=${NETSDIR}/net05_run${R}.txt
ZNET06=${NETSDIR}/net06_run${R}.txt
ZNET07=${NETSDIR}/net07_run${R}.txt
ZNET08=${NETSDIR}/net08_run${R}.txt
ZNET09=${NETSDIR}/net09_run${R}.txt
ZNET10=${NETSDIR}/net10_run${R}.txt


TEMPLATE=${MAINDIR}/StrParc/templates/L1_ppi.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@ZGMAX@'$ZGMAX'@g' \
-e 's@ZVMIN@'$ZVMIN'@g' \
-e 's@ZLMIN@'$ZLMIN'@g' \
-e 's@ZPMAX@'$ZPMAX'@g' \
-e 's@ZCONTROL@'$ZCONTROL'@g' \
-e 's@ZTARGET@'$ZTARGET'@g' \
-e 's@ZCUE@'$ZCUE'@g' \
-e 's@ZMISS@'$ZMISS'@g' \
-e 's@ZHIT@'$ZHIT'@g' \
-e 's@ZNET01@'$ZNET01'@g' \
-e 's@ZNET02@'$ZNET02'@g' \
-e 's@ZNET03@'$ZNET03'@g' \
-e 's@ZNET04@'$ZNET04'@g' \
-e 's@ZNET05@'$ZNET05'@g' \
-e 's@ZNET06@'$ZNET06'@g' \
-e 's@ZNET07@'$ZNET07'@g' \
-e 's@ZNET08@'$ZNET08'@g' \
-e 's@ZNET09@'$ZNET09'@g' \
-e 's@ZNET10@'$ZNET10'@g' \
<$TEMPLATE> ${MAINOUTPUT}/L1_run${R}_m03_ppi.fsf
feat ${MAINOUTPUT}/L1_run${R}_m03_ppi.fsf

rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz

OUTDIR=${MAINDIR}/Logs/MID_L1_m03_ppi
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
