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
SMOOTH=$2
FNIRT=$3
SETORIGIN=$4

GO=5
#qsub -v EXPERIMENT=HighRes.01 L2_highres.sh $SUBJ $S $F $SO


MAINDIR=${EXPERIMENT}/Analysis
if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FNIRT_new/Smooth_${SMOOTH}mm
else
	MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/Model04_FLIRT_new/Smooth_${SMOOTH}mm
fi
echo $MAINOUTPUT
NRUNS=5
INPUT01=${MAINOUTPUT}/run1.feat
INPUT02=${MAINOUTPUT}/run2.feat
INPUT03=${MAINOUTPUT}/run3.feat
INPUT04=${MAINOUTPUT}/run4.feat
INPUT05=${MAINOUTPUT}/run5.feat

# bad runs
# 1005: 4,5
# 1006: 4
# 1008: 5
# 1009: 2,3,4,5
# 1014: 4,5
# 1015: 1,4,5
# 1017: 2
# 1020: 5
# 1023: 2,3,4,5
if [ ${SUBJ} -eq 1005 ] || [ ${SUBJ} -eq 1014 ]; then
	INPUT01=${MAINOUTPUT}/run1.feat
	INPUT02=${MAINOUTPUT}/run2.feat
	INPUT03=${MAINOUTPUT}/run3.feat
	NRUNS=3
fi
if [ ${SUBJ} -eq 1015 ]; then
	INPUT01=${MAINOUTPUT}/run2.feat
	INPUT02=${MAINOUTPUT}/run3.feat
	NRUNS=2
fi
if [ ${SUBJ} -eq 1006 ]; then
	INPUT01=${MAINOUTPUT}/run1.feat
	INPUT02=${MAINOUTPUT}/run2.feat
	INPUT03=${MAINOUTPUT}/run3.feat
	INPUT04=${MAINOUTPUT}/run5.feat
	NRUNS=4
fi
if [ ${SUBJ} -eq 1008 ]; then
	INPUT01=${MAINOUTPUT}/run1.feat
	INPUT02=${MAINOUTPUT}/run2.feat
	INPUT03=${MAINOUTPUT}/run3.feat
	INPUT04=${MAINOUTPUT}/run4.feat
	NRUNS=4
fi
if [ ${SUBJ} -eq 1017 ]; then
	INPUT01=${MAINOUTPUT}/run1.feat
	INPUT02=${MAINOUTPUT}/run3.feat
	INPUT03=${MAINOUTPUT}/run4.feat
	INPUT04=${MAINOUTPUT}/run5.feat
	NRUNS=4
fi
if [ ${SUBJ} -eq 1020 ]; then
	INPUT01=${MAINOUTPUT}/run1.feat
	INPUT02=${MAINOUTPUT}/run2.feat
	INPUT03=${MAINOUTPUT}/run3.feat
	INPUT04=${MAINOUTPUT}/run4.feat
	NRUNS=4
fi


OUTPUT=${MAINOUTPUT}/Level2
if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.gfeat
fi
for C in `seq 18`; do
	CHECK_FILE=${OUTPUT}.gfeat/cope${C}.feat/cluster_mask_zstat1.nii.gz
	if [ ! -e $CHECK_FILE ]; then
		rm -rf ${OUTPUT}.gfeat
	fi
done

TEMPLATE=${MAINDIR}/FSL/templates/L2_template_${NRUNS}runs_m4.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT01@'$INPUT01'@g' \
-e 's@INPUT02@'$INPUT02'@g' \
-e 's@INPUT03@'$INPUT03'@g' \
-e 's@INPUT04@'$INPUT04'@g' \
-e 's@INPUT05@'$INPUT05'@g' \
<$TEMPLATE> ${MAINOUTPUT}/level2.fsf

if [ -d ${OUTPUT}.gfeat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/level2.fsf
fi

for C in `seq 18`; do
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/stats/res4d.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/filtered_func_data.nii.gz
done

OUTDIR=${MAINOUTPUT}/Logs
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
