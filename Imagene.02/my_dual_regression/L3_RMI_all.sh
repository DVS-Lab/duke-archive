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

SUBJ=SUB_SUBNUM_SUB
SMOOTH=SUB_SMOOTH_SUB
GO=SUB_GO_SUB

MAINDIR=${EXPERIMENT}/Analysis
NSUBJECTS=49
MAINOUTPUT=${MAINDIR}/FSL/Level3_n${NSUBJECTS}

for LIST in "10 face-land" "11 land-face"; do
       set -- $LIST
       CNUM=$1
       CNAME=$2

       N=0
       for SUBJ in 13282 13298 13323 13329 13346 13374 13383 13392 13431 13474 13483 13527 13534 13540 13551 13559 13637 13647 13654 13696 13849 13863 13875 13886 13928 13944 13952 14064 14265 14447 14470 14478 14507 14518 14588 14694 14715 14779 14841 14934 14955 15014 15092 15102 15115 15491 15596 15606 15690; do
			SUBJDIR=${MAINDIR}/FSL/${SUBJ}/anticipation_model_FNIRT/Smooth_${SMOOTH}mm
				if [ $SUBJ -eq 13346 ]; then
					FILENAME=${SUBJDIR}/run1.feat/stats/cope${CNUM}.nii.gz
				elif [ $SUBJ -eq 15606 ]; then
					FILENAME=${SUBJDIR}/run2.feat/stats/cope${CNUM}.nii.gz
				else
					FILENAME=${SUBJDIR}/Level2.gfeat/cope${CNUM}.feat/stats/cope1.nii.gz
				fi
				MAINOUTPUT2=${MAINOUTPUT}/anticipation_model_face-land_FNIRT/Smooth_${SMOOTH}mm
               let N=$N+1
               NN=`printf '%02d' $N` #this pads the numbers with zero
               eval INPUT${NN}=${FILENAME}
               if [ ! -e ${FILENAME} ]; then
                       echo "DOES NOT EXIST: ${FILENAME}"
               fi
       done

       mkdir -p $MAINOUTPUT2
       OUTPUT=${MAINOUTPUT2}/L3_mixed_C${CNUM}_${CNAME}
       if [ $GO -eq 1 ]; then
               rm -rf ${OUTPUT}.gfeat
       fi

       TEMPLATE=${MAINDIR}/FSL/templates/L3_relative_motivation_model_face-land_mixed.fsf
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
       -e 's@INPUT40@'$INPUT40'@g' \
       -e 's@INPUT41@'$INPUT41'@g' \
       -e 's@INPUT42@'$INPUT42'@g' \
       -e 's@INPUT43@'$INPUT43'@g' \
       -e 's@INPUT44@'$INPUT44'@g' \
       -e 's@INPUT45@'$INPUT45'@g' \
       -e 's@INPUT46@'$INPUT46'@g' \
       -e 's@INPUT47@'$INPUT47'@g' \
       -e 's@INPUT48@'$INPUT48'@g' \
       -e 's@INPUT49@'$INPUT49'@g' \
       <$TEMPLATE> ${MAINOUTPUT2}/level3_c${CNUM}.fsf

       if [ -d ${OUTPUT}.feat ]; then
               echo "this one is already done"
       else
               $FSLDIR/bin/feat ${MAINOUTPUT2}/level3_c${CNUM}.fsf
       fi

       rm -rf ${OUTPUT}.gfeat/stats/res4d.nii.gz
       # rm -rf ${OUTPUT}.gfeat/filtered_func_data.nii.gz

done

#cd ${OUTPUT}.gfeat/cope1.feat
#randomise -i filtered_func_data.nii.gz -o randomise_out -d design.mat -t design.con -m mask.nii.gz -n 10000 -T

#delete unnecessary files
NCOPES=1
for C in `seq $NCOPES`; do
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/stats/res4d.nii.gz
#	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/filtered_func_data.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${C}.feat/var_filtered_func_data.nii.gz
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
