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
FIXED=SUB_FIXED
DENOISED=SUB_DENOISED
ISO=SUB_ISO

if [ $DENOISED -eq 1 -a $ISO -eq 0 ]; then
	ICA=denoised
	ICAFILTER=GLM3_denoised
	TASK2=Combo_Level2_denoised
elif [ $DENOISED -eq 0 -a $ISO -eq 0 ]; then
	ICA=normal
	ICAFILTER=GLM3
	TASK2=Combo_Level2
elif [ $DENOISED -eq 1 -a $ISO -eq 1 ]; then
	ICA=denoised_4x4x4mm
	ICAFILTER=GLM3_denoised_4x4x4mm
	TASK2=Combo_Level2_denoised_4x4x4mm
elif [ $DENOISED -eq 0 -a $ISO -eq 1 ]; then
	ICA=normal_4x4x4mm
	ICAFILTER=GLM3_4x4x4mm
	TASK2=Combo_Level2_4x4x4mm
fi


if [ "$TEMPLATE" == "L3_paired_T-test" ] && [ ! "$TASK" == "Passive" ]; then
	echo "Skipping paired tests..."
	echo $TEMPLATE
	echo $TASK
	OUTDIR=${EXPERIMENT}/Analysis/FSL/badlogs3
	mkdir -p $OUTDIR
elif [ "$TEMPLATE" = "L3_cross_study" -o "$TEMPLATE" == "L3_cross_studyF" ] &&  [ ! "$TASK" == "Combo_Level2" ]; then
	if [ "$MODEL" == "Model_3" ] || [ "$MODEL" == "Model_1" ]; then
		echo "Skipping cross study tests... for models 1 and 3"
		echo $TEMPLATE
		echo $MODEL
		echo $TASK
		OUTDIR=${EXPERIMENT}/Analysis/FSL/badlogsCrossStudy_skips3
		mkdir -p $OUTDIR
	fi
