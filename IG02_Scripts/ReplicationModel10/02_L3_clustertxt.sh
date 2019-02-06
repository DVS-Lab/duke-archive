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
#$ -M rosa.li@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


COPE=SUB_COPE_SUB
CNAME=SUB_CNAME_SUB
MODEL=SUB_MODEL_SUB
GO=SUB_GO_SUB
TEMPLATE=SUB_TEMPLATE_SUB


MAINDIR=${EXPERIMENT}/Analysis/Framing/FSL/Level3_n217_RL/${TEMPLATE}/Model${MODEL}/C${COPE}_${CNAME}.gfeat/cope1.feat
OUTPUT=${EXPERIMENT}/Analysis/Framing/FSL/Level3_n217_RL/cluster_txts/${TEMPLATE}/randomise_tfce

mkdir -p $OUTPUT

NCONTRASTS=1
cd $MAINDIR

for C in `seq $NCONTRASTS`; do

N=95
NN=0.95



TXTNAME=${CNAME}_lmax_tfce_corrp_tstat${C}_${N}.txt

S=`fslstats thresh_randomise_out_tfce_corrp_tstat${C}_${N}.nii.gz -R`
COMP="0.000000 0.000000 "

if [ "$S" != "$COMP" ]; then
cluster -i zstat1.nii.gz -t $NN --mm --olmax=${TXTNAME}
cp ${TXTNAME} ${OUTPUT}
rm ${TXTNAME}
else
echo "thresh_randomise_out_tfce_corrp_tstat${C}_${N}.nii.gz No results :("
fi

done




OUTDIR=${OUTPUT}/clusterlogs
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