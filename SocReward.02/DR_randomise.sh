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
#$ -M jac44@duke.edu

# -- END USER DIRECTIVE --

# -- BEGIN USER SCRIPT --
# User script goes here

ICABASE=$1 #what is the name your ICA output 
DESIGN=$2 #and DR output? 
ICNUM=$3 #which component are you testing (0 to N-1)?
NCONTRASTS=$4 #how many contrasts are in your design.con file?


# this script will also assume that the design.con and design.mat files in $DROUTPUT are correct and valid the subject order of the files in that folder. this is definitely the most important thing, so if you have those ready with each dual regression submission, just ignore my suggestion about doing the t-test (i.e., using -1 in place of the two inputs in your dr command). make sense?

# this script also assumes you ran the default DR script:
#------dual_regression groupICA.gica/groupmelodic.ica/melodic_IC 1 design.mat design.con 0 output `cat groupICA.gica/.filelist`-------
#still use the trick i made for editing the .filelist file and writing a new one with the correct paths.
#remember, group identifiers need to be consistent, make sure the inputs/IDs in design.mat correspond to what you think they correspond to in the .filelist.



MAINDIR=${EXPERIMENT}/Analysis/FSL
OUTPUT=$MAINDIR/${ICABASE}.gica/DR_output_${DESIGN}

IC=`$FSLDIR/bin/zeropad $ICNUM 4`

#randomise command
$FSLDIR/bin/randomise -i $OUTPUT/dr_stage2_ic$IC -o $OUTPUT/dr_stage3b_ic$IC -m $OUTPUT/mask -d $OUTPUT/design.mat -t $OUTPUT/design.con -n 10000 -v 5 -T

#threshold output
for C in `seq $NCONTRASTS`; do
	$FSLDIR/bin/fslmaths $OUTPUT/dr_stage3b_ic${IC}_tfce_corrp_tstat${C} -thr 0.95 $OUTPUT/thresh_dr_stage3b_ic${IC}_tfce_corrp_tstat${C}
done

OUTDIR=$MAINDIR/Logs
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