else

	MAINDIR=${EXPERIMENT}/Analysis/FSL
	if [ $FIXED -eq 1 ]; then
		L3_TEMP=level3_fixed
		if [ $CORRECTION -eq 1 ]; then
			MAINOUTPUTPRE=${MAINDIR}/ThirdLevel5_${ICA}/FEcorrected
			PTHRESH=0.05
			THRESHTYPE=3
		else
			MAINOUTPUTPRE=${MAINDIR}/ThirdLevel5_${ICA}/FEuncorrected
			PTHRESH=0.001
			THRESHTYPE=1
		fi
	else
		L3_TEMP=level3
		if [ $CORRECTION -eq 1 ]; then
			MAINOUTPUTPRE=${MAINDIR}/ThirdLevel5_${ICA}/corrected
			PTHRESH=0.05
			THRESHTYPE=3
		else
			MAINOUTPUTPRE=${MAINDIR}/ThirdLevel5_${ICA}/uncorrected
			PTHRESH=0.001
			THRESHTYPE=1
		fi
	fi

	if [ "$TEMPLATE" == "L3_paired_T-test" ] || [ "$TEMPLATE" == "L3_cross_study" ]; then
		MAINOUTPUT=${MAINOUTPUTPRE}/${TEMPLATE}/${MODEL}
	else
		MAINOUTPUT=${MAINOUTPUTPRE}/${TEMPLATE}/${TASK}/${MODEL}
	fi
	if [ "$TEMPLATE" == "L3_cross_study" -o "$TEMPLATE" == "L3_cross_studyF" ]; then
		if [ "$MODEL" == "Model_3" ] || [ "$MODEL" == "Model_1" ]; then
			exit
		fi
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
	if [ "$MODEL" == "Model_3" ]; then
		if [ "$TASK" == "Passive" ] || [ "$TASK" == "PassiveCued" ]; then
			NAME=( F_linear M_Linear )
			NUM=( 2 4 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		fi
	fi
	if [ "$MODEL" == "Model_1" ]; then
		if [ "$TASK" == "PassiveCued" ]; then
			NAME=( Fcue-Mcue Mcue-Fcue F-M M-F 4star-1star 1star-4star hot-not not-hot gain5-loss5 loss5-gain5 gain-loss loss-gain pos-neg neg-pos M_salience+ M_salience- F_salience+ F_salience- )
			NUM=( 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		else
			NAME=( F-M M-F 4star-1star 1star-4star hot-not not-hot gain5-loss5 loss5-gain5 gain-loss loss-gain pos-neg neg-pos M_salience+ M_salience- F_salience+ F_salience- )
			NUM=( 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 )
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
			NAME=( cue high-low low-high pos-neg neg-pos salience+ salience- )
			NUM=( 5 6 7 8 9 10 11 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		else
			NAME=( high-low low-high pos-neg neg-pos salience+ salience- )
			NUM=( 6 7 8 9 10 11 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		fi
		if [ "$TEMPLATE" == "L3_cross_study" -o "$TEMPLATE" == "L3_cross_studyF" ]; then
			NAME=( high-low low-high pos-neg neg-pos )
			NUM=( 6 7 8 9 )
			LENGTH=${#NAME[@]}
			let LENGTH=$LENGTH-1
		fi
	fi

	for x in `seq 0 $LENGTH`; do
		COPENAME=${NAME[$x]}
		COPENUM=${NUM[$x]}

		cd ${EXPERIMENT}/Analysis/FSL/Templates/${L3_TEMP}
		OUTPUT=${MAINOUTPUT}/$COPENAME
		REALOUTPUT=${OUTPUT}.gfeat
		if [ -d ${REALOUTPUT} ]; then
			FILECHECK=${REALOUTPUT}/cope1.feat/thresh_zstat1.nii.gz
			if [ -e $FILECHECK ]; then
				echo "file exists... skipping to the next one"
				continue
				OUTDIR=$MAINOUTPUT/logs
				mkdir -p $OUTDIR
			else
				OUTDIR=${EXPERIMENT}/Analysis/FSL/logs_restarts_go${GO}_correction${CORRECTION}_${MODEL}_${TASK}
				mkdir -p $OUTDIR
				rm -rf $REALOUTPUT
				sleep 200s
			fi
		fi

		N=0
		if [ "$TEMPLATE" == "L3_paired_T-test" ]; then
			for TASK in "Passive" "PassiveCued"; do
				for SUBJ in 34712 34742 34756 34783 34793 34915 34950 34952 34967 34970 35009 35025 35086 35267 35280 35283; do
					let N=$N+1
					if [ "$TASK" == "Combo_Level2" ] && [ ! "$MODEL" == "Model_3" ]; then
						MIDDIR=${TASK2}/${MODEL}
						POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
					elif [ "$TASK" == "Combo_Level2" ] && [ "$MODEL" == "Model_3" ]; then
						MIDDIR=${TASK2}/${MODEL}
						POSTDIR=${COPENAME}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
					else
						MIDDIR=${TASK}/${ICAFILTER}/${MODEL}
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
			OUTDIR=$MAINOUTPUT/logs

		fi

		if [ "$TEMPLATE" == "L3_cross_study" -o "$TEMPLATE" == "L3_cross_studyF" ] && [ "$TASK" == "Combo_Level2" ]; then

			for SUBJ in 34712 34742 34756 34783 34793 34915 34950 34952 34967 34970 35009 35025 35086 35267 35280 35283 32918 32953 32958 32976 32984 33035 33045 33064 33082 33288 33302 33402 33456 33642 33732 33746 33754 33757 33771 33784 33744 33467 33135; do
				let N=$N+1
				MIDDIR=${TASK2}/${MODEL}
				POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
				if [ $N -gt 9 ]; then
					eval INPUT${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/${POSTDIR}
				else
					eval INPUT0${N}=${MAINDIR}/${SUBJ}/${MIDDIR}/${POSTDIR}
				fi

				if [ $N -gt 16 ]; then
					if [ "$MODEL" == "Model_2_Face" ]; then
						SR01_MODEL=Model9_faces_6mm_ST
						GFEAT=${SUBJ}_2ndlevel_faces.gfeat
					elif [ "$MODEL" == "Model_2_Money" ]; then
						SR01_MODEL=Model9_money_6mm_ST
						GFEAT=${SUBJ}_2ndlevel_money.gfeat
						if [ $COPENUM -eq 6 ]; then
							COPENUM=12
						elif [ $COPENUM -eq 7 ]; then
							COPENUM=13
						fi
					elif [ "$MODEL" == "Model_4_Face" ]; then
						SR01_MODEL=LinearIncrease_Face_6mm_ST
						GFEAT=${SUBJ}_level2.gfeat
						if [ $COPENUM -eq 1 ]; then
							COPENUM=2
						elif [ $COPENUM -eq 2 ]; then
							COPENUM=1
						fi
					elif [ "$MODEL" == "Model_4_Money" ]; then
						SR01_MODEL=LinearIncrease_Money_6mm_ST
						GFEAT=${SUBJ}_level2.gfeat
						if [ $COPENUM -eq 1 ]; then
							COPENUM=2
						elif [ $COPENUM -eq 2 ]; then
							COPENUM=1
						fi
					fi
		
					DATADIR=${MAINDIR}/SR01/${SUBJ}
					eval INPUT${N}=${DATADIR}/${SUBJ}_${SR01_MODEL}/${GFEAT}/cope${COPENUM}.feat/stats/cope1.nii.gz

					if [ $COPENUM -eq 1 ]; then
						COPENUM=2
					elif [ $COPENUM -eq 2 ]; then
						COPENUM=1
					fi
				fi
			done
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
			-e 's@PTHRESH@'$PTHRESH'@g' \
			-e 's@THRESHTYPE@'$THRESHTYPE'@g' \
			<${TEMPLATE}.fsf> ${MAINOUTPUT}/L3_${COPENAME}.fsf
	
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
			OUTDIR=$MAINOUTPUT/logs

		else

			if [ "$TEMPLATE" == "L3_cross_study" -o "$TEMPLATE" == "L3_cross_studyF" ]; then
				echo "skipping L3_cross_study. shouldn't be doing this anyway..."
				OUTDIR=$MAINOUTPUT/logs
				mkdir -p $OUTDIR
				continue
			fi
			for SUBJ in 34712 34742 34756 34783 34793 34915 34950 34952 34967 34970 35009 35025 35086 35267 35280 35283; do
				if [ "$TASK" == "Combo_Level2" ] && [ ! "$MODEL" == "Model_3" ]; then
					MIDDIR=${TASK2}/${MODEL}
					POSTDIR=${SUBJ}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
				elif [ "$TASK" == "Combo_Level2" ] && [ "$MODEL" == "Model_3" ]; then
					MIDDIR=${TASK2}/${MODEL}
					POSTDIR=${COPENAME}_level2.gfeat/cope${COPENUM}.feat/stats/cope1.nii.gz
				else
					MIDDIR=${TASK}/${ICAFILTER}/${MODEL}
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
			OUTDIR=$MAINOUTPUT/logs

		fi
	done
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
