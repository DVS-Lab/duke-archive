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

SUBJ=$1

MAINDIR=/mnt/BIAC/munin3.dhe.duke.edu/Huettel/Imagene.02/Analysis
SUBJDIR=${MAINDIR}/TaskData/${SUBJ}/Framing/MELODIC_FLIRT/Smooth_6mm/run3.ica
MAINOUTPUT=${SUBJDIR}/TPJ_PPI
rm -rf $MAINOUTPUT
mkdir -p $MAINOUTPUT
OUTPUT=$MAINOUTPUT/TPJ_PPI
OUTPUTREAL=${OUTPUT}.feat
rm -rf $OUTPUTREAL

#

OLDDATA=${SUBJDIR}/filtered_func_data.nii.gz
NEWDATA=${SUBJDIR}/filtered_func_data_230vol.nii.gz
fslroi $OLDDATA $NEWDATA 0 230
CONFOUNDEVS=${SUBJDIR}/TPJppi_dr_stage1_${SUBJ}_ConfoundEVs.txt #your confounds file
PSY=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/CharitySelfRegression/${SUBJ}/charity_minus_self.txt
PHYS=${SUBJDIR}/TPJppi_dr_stage1_${SUBJ}_tpjSubRegion.txt
TEMPLATEDIR=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/AU_files
TEMPLATE=${TEMPLATEDIR}/PPI_template_use.fsf
CHARITY_PLUS_SELF=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/CharitySelfRegression/${SUBJ}/charity_plus_self.txt
EV5=${MAINDIR}/AU_connectivity/DVS/TPJparcellation/CharitySelfRegression/${SUBJ}/ev5.txt

cp -r ${MAINDIR}/TaskData/${SUBJ}/Framing/MELODIC_FLIRT/Smooth_6mm/run3.ica/reg ${MAINOUTPUT}/TPJ_PPI.feat

FSLEVDIR=${MAINDIR}/Framing/EVfiles6/Model11_NoLapses/${SUBJ}
MISSES=${FSLEVDIR}/run1/${SUBJ}_misses_run1.txt
if [ -e $MISSES ]; then
	EVSHAPE=3
else
	EVSHAPE=10
fi

cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$NEWDATA'@g' \
-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
-e 's@PSYCH@'$PSY'@g' \
-e 's@TPJ_SUBREGION@'$PHYS'@g' \
-e 's@CHARITY_PLUS_SELF@'$CHARITY_PLUS_SELF'@g' \
-e 's@EV_5@'$EV5'@g' \
-e 's@MISSES@'$MISSES'@g' \
-e 's@EVSHAPE@'$EVSHAPE'@g' \
<$TEMPLATE> ${MAINOUTPUT}/TPJ_ppi_edited.fsf

feat ${MAINOUTPUT}/TPJ_ppi_edited.fsf
cp -r ${SUBJDIR}/reg ${OUTPUTREAL}/.

OUTDIR=$MAINDIR/AU_connectivity/PPI_Logs
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
