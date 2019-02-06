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

ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/HighRes.01
sleep 5s

SUBJ_FULL=$1
SUBJ=$2

MAINDIR=${EXPERIMENT}/Analysis

#make nii
OUTPUT=${EXPERIMENT}/Analysis/NIFTI/${SUBJ}
mkdir -p $OUTPUT
~/dcm2nii -o ${OUTPUT} ${EXPERIMENT}/Data/MRI/${SUBJ_FULL}


# #for testing only
# OUTPUT2=${EXPERIMENT}/Analysis/NIFTI2/${SUBJ}
# cp -r $OUTPUT $OUTPUT2
# RAWANAT=$MAINDIR/NIFTI2/${SUBJ}/coT1mprage${SUBJ}.nii.gz
# FLIPPEDANAT=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat.nii.gz
# fslmaths ${RAWANAT} ${FLIPPEDANAT}
# fslswapdim ${RAWANAT} -x y z ${FLIPPEDANAT}
# fslorient -forceradiological ${FLIPPEDANAT}
# ANAT=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat_brain.nii.gz
# bet ${FLIPPEDANAT} ${ANAT} -R

cd $MAINDIR/NIFTI/${SUBJ}
pwd
if [ $SUBJ -eq 1008 ]; then
	mv coT1mprage${SUBJ}2.nii.gz coT1mprage${SUBJ}.nii.gz
	mv ep2dDTI30direction${SUBJ}2.nii.gz ep2dDTI30direction${SUBJ}.nii.gz
	mv ep2dDTI30direction${SUBJ}2.bvec ep2dDTI30direction${SUBJ}.bvec
	mv ep2dDTI30direction${SUBJ}2.bval ep2dDTI30direction${SUBJ}.bval

	for i in 1 2 3 4 5; do
		mv fMRIphysio${i}new${SUBJ}2.nii.gz fMRIphysio${i}new${SUBJ}.nii.gz
	done
	mv fMRIphysiowholebrain${SUBJ}2.nii.gz fMRIphysiowholebrain${SUBJ}.nii.gz
	mv fMRIphysioRest${SUBJ}2.nii.gz fMRIphysioRest${SUBJ}.nii.gz
	mv grefieldmapping${SUBJ}2A.nii.gz grefieldmapping${SUBJ}A.nii.gz
	mv grefieldmapping${SUBJ}2B.nii.gz grefieldmapping${SUBJ}B.nii.gz
	mv grefieldmapping${SUBJ}2.nii.gz grefieldmapping${SUBJ}.nii.gz
	mv oT1mprage${SUBJ}2.nii.gz oT1mprage${SUBJ}.nii.gz
	mv oT2space${SUBJ}2.nii.gz oT2space${SUBJ}.nii.gz
	mv T1mprage${SUBJ}2.nii.gz T1mprage${SUBJ}.nii.gz
	mv T2space${SUBJ}2.nii.gz T2space${SUBJ}.nii.gz
fi

if [ $SUBJ -eq 1006 ]; then
	#mv coT1mprage${SUBJ}2.nii.gz coT1mprage${SUBJ}.nii.gz
	mv ep2dDTI30direction${SUBJ}2.nii.gz ep2dDTI30direction${SUBJ}.nii.gz
	mv ep2dDTI30direction${SUBJ}2.bvec ep2dDTI30direction${SUBJ}.bvec
	mv ep2dDTI30direction${SUBJ}2.bval ep2dDTI30direction${SUBJ}.bval

	for i in 3 4 5; do
		mv fMRIphysio${i}new${SUBJ}2.nii.gz fMRIphysio${i}new${SUBJ}.nii.gz
	done
	mv fMRIphysiowholebrain${SUBJ}2.nii.gz fMRIphysiowholebrain${SUBJ}.nii.gz
	mv fMRIphysioRest${SUBJ}2.nii.gz fMRIphysioRest${SUBJ}.nii.gz
	mv grefieldmapping${SUBJ}2A.nii.gz grefieldmapping${SUBJ}A.nii.gz
	mv grefieldmapping${SUBJ}2B.nii.gz grefieldmapping${SUBJ}B.nii.gz
	mv grefieldmapping${SUBJ}2.nii.gz grefieldmapping${SUBJ}.nii.gz
	#mv oT1mprage${SUBJ}2.nii.gz oT1mprage${SUBJ}.nii.gz
	mv oT2space${SUBJ}2.nii.gz oT2space${SUBJ}.nii.gz
	#mv T1mprage${SUBJ}2.nii.gz T1mprage${SUBJ}.nii.gz
	mv T2space${SUBJ}2.nii.gz T2space${SUBJ}.nii.gz
