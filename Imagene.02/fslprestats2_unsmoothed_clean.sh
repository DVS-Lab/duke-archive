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
RUN=SUB_RUN_SUB
TASK=SUB_TASK_SUB


# -- two inputs
S=$SUBJ #subject number
R=$RUN #run number

# -- helpful to have all data under this main directory
MAINDIR=${EXPERIMENT}/Analysis/TaskData
SCRIPTDIR=$MAINDIR/__forHugin

#cd $SCRIPTDIR
#matlab -nodesktop -nodisplay -nosplash -r "fix_output('$SUBJ','$TASK','$RUN',0)"


# -- get motion estimates and outlier volumes --
# updated: now using refrms and fdrms because DVARS does not identify the largest motion spikes
MYOUTDIR=${MAINDIR}/${S}/${TASK}
MYINDIR=${MAINDIR}/${S}/${TASK}/run${R}_SUSANprep
#rm -rf ${MYINDIR}/run${R}.nii

if [ ! -e ${MYINDIR}/swacrun${R}.nii ]; then
	echo "missing file: ${MYINDIR}/swacrun${R}.nii" >> $MAINDIR/__missingfiles_s.txt	
else
	mcflirt -in ${MYINDIR}/crun${R}.nii -out ${MYINDIR}/crun${R}_mcf -refvol 0 -rmsrel -rmsabs
	sh ${SCRIPTDIR}/fsl_motion_outliers_0ref.sh -i ${MYINDIR}/crun${R}.nii -o ${MYOUTDIR}/refrms_spikes_run${R}.txt --nomoco --refrms
	sh ${SCRIPTDIR}/fsl_motion_outliers_0ref.sh -i ${MYINDIR}/crun${R}.nii -o ${MYOUTDIR}/fdrms_spikes_run${R}.txt --fdrms
	python ${SCRIPTDIR}/combine_spikes2.py ${MYOUTDIR}/fdrms_spikes_run${R}.txt ${MYOUTDIR}/refrms_spikes_run${R}.txt ${MYOUTDIR}/all_spikes_run${R}.txt
	rm -rf ${MYINDIR}/crun${R}_mcf.nii.gz
	rm -rf ${MYINDIR}/crun${R}_mcf.mat


	# -- set output and remove existing --
	OUTPUT=${MYOUTDIR}/prestats${R}_4mmSUSAN_clean
	rm -rf ${OUTPUT}.feat
	sleep 5s
	rm -rf ${OUTPUT}.feat
	sleep 5s

	# -- regress out volumes identified as outliers/spikes and all motion --
	# Power et al. (2014, in press). Recent progress and outstanding issues in motion correction in resting state fMRI. NeuroImage. http://www.sciencedirect.com/science/article/pii/S1053811914008702
	# JISCMail - FSL Archive - dual regression and motion regressors (https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;459c6c04.1212)
	# JISCMail - FSL Archive - Re: fsl_motion_outliers question. (https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;9f686c8e.1405)
	INDATA=${MYOUTDIR}/run${R}_SUSANprep/swacrun${R}.nii # data from SPM (has not been temporally filtered!)
	if [ ! -e $INDATA ]; then
		echo "missing $INDATA" >> $MAINDIR/__missingfiles_s.txt
	fi
	NVOLUMES=`fslnvols ${INDATA}`
	
	CONFOUNDEVSFILE=${MYOUTDIR}/all_confounds_run${R}.txt
	mp_diffpow.sh ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}.txt ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}_diff.dat
	if [ -e ${MYOUTDIR}/all_spikes_run${R}.txt ]; then
		paste -d ' ' ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}.txt ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}_diff.dat > ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}_final.txt
		paste -d ' ' ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}_final.txt ${MYOUTDIR}/all_spikes_run${R}.txt > ${CONFOUNDEVSFILE}
	else
		paste -d ' ' ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}.txt ${MYOUTDIR}/run${R}_SUSANprep/rp_crun${R}_diff.dat > ${CONFOUNDEVSFILE}
	fi	
	
	if [ -e $CONFOUNDEVSFILE ]; then
		OUTDATA=${MYOUTDIR}/run${R}_SUSANprep/swacrun${R}_scrubbed
		preMAT=${CONFOUNDEVSFILE}
		postMAT=${MYOUTDIR}/run${R}_SUSANprep/for_unconfound${R}.mat
		cd ${SCRIPTDIR}
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@INDATA@'$INDATA'@g' \
		-e 's@UNCONFOUNDFILE@'$preMAT'@g' \
		-e 's@NVOLUMES@'$NVOLUMES'@g' \
		<make_confoundmat.fsf> ${MYOUTDIR}/run${R}_SUSANprep/for_unconfound${R}.fsf
		feat_model ${MYOUTDIR}/run${R}_SUSANprep/for_unconfound${R} ${preMAT}
		unconfound ${INDATA} ${OUTDATA} ${postMAT}
	else
		echo "failed: $CONFOUNDEVSFILE" >> $MAINDIR/__failedconfounds_s.txt
		exit
	fi


	# -- run remaining preprocessing steps and ica --
	DATA=${MYOUTDIR}/run${R}_SUSANprep/swacrun${R}_scrubbed.nii.gz
	TEMPLATE=${SCRIPTDIR}/hp_bet_melodic_smooth.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	<$TEMPLATE> ${MYOUTDIR}/prestats${R}_4mm_clean.fsf
	feat ${MYOUTDIR}/prestats${R}_4mm_clean.fsf



	#-- clean up extra files --
	rm -rf $DATA
	GENDATA=${OUTPUT}.feat/filtered_func_data.nii.gz
	if [ -e $GENDATA ]; then
		rm -rf ${MYINDIR}/crun${R}.nii
		rm -rf ${MYINDIR}/run${R}.nii
		rm -rf ${MYINDIR}/c*_anat.nii
		rm -rf ${MYINDIR}/iy_*anat.nii
		rm -rf ${MYINDIR}/y_*anat.nii
		rm -rf ${MYINDIR}/rc*_anat.nii
	else
		echo "failed: $GENDATA" >> $MAINDIR/__faileddata_s.txt
	fi

fi

OUTDIR=${MAINDIR}/Logs/fslprestats2_fix
mkdir -p $OUTDIR


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
#OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
