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



FSLDIR=/usr/local/fsl-4.1.0-centos4_64
export FSLDIR
source $FSLDIR/etc/fslconf/fsl.sh

#Vinod:  L:\Imagene.01\Analysis\Framing\FSL\47729\47729_model3_slbycope\cope9.gfeat\cope1.feat
#thats an example of second level output.. u shud use copes 9, 10, 11 and 12 in order.. so all 61 cope9s, #then 61 cope10s and so on.
# Sent at 3:13 PM on Thursday
# me:  13, 14, 15, 16 is charity

MAINDIR=${EXPERIMENT}/Analysis/Framing/FSL
OUTPUT=${MAINDIR}/Level3/N35_Model3/Paired_t-test_n35_SGmSS-CGmCS
#SGmSS-CGmCS
# Y:\Huettel\Imagene.01\Analysis\Framing\FSL\47731\47731_model3_sl.gfeat

N=0
for COPE in 17 19; do 
for SUBJ in 47731 47734 47735 47748 47752 47885 47945 47977 48066 48090 48097 48100 48103 48123 48145 48152 48156 48158 48165 48176 48187 48193 48206 48232 48271 48281  48301 48309 48312 48326 48327 48330 48335 48337 48351; do
		let N=$N+1
		FILENAME=${MAINDIR}/${SUBJ}/${SUBJ}_model3_sl.gfeat/cope${COPE}.feat/stats/cope1.nii.gz
		if [ $N -lt 10 ]; then
			eval INPUT0${N}=${FILENAME}
		else
			eval INPUT${N}=${FILENAME}
		fi
done
done

# Y:\Huettel\Imagene.01\Analysis\Framing\Templates
TEMPLATEDIR=${EXPERIMENT}/Analysis/Framing/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT01@'$INPUT01'@g' \
-e 's@INPUT02@'$INPUT02'@g' \
-e 's@INPUT03@'$INPUT03'@g' \
-e 's@INPUT04@'$INPUT04'@g' \
-e 's@INPUT05@'$INPUT05'@g' \
-e 's@INPUT06@'$INPUT06'@g' \
-e 's@INPUT07@'$INPUT07'@g' \
-e 's@INPUT08@'$INPUT08'@g' \
-e 's@INPUT09@'$INPUT09'@g' \
-e 's@INPUT10@'$INPUT10'@g' \
-e 's@INPUT11@'$INPUT11'@g' \
-e 's@INPUT12@'$INPUT12'@g' \
-e 's@INPUT13@'$INPUT13'@g' \
-e 's@INPUT14@'$INPUT14'@g' \
-e 's@INPUT15@'$INPUT15'@g' \
-e 's@INPUT16@'$INPUT16'@g' \
-e 's@INPUT17@'$INPUT17'@g' \
-e 's@INPUT18@'$INPUT18'@g' \
-e 's@INPUT19@'$INPUT19'@g' \
-e 's@INPUT20@'$INPUT20'@g' \
-e 's@INPUT21@'$INPUT21'@g' \
-e 's@INPUT22@'$INPUT22'@g' \
-e 's@INPUT23@'$INPUT23'@g' \
-e 's@INPUT24@'$INPUT24'@g' \
-e 's@INPUT25@'$INPUT25'@g' \
-e 's@INPUT26@'$INPUT26'@g' \
-e 's@INPUT27@'$INPUT27'@g' \
-e 's@INPUT28@'$INPUT28'@g' \
-e 's@INPUT29@'$INPUT29'@g' \
-e 's@INPUT30@'$INPUT30'@g' \
-e 's@INPUT31@'$INPUT31'@g' \
-e 's@INPUT32@'$INPUT32'@g' \
-e 's@INPUT33@'$INPUT33'@g' \
-e 's@INPUT34@'$INPUT34'@g' \
-e 's@INPUT35@'$INPUT35'@g' \
-e 's@INPUT36@'$INPUT36'@g' \
-e 's@INPUT37@'$INPUT37'@g' \
-e 's@INPUT38@'$INPUT38'@g' \
-e 's@INPUT39@'$INPUT39'@g' \
-e 's@INPUT40@'$INPUT40'@g' \
-e 's@INPUT41@'$INPUT41'@g' \
-e 's@INPUT42@'$INPUT42'@g' \
-e 's@INPUT43@'$INPUT43'@g' \
-e 's@INPUT44@'$INPUT44'@g' \
-e 's@INPUT45@'$INPUT45'@g' \
-e 's@INPUT46@'$INPUT46'@g' \
-e 's@INPUT47@'$INPUT47'@g' \
-e 's@INPUT48@'$INPUT48'@g' \
-e 's@INPUT49@'$INPUT49'@g' \
-e 's@INPUT50@'$INPUT50'@g' \
-e 's@INPUT51@'$INPUT51'@g' \
-e 's@INPUT52@'$INPUT52'@g' \
-e 's@INPUT53@'$INPUT53'@g' \
-e 's@INPUT54@'$INPUT54'@g' \
-e 's@INPUT55@'$INPUT55'@g' \
-e 's@INPUT56@'$INPUT56'@g' \
-e 's@INPUT57@'$INPUT57'@g' \
-e 's@INPUT58@'$INPUT58'@g' \
-e 's@INPUT59@'$INPUT59'@g' \
-e 's@INPUT60@'$INPUT60'@g' \
-e 's@INPUT61@'$INPUT61'@g' \
-e 's@INPUT62@'$INPUT62'@g' \
-e 's@INPUT63@'$INPUT63'@g' \
-e 's@INPUT64@'$INPUT64'@g' \
-e 's@INPUT65@'$INPUT65'@g' \
-e 's@INPUT66@'$INPUT66'@g' \
-e 's@INPUT67@'$INPUT67'@g' \
-e 's@INPUT68@'$INPUT68'@g' \
-e 's@INPUT69@'$INPUT69'@g' \
-e 's@INPUT70@'$INPUT70'@g' \
<paired_t-test_n35.fsf> ${MAINDIR}/Level3/N35_Model3/Paired_t-test_n35.fsf

feat ${MAINDIR}/Level3/N35_Model3/Paired_t-test_n35.fsf
cd $OUTPUT.gfeat
rm -f filtered_func_data.nii.gz
rm -f stats/res4d.nii.gz
rm -f var_filtered_func_data.nii.gz



OUTDIR=${MAINDIR}/Level3/Model3bycope/

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
