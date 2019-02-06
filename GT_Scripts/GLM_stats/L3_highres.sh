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


SMOOTH=$1
FNIRT=$2
SETORIGIN=1

GO=1

#qsub -v EXPERIMENT=HighRes.01 L3_highres.sh $CNUM $CNAME $SMOOTH $F $SO


MAINDIR=${EXPERIMENT}/Analysis
NSUBJECTS=20

for LIST in "1 Face-Land" "2 Land-Face" "3 Rate" "4 Face_L" "5 Face_Q" "6 Land_L" "7 Land_Q" "8 Face_L-Land_L" "9 Land_L-Face_L" "10 Face_Q-Land_Q" "11 Land_Q-Face_Q"; do
	set -- $LIST
	CNUM=$1
	CNAME=$2

	
	N=0
	for SUBJ in 1002 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023; do
		if [ $SETORIGIN -eq 1 ]; then
			if [ $FNIRT -eq 1 ]; then
				L2OUTPUT=${MAINDIR}/FSL/${SUBJ}/Model03_FNIRT/Smooth_${SMOOTH}mm
				MAINOUTPUT=${MAINDIR}/FSL/Level3_n${NSUBJECTS}/Model03_FNIRT/Smooth_${SMOOTH}mm
			else
				L2OUTPUT=${MAINDIR}/FSL/${SUBJ}/Model03_FLIRT/Smooth_${SMOOTH}mm
				MAINOUTPUT=${MAINDIR}/FSL/Level3_n${NSUBJECTS}/Model03_FLIRT/Smooth_${SMOOTH}mm
			fi
		else
			if [ $FNIRT -eq 1 ]; then
				L2OUTPUT=${MAINDIR}/FSL/${SUBJ}/Model03_FNIRT_noSO/Smooth_${SMOOTH}mm
				MAINOUTPUT=${MAINDIR}/FSL/Level3_n${NSUBJECTS}/Model03_FNIRT_noSO/Smooth_${SMOOTH}mm
			else
				L2OUTPUT=${MAINDIR}/FSL/${SUBJ}/Model03_FLIRT_noSO/Smooth_${SMOOTH}mm
				MAINOUTPUT=${MAINDIR}/FSL/Level3_n${NSUBJECTS}/Model03_FLIRT_noSO/Smooth_${SMOOTH}mm
			fi
		fi
		let N=$N+1
		if [ $SUBJ -eq 1009 ] || [ $SUBJ -eq 1023 ]; then
			FILENAME=${L2OUTPUT}/run1.feat/stats/cope${CNUM}.nii.gz
			rm -rf ${L2OUTPUT}/run1.feat/reg_standard
		else
			FILENAME=${L2OUTPUT}/Level2.gfeat/cope${CNUM}.feat/stats/cope1.nii.gz
		fi
		NN=`printf '%02d' $N` #this pads the numbers with zero
		eval INPUT${NN}=${FILENAME}
		if [ ! -e ${FILENAME} ]; then
			echo "DOES NOT EXIST: ${FILENAME}"
		fi
	done
	
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/L3_C${CNUM}_${CNAME}
	if [ $GO -eq 1 ]; then
		rm -rf ${OUTPUT}.gfeat
	fi
	
	TEMPLATE=${MAINDIR}/FSL/templates/L3_template_n20.fsf
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
	<$TEMPLATE> ${MAINOUTPUT}/level3_c${CNUM}.fsf
	
	if [ -d ${OUTPUT}.feat ]; then
		echo "this one is already done"
	else
		$FSLDIR/bin/feat ${MAINOUTPUT}/level3_c${CNUM}.fsf
	fi
	
	rm -rf ${OUTPUT}.gfeat/stats/res4d.nii.gz
	# rm -rf ${OUTPUT}.gfeat/filtered_func_data.nii.gz

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
