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


ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02
sleep 5s

MAINDIR=/mnt/BIAC/munin.dhe.duke.edu/Huettel/Imagene.02/Analysis/TaskData

SUBJ=$1
TASK=$2
RUN=$3
GO=2

FEATOUTPUT=${MAINDIR}/${SUBJ}/${TASK}/MELODIC_FNIRT/Smooth_6mm/run${RUN}.ica
DATADIR=${MAINDIR}/${SUBJ}/${TASK}/MELODIC_150/Smooth_6mm/run${RUN}.ica
DATA=${DATADIR}/unconfounded_data.nii.gz

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

if [ -e ${DATA} ]; then

	#nonlinear
	OUT2N=${DATADIR}/std_unconfounded_data_fnirt_2mm.nii.gz
	OUT3N=${DATADIR}/std_unconfounded_data_fnirt_3mm.nii.gz
	check_data $OUT2N
	check_data $OUT3N
	if [ $GO -eq 1 ]; then
		rm -rf $OUT2N
		rm -rf $OUT3N
	fi
	if [ ! -e ${OUT2N} ]; then
		applywarp --ref=${FEATOUTPUT}/reg/standard --in=${DATA} --out=${OUT2N} --warp=${FEATOUTPUT}/reg/highres2standard_warp --premat=${FEATOUTPUT}/reg/example_func2highres.mat --interp=spline
		fslmaths ${OUT2N} -thr 10 ${OUT2N}
		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/redo
	else
		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/done
	fi
# 	if [ ! -e ${OUT3N} ]; then
# 		echo "tried to do 3mm FNIRT..."
# 		#fslcreatehd 60 72 60 1 3 3 3 1 0 0 0 16 ${DATADIR}/std_unconfounded_data_rereg_test.nii.gz_tmp.nii.gz
# 		flirt -ref ${FEATOUTPUT}/reg/standard -in ${FEATOUTPUT}/reg/standard -out ${FEATOUTPUT}/reg/standard_3mm -applyisoxfm 3
# 		flirt -ref ${FEATOUTPUT}/reg/standard_3mm -in ${OUT2N} -applyisoxfm 3 -init ${FSLDIR}/etc/flirtsch/ident.mat -out ${OUT3N} -paddingsize 0.0 -interp sinc -sincwidth 7 -sincwindow hanning
# 		fslmaths ${OUT3N} -thr 10 ${OUT3N}
# 		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/redo
# 	else
# 		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/done
# 	fi

	#linear
# 	OUT2=${DATADIR}/std_unconfounded_data_flirt_2mm.nii.gz
# 	OUT3=${DATADIR}/std_unconfounded_data_flirt_3mm.nii.gz
# 	check_data $OUT2
# 	check_data $OUT3
# 	if [ $GO -eq 1 ]; then
# 		rm -rf $OUT2
# 		rm -rf $OUT3
# 	fi
# 	if [ ! -e $OUT2 ]; then
# 		flirt -ref ${FEATOUTPUT}/reg/standard -in ${DATA} -out ${OUT2} -applyxfm -init ${FEATOUTPUT}/reg/example_func2standard.mat -interp sinc -datatype float
# 		fslmaths ${OUT2} -thr 10 ${OUT2}
# 		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/redo
# 	else
# 		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/done
# 	fi
# 	if [ ! -e $OUT3 ]; then
# 		flirt -ref ${FEATOUTPUT}/reg/standard -in ${DATA} -out ${OUT3} -applyisoxfm 3 -init ${FEATOUTPUT}/reg/example_func2standard.mat -interp sinc -datatype float
# 		fslmaths ${OUT3} -thr 10 ${OUT3}
# 		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/redo
# 	else
# 		OUTDIR=$MAINDIR/groupICA_AU/Logs/DVSnormalization2/done
# 	fi

else
	echo "no data??"
fi

# #transforms above output from 2x2x2 to 3x3x3mm with dimensions of 60x72x60
# if [ -e ${OUT} ]; then
# 	fslcreatehd 60 72 60 1 3 3 3 1 0 0 0 16 ${DATADIR}/std_unconfounded_data_rereg_test.nii.gz_tmp.nii.gz
# 	flirt -in ${OUT} -applyisoxfm 3 -init ${FSLDIR}/etc/flirtsch/ident.mat -out ${DATADIR}/std_unconfounded_data_rereg_3mm.nii.gz -paddingsize 0.0 -interp sinc -sincwidth 7 -sincwindow hanning -ref ${DATADIR}/std_unconfounded_data_rereg_test.nii.gz_tmp
# else
# 	echo "no data??"
# fi


#linear
##Flirt [options] -in <inputvol> -ref <refvol> -applyxfm -init <matrix> -out <outputvol>
##flirt -in ${DATA} -ref ${FEATOUTPUT}/reg/standard -applyxfm -init ${FEATOUTPUT}/reg/example_func2standard.mat -out ${DATADIR}/std_unconfounded_data_flirt





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
