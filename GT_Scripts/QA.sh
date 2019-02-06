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


SUBJ=$1
GO=2

DO_QA=1

#-----------RELEVANT EXCEPTIONS FOR FUNCTIONAL DATA-------- (not a complete list since only missing tasks are relevant for this script)

#--------end exceptions list-------


MAINDIR=${EXPERIMENT}/Analysis
cd $MAINDIR/NIFTI/${SUBJ}
for i in 1 2 3 4 5; do
	fslwrapbxh fMRIphysio${i}new${SUBJ}.nii.gz
done

QA_OUTPUT=$MAINDIR/NIFTI/${SUBJ}/QA_HighRes
if [ $GO -eq 1 ]; then
	rm -rf ${QA_OUTPUT}
fi
if [ -s $QA_OUTPUT/SFNR_run1.txt ]; then #test that the file is there and not empty
	echo "already exists and isn't empty: $QA_OUTPUT/SFNR_run1.txt"
	DO_QA=0
else
	rm -rf ${QA_OUTPUT}
fi

if [ $DO_QA -eq 1 ]; then
	cd $MAINDIR/NIFTI/${SUBJ}
	fmriqa_generate.pl --overwrite *.bxh ${QA_OUTPUT}
	if [ -d $QA_OUTPUT ]; then
		cd ${QA_OUTPUT}
		OUTDIR=${EXPERIMENT}/Analysis/NIFTI/Logs/QA/success
	else
		OUTDIR=${EXPERIMENT}/Analysis/NIFTI/Logs/QA/fail
		echo "FAIL: $QA_OUTPUT"
	fi
	grep 'mean SFNR (ROI in middle slice)' index.html | awk '{print $7}' > temp.txt
	#OUTPUT ASSUMING 3 RUNS: slice)</td><td>87.2</td><td>84.1</td><td>82.4</td></tr>
	sed -e 's@</td>@'"   "'@g' -e 's@<td>@'"   "'@g' <temp.txt> new_temp.txt
	#OUTPUT ASSUMING 3 RUNS: slice)      87.2      84.1      82.4   </tr>
	#awk '{print $1}' new_temp.txt # slice)
	awk '{print $2}' new_temp.txt > SFNR_run1.txt # 87.2
	awk '{print $3}' new_temp.txt > SFNR_run2.txt # 84.1
	awk '{print $4}' new_temp.txt > SFNR_run3.txt # 82.4
	awk '{print $5}' new_temp.txt > SFNR_run4.txt # 82.4
	awk '{print $6}' new_temp.txt > SFNR_run5.txt # 82.4
	rm temp.txt new_temp.txt
else
	OUTDIR=${EXPERIMENT}/Analysis/NIFTI/Logs/QA/skipped
fi


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
