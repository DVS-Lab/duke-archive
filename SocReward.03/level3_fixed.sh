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


MODEL=SUB_MODEL
TASK=SUB_TASK
TEMPLATE=SUB_TEMPLATE
GO=SUB_GO
CORRECTION=SUB_CORRECTION

if [ "$TEMPLATE" == "L3_paired_T-test" ] && [ ! "$TASK" == "Passive" ]; then
	echo "Skipping paired tests..."
	echo $TEMPLATE
	echo $TASK
	OUTDIR=${EXPERIMENT}/Analysis/FSL/badlogs2
	mkdir -p $OUTDIR
else
	
	MAINDIR=${EXPERIMENT}/Analysis/FSL
	if [ $CORRECTION -eq 1 ]; then
		MAINOUTPUTPRE=${MAINDIR}/ThirdLevel2/FEcorrected
		PTHRESH=0.05
		THRESHTYPE=3
	else
		MAINOUTPUTPRE=${MAINDIR}/ThirdLevel2/FEuncorrected
		PTHRESH=0.001
		THRESHTYPE=1
	fi
	if [ "$TEMPLATE" == "L3_paired_T-test" ]; then
		MAINOUTPUT=${MAINOUTPUTPRE}/${TEMPLATE}/${MODEL}
	else
		MAINOUTPUT=${MAINOUTPUTPRE}/${TEMPLATE}/${TASK}/${MODEL}
	fi
	mkdir -p ${MAINOUTPUT}
	
	declare -a NAME
	declare -a NUM
	if [ "$MODEL" == "Model_3" ] && [ "$TASK" == "Combo_Level2" ]; then
		NAME=( F_linear M_Linear )
		NUM=( 1 1 )
		LENGTH=${#NAME[@]}
		let LENGTH=$LENGTH-1
	fi
	if [ "$MODEL" == "Model_3" ] && [ "$TASK" == "Passive" ] || [ "$TASK" == "PassiveCued" ]; then
		NAME=( F_linear M_Linear )
		NUM=( 2 4 )
		LENGTH=${#NAME[@]}
		let LENGTH=$LENGTH-1
	fi
	if [ "$MODEL" == "Model_1" ]; then
		if [ "$TASK" == "PassiveCued" ]; then
			NAME=( Fcue-Mcue Mcue-Fcue F-M M-F 4star-1star 1star-4star hot-not not-hot gain5-loss5 loss5-gain5 gain-loss loss-gain pos-neg neg-pos )
			NUM=( 11 12 13 14 15 16 17 18 19 20 21 22 23 24 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		else
			NAME=( F-M M-F 4star-1star 1star-4star hot-not not-hot gain5-loss5 loss5-gain5 gain-loss loss-gain pos-neg neg-pos )
			NUM=( 13 14 15 16 17 18 19 20 21 22 23 24 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		fi
	fi
	if [ "$MODEL" == "Model_4_Face" ] || [ "$MODEL" == "Model_4_Money" ]; then
		NAME=( constant linear )
		NUM=( 1 2 )
		LENGTH=${#NAME[@]}
		let LENGTH=$LENGTH-1
	fi
	if [ "$MODEL" == "Model_2_Face" ] || [ "$MODEL" == "Model_2_Money" ]; then
		if [ "$TASK" == "PassiveCued" ]; then
			NAME=( cue high-low low-high pos-neg neg-pos )
			NUM=( 5 6 7 8 9 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		else
			NAME=( high-low low-high pos-neg neg-pos )
			NUM=( 6 7 8 9 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		fi
	fi
	
	for x in `seq 0 $LENGTH`; do
		COPENAME=${NAME[$x]}
		COPENUM=${NUM[$x]}
		
		OUTPUT=${MAINOUTPUT}/$COPENAME
		REALOUTPUT=${OUTPUT}.gfeat
		if [ ${GO} -eq 1 ]; then
			rm -rf $REALOUTPUT
		fi
	
		N=0
		if [ "$TEMPLATE" == "L3_paired_T-test" ]; then
			for TASK in "Passive" "PassiveCued"; do
				for SUBJ in 34712 34742 34756 34783 34793 34915 34950 34952 34967 34970 35009 35025 35086 35267 35280 35283; do
					let N=$N+1
					if [ "$TASK" == "Combo_Level2" ] && [ ! "$MODEL" == "Model_3" ]; then
						MIDDIR=${TASK}/${MODEL}
						POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
					elif [ "$TASK" == "Combo_Level2" ] && [ "$MODEL" == "Model_3" ]; then
						MIDDIR=${TASK}/${MODEL}
						POSTDIR=${COPENAME}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
					else
						MIDDIR=${TASK}/GLM2/${MODEL}
						POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
					fi
					if [ $SUBJ -eq 35086 ] && [ "$TASK" == "PassiveCued" ]; then
						if [ $N -gt 9 ]; then
							eval INPUT${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/run1.feat/stats/cope${COPENUM}.nii.gz
						else
							eval INPUT0${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/run1.feat/stats/cope${COPENUM}.nii.gz
						fi
					else
						if [ $N -gt 9 ]; then
							eval INPUT${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/${POSTDIR}
						else
							eval INPUT0${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/${POSTDIR}
						fi
					fi
				done
			done
		else
			for SUBJ in 34712 34742 34756 34783 34793 34915 34950 34952 34967 34970 35009 35025 35086 35267 35280 35283; do
				if [ "$TASK" == "Combo_Level2" ] && [ ! "$MODEL" == "Model_3" ]; then
					MIDDIR=${TASK}/${MODEL}
					POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
				elif [ "$TASK" == "Combo_Level2" ] && [ "$MODEL" == "Model_3" ]; then
					MIDDIR=${TASK}/${MODEL}
					POSTDIR=${COPENAME}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
				else
					MIDDIR=${TASK}/GLM2/${MODEL}
					POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
				fi
				let N=$N+1
				if [ $SUBJ -eq 35086 ] && [ "$TASK" == "PassiveCued" ]; then
					if [ $N -gt 9 ]; then
						eval INPUT${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/run1.feat/stats/cope${COPENUM}.nii.gz
					else
						eval INPUT0${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/run1.feat/stats/cope${COPENUM}.nii.gz
					fi
				else
					if [ $N -gt 9 ]; then
						eval INPUT${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/${POSTDIR}
					else
						eval INPUT0${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/${POSTDIR}
					fi
				fi
			done
		fi
	
		cd ${EXPERIMENT}/Analysis/FSL/Templates/level3_fixed
		if [ ! "$TEMPLATE" == "L3_paired_T-test" ]; then
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
			-e 's@PTHRESH@'$PTHRESH'@g' \
			-e 's@THRESHTYPE@'$THRESHTYPE'@g' \
			<${TEMPLATE}.fsf> ${MAINOUTPUT}/L3_${COPENAME}.fsf
		else
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
			-e 's@PTHRESH@'$PTHRESH'@g' \
			-e 's@THRESHTYPE@'$THRESHTYPE'@g' \
			<${TEMPLATE}.fsf> ${MAINOUTPUT}/L3_${COPENAME}.fsf
		fi
		
		if [ -d ${REALOUTPUT} ]; then
			echo "This one is already done... skipping to the next one..."
		else
			feat ${MAINOUTPUT}/L3_${COPENAME}.fsf
			cd $REALOUTPUT
			cd cope1.feat
			rm -f filtered_func_data.nii.gz
			rm -f var_filtered_func_data.nii.gz
			rm -r stats/res4d.nii.gz
		fi
	done
	OUTDIR=$MAINOUTPUT/logs
	mkdir -p $OUTDIR
fi



# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
