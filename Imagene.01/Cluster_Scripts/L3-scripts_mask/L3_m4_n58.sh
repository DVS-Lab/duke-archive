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


FSLDIR=/usr/local/fsl-4.1.4-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh


COPE=SUB_COPE_SUB
CNAME=SUB_CNAME_SUB


MAINDIR=${EXPERIMENT}/Analysis/Framing/FSL
preOUTPUT=${MAINDIR}/Level3/high_thresh/Model4
mkdir -p $preOUTPUT

OUTPUT=${preOUTPUT}/C${COPE}_${CNAME}

rm -rf $OUTPUT.gfeat

N=0
for SUBJ in 47729 47731 47734 47735 47748 47752 47851 47863 47878 47885 47917 47921 47945 47977 48012 48061 48066 48090 48097 48100 48103 48112 48145 48150 48152 48156 48158 48160 48165 48167 48176 48179 48184 48187 48189 48196 48197 48204 48206 48232 48271 48281 48288 48297 48301 48309 48312 48321 48326 48327 48330 48335 48337 48339 48344 48349 48350 48351; do

	let N=$N+1
	FILENAME=${MAINDIR}/${SUBJ}/${SUBJ}_model4.gfeat/cope${COPE}.feat/stats/cope1.nii.gz
	NN=`printf '%03d' $N` #this pads the numbers with zero
	eval INPUT${NN}=${FILENAME}

done

# Y:\Huettel\Imagene.01\Analysis\Framing\Templates
TEMPLATEDIR=${EXPERIMENT}/Analysis/Framing/Templates
cd ${TEMPLATEDIR}
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
<L3_n58t.fsf> ${MAINDIR}/Level3/Model4/L3_n58_${CNAME}.fsf

$FSLDIR/bin/feat ${MAINDIR}/Level3/Model4/L3_n58_${CNAME}.fsf

cd $OUTPUT.gfeat
rm -f cope1.feat/filtered_func_data.nii.gz
rm -f cope1.feat/stats/res4d.nii.gz
rm -f cope1.feat/var_filtered_func_data.nii.gz




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