fi


RAWANAT=$MAINDIR/NIFTI/${SUBJ}/coT1mprage${SUBJ}.nii.gz
FLIPPEDANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat.nii.gz
fslmaths ${RAWANAT} ${FLIPPEDANAT}
# fslswapdim ${RAWANAT} -x y z ${FLIPPEDANAT}
# fslorient -forceradiological ${FLIPPEDANAT}


#export ARTHOME=${ARTHOME:="$HOME/acpc"}
#  $ARTHOME/acpcdetect -v -sform -i ~/t1.nii ~/fmri1.nii ~/fmri2.nii
#  $ARTHOME/acpcdetect -v -qform -sform -i ~/t1.nii


cd $MAINDIR/NIFTI/${SUBJ}
if [ $SUBJ -lt 1002 ]; then
	~/setorigin ${FLIPPEDANAT} coT1mprage${SUBJ}.nii.gz ep2dDTI30direction${SUBJ}.nii.gz fMRIphysio1new${SUBJ}.nii.gz fMRIphysio2new${SUBJ}.nii.gz fMRIphysio3new${SUBJ}.nii.gz fMRIphysio4new${SUBJ}.nii.gz fMRIphysio5new${SUBJ}.nii.gz fMRIphysioRest${SUBJ}.nii.gz grefieldmapping${SUBJ}A.nii.gz grefieldmapping${SUBJ}B.nii.gz grefieldmapping${SUBJ}.nii.gz oT1mprage${SUBJ}.nii.gz oT2space${SUBJ}.nii.gz T1mprage${SUBJ}.nii.gz T2space${SUBJ}.nii.gz
elif [ $SUBJ -eq 1023 ]; then
	~/setorigin ${FLIPPEDANAT} coT1mprage${SUBJ}.nii.gz fMRIphysio1new${SUBJ}.nii.gz fMRIphysio2new${SUBJ}.nii.gz fMRIphysio3new${SUBJ}.nii.gz fMRIphysio4new${SUBJ}.nii.gz fMRIphysio5new${SUBJ}.nii.gz fMRIphysiowholebrain${SUBJ}.nii.gz  grefieldmapping${SUBJ}A.nii.gz grefieldmapping${SUBJ}B.nii.gz grefieldmapping${SUBJ}.nii.gz oT1mprage${SUBJ}.nii.gz oT2space${SUBJ}.nii.gz T1mprage${SUBJ}.nii.gz T2space${SUBJ}.nii.gz
elif [ $SUBJ -gt 1023 ]; then
	~/setorigin ${FLIPPEDANAT} coT1mprage${SUBJ}.nii.gz ep2dDTI30direction${SUBJ}.nii.gz fMRIphysio1new${SUBJ}.nii.gz fMRIphysio2new${SUBJ}.nii.gz fMRIphysio3new${SUBJ}.nii.gz fMRIphysio4new${SUBJ}.nii.gz fMRIphysio5new${SUBJ}.nii.gz fMRIphysiowholebrain${SUBJ}.nii.gz grefieldmapping${SUBJ}A.nii.gz grefieldmapping${SUBJ}B.nii.gz grefieldmapping${SUBJ}.nii.gz oT1mprage${SUBJ}.nii.gz T1mprage${SUBJ}.nii.gz
else
	~/setorigin ${FLIPPEDANAT} coT1mprage${SUBJ}.nii.gz ep2dDTI30direction${SUBJ}.nii.gz fMRIphysio1new${SUBJ}.nii.gz fMRIphysio2new${SUBJ}.nii.gz fMRIphysio3new${SUBJ}.nii.gz fMRIphysio4new${SUBJ}.nii.gz fMRIphysio5new${SUBJ}.nii.gz fMRIphysiowholebrain${SUBJ}.nii.gz fMRIphysioRest${SUBJ}.nii.gz grefieldmapping${SUBJ}A.nii.gz grefieldmapping${SUBJ}B.nii.gz grefieldmapping${SUBJ}.nii.gz oT1mprage${SUBJ}.nii.gz oT2space${SUBJ}.nii.gz T1mprage${SUBJ}.nii.gz T2space${SUBJ}.nii.gz
fi


ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain.nii.gz
$FSLDIR/bin/bet ${FLIPPEDANAT} ${ANAT} -R


OUTDIR=${MAINDIR}/NIFTI/Logs
mkdir -p $OUTDIR

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
