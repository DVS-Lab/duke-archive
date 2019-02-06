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

SUBJ=$1

DATADIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/Passive/MELODIC
for SMOOTH in 6 0; do
	for RUN in 1 2 3; do
		RUNDIR=${DATADIR}/Smooth_${SMOOTH}mm/run${RUN}.ica
		cd ${DATADIR}/Smooth_${SMOOTH}mm/crap_new
		CRAP=`cat run${RUN}.txt`
		cd $RUNDIR
		rm -f denoised_data.nii.gz
		if [ -n "$CRAP" ]; then
			REGFILTCMD="fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f $CRAP"
			eval $REGFILTCMD
			echo $REGFILTCMD
			echo "${SUBJ} ${RUN} == success!"
		else
			cp filtered_func_data.nii.gz denoised_data.nii.gz
			echo "no bad components for ${SUBJ} ${RUN}. renaming input file to match others..."
		fi
	done
done

DATADIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/Active/MELODIC
for SMOOTH in 6 0; do
	for RUN in 1 2; do
		RUNDIR=${DATADIR}/Smooth_${SMOOTH}mm/run${RUN}.ica
		cd ${DATADIR}/Smooth_${SMOOTH}mm/crap_new
		CRAP=`cat run${RUN}.txt`
		cd $RUNDIR
		rm -f denoised_data.nii.gz
		if [ -n "$CRAP" ]; then
			REGFILTCMD="fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f $CRAP"
			eval $REGFILTCMD
			echo $REGFILTCMD
			echo "${SUBJ} ${RUN} == success!"
		else
			cp filtered_func_data.nii.gz denoised_data.nii.gz
			echo "no bad components for ${SUBJ} ${RUN}. renaming input file to match others..."
		fi
	done
done

DATADIR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/PassiveCued/MELODIC

if [ $SUBJ -eq 35086 ]; then

	for SMOOTH in 6 0; do
		for RUN in 1; do
			RUNDIR=${DATADIR}/Smooth_${SMOOTH}mm/run${RUN}.ica
			cd ${DATADIR}/Smooth_${SMOOTH}mm/crap_new
			CRAP=`cat run${RUN}.txt`
			cd $RUNDIR
			rm -f denoised_data.nii.gz
			if [ -n "$CRAP" ]; then
				REGFILTCMD="fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f $CRAP"
				eval $REGFILTCMD
				echo $REGFILTCMD
				echo "${SUBJ} ${RUN} == success!"
			else
				cp filtered_func_data.nii.gz denoised_data.nii.gz
				echo "no bad components for ${SUBJ} ${RUN}. renaming input file to match others..."
			fi
		done
	done

else
	
	for SMOOTH in 6 0; do
		for RUN in 1 2; do
			RUNDIR=${DATADIR}/Smooth_${SMOOTH}mm/run${RUN}.ica
			cd ${DATADIR}/Smooth_${SMOOTH}mm/crap_new
			CRAP=`cat run${RUN}.txt`
			cd $RUNDIR
			rm -f denoised_data.nii.gz
			if [ -n "$CRAP" ]; then
				REGFILTCMD="fsl_regfilt -i filtered_func_data -o denoised_data -d filtered_func_data.ica/melodic_mix -f $CRAP"
				eval $REGFILTCMD
				echo $REGFILTCMD
				echo "${SUBJ} ${RUN} == success!"
			else
				cp filtered_func_data.nii.gz denoised_data.nii.gz
				echo "no bad components for ${SUBJ} ${RUN}. renaming input file to match others..."
			fi
		done
	done

fi

# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=$DATADIR/ClusterLogs/081130_Denoiser_NEW
mkdir -p $OUTDIR
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
