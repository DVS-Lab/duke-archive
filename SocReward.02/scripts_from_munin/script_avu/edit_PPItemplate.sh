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


ls /mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02
sleep 5s

MAINDIR=/mnt/BIAC/munin4.dhe.duke.edu/Huettel/SocReward.02/Analysis

SUBJ=$1

for RUN in 1 4; do 
	SUBJDIR=${MAINDIR}/FSL/${SUBJ}/MELODIC_FLIRT/Smooth_5mm/run${RUN}.ica
	
	DATA=${SUBJDIR}/filtered_func_data.nii.gz
	OUTPUT=${MAINDIR}/avu/SR02_reward_gPPI_DMN_ECN_allDRICs_maineffects/PPI_${SUBJ}_run${RUN}
	CONFOUNDEVS=${SUBJDIR}/for_confound.txt
	PSYFACES=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/face_constant_image.txt
	PSYLANDS=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/land_constant_image.txt
	PSYFACESRT=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/face_constant_parametric_subsequentRT.txt
	PSYLANDSRT=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/land_constant_parametric_subsequentRT.txt
	TSDMN=${SUBJDIR}/DMN_DR_ts.txt
	TSECN=${SUBJDIR}/ECN_DR_ts.txt
	HITEV=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/hit_outcome.txt
	MISSEV=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/miss_outcome.txt
	FACECUES=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/face_ev_au.txt
	LANDCUES=${MAINDIR}/FSL/EV_files/Anticipation_Models/${SUBJ}/run${RUN}/land_ev_au.txt
	
	COMP1=${SUBJDIR}/IC1_DR_ts.txt
	COMP2=${SUBJDIR}/IC2_DR_ts.txt
	COMP5=${SUBJDIR}/IC5_DR_ts.txt
	COMP8=${SUBJDIR}/IC8_DR_ts.txt
	COMP9=${SUBJDIR}/IC9_DR_ts.txt
	Comp10=${SUBJDIR}/IC10_DR_ts.txt
	Comp11=${SUBJDIR}/IC11_DR_ts.txt
	Comp12=${SUBJDIR}/IC12_DR_ts.txt
	Comp13=${SUBJDIR}/IC13_DR_ts.txt
	Comp14=${SUBJDIR}/IC14_DR_ts.txt
	Comp15=${SUBJDIR}/IC15_DR_ts.txt
	Comp16=${SUBJDIR}/IC16_DR_ts.txt
	Comp17=${SUBJDIR}/IC17_DR_ts.txt
	Comp18=${SUBJDIR}/IC18_DR_ts.txt
	Comp19=${SUBJDIR}/IC19_DR_ts.txt
	Comp20=${SUBJDIR}/IC20_DR_ts.txt
	Comp21=${SUBJDIR}/IC21_DR_ts.txt
	Comp22=${SUBJDIR}/IC22_DR_ts.txt
	Comp23=${SUBJDIR}/IC23_DR_ts.txt
	Comp24=${SUBJDIR}/IC24_DR_ts.txt
	Comp25=${SUBJDIR}/IC25_DR_ts.txt
	LFP=${SUBJDIR}/LFP_DR_ts.txt
	RFP=${SUBJDIR}/RFP_DR_ts.txt

	TEMPLATE=${MAINDIR}/avu/models/SR02_gPPI_allDRts_newzerooptions_maineffects.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@CONFOUNDEVS@'$CONFOUNDEVS'@g' \
	-e 's@PSYFACES@'$PSYFACES'@g' \
	-e 's@PSYLANDS@'$PSYLANDS'@g' \
	-e 's@RTNEXTPARAMET_FACES@'$PSYFACESRT'@g' \
	-e 's@RTNEXTPARAMET_LANDS@'$PSYLANDSRT'@g' \
	-e 's@TSDMN@'$TSDMN'@g' \
	-e 's@TSECN@'$TSECN'@g' \
	-e 's@HITEV@'$HITEV'@g' \
	-e 's@MISSEV@'$MISSEV'@g' \
	-e 's@FACECUES@'$FACECUES'@g' \
	-e 's@LANDCUES@'$LANDCUES'@g' \
	-e 's@IC1@'$COMP1'@g' \
	-e 's@IC2@'$COMP2'@g' \
	-e 's@IC5@'$COMP5'@g' \
	-e 's@IC8@'$COMP8'@g' \
	-e 's@IC9@'$COMP9'@g' \
	-e 's@ic10@'$Comp10'@g' \
	-e 's@ic11@'$Comp11'@g' \
	-e 's@ic12@'$Comp12'@g' \
	-e 's@ic13@'$Comp13'@g' \
	-e 's@ic14@'$Comp14'@g' \
	-e 's@ic15@'$Comp15'@g' \
	-e 's@ic16@'$Comp16'@g' \
	-e 's@ic17@'$Comp17'@g' \
	-e 's@ic18@'$Comp18'@g' \
	-e 's@ic19@'$Comp19'@g' \
	-e 's@ic20@'$Comp20'@g' \
	-e 's@ic21@'$Comp21'@g' \
	-e 's@ic22@'$Comp22'@g' \
	-e 's@ic23@'$Comp23'@g' \
	-e 's@ic24@'$Comp24'@g' \
	-e 's@ic25@'$Comp25'@g' \
	-e 's@LFP@'$LFP'@g' \
	-e 's@RFP@'$RFP'@g' \
	<$TEMPLATE> ${SUBJDIR}/SR02_gPPI_allDRts_newzerooptions_maineffects_edit.fsf
	
	feat ${SUBJDIR}/SR02_gPPI_allDRts_newzerooptions_maineffects_edit.fsf
	cp -r ${SUBJDIR}/reg ${OUTPUT}.feat/.
	
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
