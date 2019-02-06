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
DATA=${SUBDIR}/prestats${R}_4mmSUSAN_clean.feat/zfiltered_func_data.nii.gz
NVOLUMES=`fslnvols ${DATA}`

MAINOUTPUT=${MAINDIR}/StrParc/FSL/${S}
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/zL1_run${R}_4mm_m07.feat
rm -rf ${OUTPUT}
mkdir -p $OUTPUT

EVDIR=${MAINDIR}/StrParc/EV_files_HitMiss_para_wRT
ZCUE=${EVDIR}/${S}_cue${R}.txt
ZANTC=${EVDIR}/${S}_ant_cons${R}.txt
ZANTP=${EVDIR}/${S}_ant_para${R}.txt
ZHITC=${EVDIR}/${S}_hit_cons${R}.txt
ZHITP=${EVDIR}/${S}_hit_para${R}.txt
ZMISSC=${EVDIR}/${S}_miss_cons${R}.txt
ZMISSP=${EVDIR}/${S}_miss_para${R}.txt
ZTARG=${EVDIR}/${S}_target${R}.txt


TEMPLATE=${MAINDIR}/StrParc/templates/L1_m07_allcons.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@ZANTC@'$ZANTC'@g' \
-e 's@ZANTP@'$ZANTP'@g' \
-e 's@ZHITC@'$ZHITC'@g' \
-e 's@ZHITP@'$ZHITP'@g' \
-e 's@ZMISSC@'$ZMISSC'@g' \
-e 's@ZMISSP@'$ZMISSP'@g' \
-e 's@ZCUE@'$ZCUE'@g' \
-e 's@ZTARG@'$ZTARG'@g' \
<$TEMPLATE> ${OUTPUT}/design.fsf
feat_model ${OUTPUT}/design
cd $OUTPUT

fsl_glm -i $DATA -d design.mat -c design.con -o normedstats --des_norm --out_cope=normedcopes
fslsplit normedcopes zcope_tmp -t
fslmaths zcope_tmp0000 zcope1 #antp
fslmaths zcope_tmp0004 zcope5 #hit-miss
fslmaths zcope_tmp0006 zcope7 #hit
fslmaths zcope_tmp0007 zcope8 #miss


#cd ${OUTPUT}.feat
#unconfound ${DATA} ufiltered_func_data_m07_hrf design.mat


rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz
rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz

OUTDIR=${MAINDIR}/Logs/MID_L1_m07z
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
