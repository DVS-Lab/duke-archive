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
# #$ -M smith@biac.duke.edu
# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here


# FSLDIR=/usr/local/fsl-4.1.4-centos4_64
# export FSLDIR
# source $FSLDIR/etc/fslconf/fsl.sh


COPE=$1
CNAME=$2
ROI=PCC1
FILTER=$3

MAINDIR=${EXPERIMENT}/Analysis/Resting_Default-Network
preOUTPUT=${MAINDIR}/Level3/${ROI}_${FILTER}
mkdir -p $preOUTPUT
OUTDIR=$preOUTPUT
OUTPUT=${preOUTPUT}/C${COPE}_${CNAME} #will be the name of the new fsf file
rm -rf $OUTPUT.gfeat

N=0
for SUBJ in 10168 10181 10199 10255 10279 10281 10286 10304 10305 10306 10314 10315 10335 10350 10351 10352 10358 10359 10360 10414 10415 10416 10424 10425 10426 10472 10474 10482 10483 10512 10515 10521 10523 10524 10525 10558 10560 10565 10583 10605 10615 10657 10659 10665 10670 10696 10697 10698 10699 10705 10706 10707 10746 10747 10749 10757 10762 10782 10785 10793 10794 10795 10817 10827 10844 10845 10858; do

	let N=$N+1
	FILENAME=${MAINDIR}/${SUBJ}/${SUBJ}_${ROI}_${FILTER}.feat/stats/cope${COPE}.nii.gz
	NN=`printf '%03d' $N` #this pads the numbers with zero
	eval INPUT${NN}=${FILENAME}

done

TEMPLATE=${EXPERIMENT}/Analysis/Resting_Default-Network/Templates/L3_n67.fsf
NEWFEATFILE=${OUTPUT}.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT001@'$INPUT001'@g' \
-e 's@INPUT002@'$INPUT002'@g' \
-e 's@INPUT003@'$INPUT003'@g' \
-e 's@INPUT004@'$INPUT004'@g' \
-e 's@INPUT005@'$INPUT005'@g' \
-e 's@INPUT006@'$INPUT006'@g' \
-e 's@INPUT007@'$INPUT007'@g' \
-e 's@INPUT008@'$INPUT008'@g' \
-e 's@INPUT009@'$INPUT009'@g' \
-e 's@INPUT010@'$INPUT010'@g' \
-e 's@INPUT011@'$INPUT011'@g' \
-e 's@INPUT012@'$INPUT012'@g' \
-e 's@INPUT013@'$INPUT013'@g' \
-e 's@INPUT014@'$INPUT014'@g' \
-e 's@INPUT015@'$INPUT015'@g' \
-e 's@INPUT016@'$INPUT016'@g' \
-e 's@INPUT017@'$INPUT017'@g' \
-e 's@INPUT018@'$INPUT018'@g' \
-e 's@INPUT019@'$INPUT019'@g' \
-e 's@INPUT020@'$INPUT020'@g' \
-e 's@INPUT021@'$INPUT021'@g' \
-e 's@INPUT022@'$INPUT022'@g' \
-e 's@INPUT023@'$INPUT023'@g' \
-e 's@INPUT024@'$INPUT024'@g' \
-e 's@INPUT025@'$INPUT025'@g' \
-e 's@INPUT026@'$INPUT026'@g' \
-e 's@INPUT027@'$INPUT027'@g' \
-e 's@INPUT028@'$INPUT028'@g' \
-e 's@INPUT029@'$INPUT029'@g' \
-e 's@INPUT030@'$INPUT030'@g' \
-e 's@INPUT031@'$INPUT031'@g' \
-e 's@INPUT032@'$INPUT032'@g' \
-e 's@INPUT033@'$INPUT033'@g' \
-e 's@INPUT034@'$INPUT034'@g' \
-e 's@INPUT035@'$INPUT035'@g' \
-e 's@INPUT036@'$INPUT036'@g' \
-e 's@INPUT037@'$INPUT037'@g' \
-e 's@INPUT038@'$INPUT038'@g' \
-e 's@INPUT039@'$INPUT039'@g' \
-e 's@INPUT040@'$INPUT040'@g' \
-e 's@INPUT041@'$INPUT041'@g' \
-e 's@INPUT042@'$INPUT042'@g' \
-e 's@INPUT043@'$INPUT043'@g' \
-e 's@INPUT044@'$INPUT044'@g' \
-e 's@INPUT045@'$INPUT045'@g' \
-e 's@INPUT046@'$INPUT046'@g' \
-e 's@INPUT047@'$INPUT047'@g' \
-e 's@INPUT048@'$INPUT048'@g' \
-e 's@INPUT049@'$INPUT049'@g' \
-e 's@INPUT050@'$INPUT050'@g' \
-e 's@INPUT051@'$INPUT051'@g' \
-e 's@INPUT052@'$INPUT052'@g' \
-e 's@INPUT053@'$INPUT053'@g' \
-e 's@INPUT054@'$INPUT054'@g' \
-e 's@INPUT055@'$INPUT055'@g' \
-e 's@INPUT056@'$INPUT056'@g' \
-e 's@INPUT057@'$INPUT057'@g' \
-e 's@INPUT058@'$INPUT058'@g' \
-e 's@INPUT059@'$INPUT059'@g' \
-e 's@INPUT060@'$INPUT060'@g' \
-e 's@INPUT061@'$INPUT061'@g' \
-e 's@INPUT062@'$INPUT062'@g' \
-e 's@INPUT063@'$INPUT063'@g' \
-e 's@INPUT064@'$INPUT064'@g' \
-e 's@INPUT065@'$INPUT065'@g' \
-e 's@INPUT066@'$INPUT066'@g' \
-e 's@INPUT067@'$INPUT067'@g' \
<${TEMPLATE}> $NEWFEATFILE

#run feat file
$FSLDIR/bin/feat $NEWFEATFILE


# cd $OUTPUT.gfeat
# rm -f cope1.feat/filtered_func_data.nii.gz
# rm -f cope1.feat/stats/res4d.nii.gz
# rm -f cope1.feat/var_filtered_func_data.nii.gz




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
