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
# #$ -M njc8@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02
sleep 5s

#---------delete junk---------

function check_data {
	FILE_TO_CHECK=$1
	echo "using function..."
	if [ -e ${FILE_TO_CHECK} ]; then
		XX=`fslstats $FILE_TO_CHECK -m`
		echo $XX
		if [ $XX == "nan" ]; then
			echo "found $XX in the filtered func file. deleting and starting over..."
			rm -rf $FILE_TO_CHECK
		fi
		COL1=`fslstats $FILE_TO_CHECK -R | awk '{print $1}'`
		COL2=`fslstats $FILE_TO_CHECK -R | awk '{print $2}'`
		if [ "$COL2" == "inf" -o "$COL1" == "-nan" -o  "$COL2" == "-inf" -o "$COL1" == "nan" ]; then
			echo "data fail because of nans"
			rm -rf $FILE_TO_CHECK
		fi
		COL2_INT=${COL2/.*}
		COL1_INT=${COL1/.*}
		echo $COL1_INT
		echo $COL2_INT
		#if [ $COL2_INT -gt 200000 -o $COL1_INT -lt -200000 ]; then
		if [ ${#COL2} -gt 20 -o ${#COL1} -gt 20 ]; then
			echo "data fail because of really big fucking numbers"
			rm -rf $FILE_TO_CHECK
		fi
	else
		echo "can't find ${FILE_TO_CHECK}"
	fi

}
#---------delete junk---------


SUBJ=$1
GO=2

MAINDIR=/mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02/Analysis/TaskData
cd $MAINDIR




SMOOTH=6
for TASK in "Resting" "MID"; do
	if [ "$TASK" == "Resting" ]; then
		RUN=1
	else
		if [ $SUBJ -eq 10315 -o $SUBJ -eq 10424 -o $SUBJ -eq 10794 -o $SUBJ -eq 11328 -o $SUBJ -eq 11371 -o $SUBJ -eq 12294 -o $SUBJ -eq 12665 -o $SUBJ -eq 12758 ]; then 
			RUN=2
		elif [ $SUBJ -eq 11067 -o $SUBJ -eq 11245 -o $SUBJ -eq 12988 ]; then
			RUN=3
		else
			RUN=1
		fi
	fi
	FEATOUTPUT=${MAINDIR}/${SUBJ}/${TASK}/MELODIC_FNIRT/Smooth_${SMOOTH}mm/run${RUN}.ica
	DATADIR=${MAINDIR}/${SUBJ}/${TASK}/MELODIC_150/Smooth_${SMOOTH}mm/run${RUN}.ica
	DATA=${DATADIR}/unconfounded_data.nii.gz
	
	if [ -e ${DATA} ]; then
	
		#nonlinear
		OUT2N=${DATADIR}/std_unconfounded_data_fnirt_2mm.nii.gz
		check_data $OUT2N
		if [ $GO -eq 1 ]; then
			rm -rf $OUT2N
		fi
		if [ ! -e ${OUT2N} ]; then
			applywarp --ref=${FEATOUTPUT}/reg/standard --in=${DATA} --out=${OUT2N} --warp=${FEATOUTPUT}/reg/highres2standard_warp --premat=${FEATOUTPUT}/reg/example_func2highres.mat --interp=spline
			fslmaths ${OUT2N} -thr 10 ${OUT2N}
			OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/redo
		else
			OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/done
		fi
	
		cd $MAINDIR/groupICA_AU/DVS/StriatumParcellation
		INFILE=${MAINDIR}/${SUBJ}/${TASK}/MELODIC_150/Smooth_${SMOOTH}mm/run${RUN}.ica/std_unconfounded_data_fnirt_2mm
		OUTFILE=${MAINDIR}/${SUBJ}/${TASK}/MELODIC_150/Smooth_${SMOOTH}mm/run${RUN}.ica/striatum_std_unconfounded_data_fnirt_2mm
		fslmaths $INFILE -mas StriatumMask_atlas $OUTFILE
	
	fi
done

#OUTDIR=$MAINDIR/groupICA_AU/DVS/StriatumParcellation/Logs
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
