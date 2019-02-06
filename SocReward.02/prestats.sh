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
SMOOTH=SUB_SMOOTH_SUB
GO=SUB_GO_SUB

SKIP=0

MAINDIR=${EXPERIMENT}/Analysis/FSL
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/MELODIC_FLIRT/Smooth_${SMOOTH}mm
MAINOUTPUT2=${SUBJDIR}/MELODIC_FNIRT/Smooth_${SMOOTH}mm

if [ $SKIP -eq 1 ]; then
	echo "not making dirs for exceptions..."
else
	mkdir -p ${MAINOUTPUT}
	mkdir -p ${MAINOUTPUT2}

fi

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica
FILE_TO_CHECK=${OUTPUTREAL}/filtered_func_data.nii.gz
if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUTREAL}
fi
if [ ! -e $FILE_TO_CHECK ]; then
	rm -rf ${OUTPUTREAL}
fi

ANAT=${SUBJDIR}/${SUBJ}_anat_brain
ANATH=${SUBJDIR}/${SUBJ}_anat
DATA=${SUBJDIR}/run${RUN}
OUTPUT=${MAINOUTPUT}/run${RUN}
SO_FILE=${SUBJDIR}/so_run${RUN}.txt

if [ $SUBJ -eq 13282 -a $RUN -eq 1 ]; then
	NVOLUMES=484
elif [ $SUBJ -eq 13282 -a $RUN -eq 2 ]; then
	NVOLUMES=488
elif [ $RUN -eq 5 ]; then
	NVOLUMES=242
else
	NVOLUMES=492
fi
NDISDAQS=8

STANDARD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz

if [ $SKIP -eq 1 ]; then
	echo "skipping exceptions..."
	OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_SKIP/GO_${GO}
else
	TEMPLATEDIR=${MAINDIR}/Templates
	cd ${TEMPLATEDIR}
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@SMOOTH@'$SMOOTH'@g' \
	-e 's@ANAT@'$ANAT'@g' \
	-e 's@DATA@'$DATA'@g' \
	-e 's@NVOLUMES@'$NVOLUMES'@g' \
	-e 's@NDISDAQS@'$NDISDAQS'@g' \
	-e 's@SO_FILE@'$SO_FILE'@g' \
	-e 's@STANDARD@'$STANDARD'@g' \
	<melodic_SR02.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	
	
	
	cd ${MAINOUTPUT}
	if [ -d "$OUTPUTREAL" ]; then
		echo "That one is already done!"
	else
		$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
	fi


	OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica
	cd ${MAINOUTPUT}
	if [ -d "$OUTPUTREAL" ]; then
		cd $OUTPUTREAL
		$FSLDIR/bin/fslmeants -i filtered_func_data.nii.gz -o wb_raw.txt -m mask.nii.gz
		rm -rf stats
	else
		echo "wtf... this file should be there"
	fi
	
	cp $OUTPUTREAL/mc/prefiltered_func_data_mcf.par $OUTPUTREAL/MOTIONconfoundevs.txt
	
	
	echo "LOOKING FOR BAD TIME POINTS ----------- HERE -----------"
	if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
		echo "Exists: ${OUTPUTREAL}/bad_timepoints.txt"
		OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_SUCCESS/GO_${GO}
	else
		fsl_motion_outliers ${DATA} ${NDISDAQS} ${OUTPUTREAL}/bad_timepoints.txt
		if [ -e ${OUTPUTREAL}/bad_timepoints.txt ]; then
			OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_SUCCESS/GO_${GO}
		else
			OUTDIR=${MAINDIR}/Logs/prestats+reg/fsl_motion_outlier_FAIL/GO_${GO}
		fi
	fi



	DATA=${SUBJDIR}/MELODIC_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.ica/filtered_func_data.nii.gz
	EF=${OUTPUTREAL}/example_func
	MF=${OUTPUTREAL}/mean_func
	STANDARD=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz
	STANDARDMASK=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz
	STANDARDHEAD=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz
	
	#do FLIRT first
	if [ $GO -eq 1 ]; then
		rm -rf ${OUTPUT}.ica/reg
	fi
	CHECKREG=${OUTPUT}.ica/reg/example_func2standard.png
	if [ -e $CHECKREG ]; then
		echo "registration is complete..."
	else
		if [ $GO -gt 1 ]; then
			echo "registration fail... trying again..."
		fi
		REGDIR=${OUTPUT}.ica/reg
		rm -rf $REGDIR
		mkdir -p $REGDIR
		cd $REGDIR
		
		#prep images
		$FSLDIR/bin/fslmaths $ANAT highres
		$FSLDIR/bin/fslmaths $STANDARD standard
		$FSLDIR/bin/bet $MF mean_func_brain -f .45 -m
		$FSLDIR/bin/fslmaths $EF -mas mean_func_brain_mask example_func
		
		
		#make highres2example_func.mat AND example_func2initial_highres.mat
		$FSLDIR/bin/flirt -ref highres -in example_func -out example_func2highres -omat example_func2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
		$FSLDIR/bin/slicer example_func2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres1.png ; $FSLDIR/bin/slicer highres example_func2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres2.png ; $FSLDIR/bin/pngappend example_func2highres1.png - example_func2highres2.png example_func2highres.png; /bin/rm -f sl?.png
		
		
		#registering highres2standard
		#make highres2standard.mat and standard2highres.mat
		$FSLDIR/bin/flirt -ref standard -in highres -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
		$FSLDIR/bin/slicer highres2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard1.png ; $FSLDIR/bin/slicer standard highres2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard2.png ; $FSLDIR/bin/pngappend highres2standard1.png - highres2standard2.png highres2standard.png; /bin/rm -f sl?.png
		
		
		#make standard2example_func.mat and example_func2standard.mat
		$FSLDIR/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
		$FSLDIR/bin/flirt -ref standard -in example_func -out example_func2standard -applyxfm -init example_func2standard.mat -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
		$FSLDIR/bin/slicer example_func2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard1.png ; $FSLDIR/bin/slicer standard example_func2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard2.png ; $FSLDIR/bin/pngappend example_func2standard1.png - example_func2standard2.png example_func2standard.png; /bin/rm -f sl?.png
	fi


	#now do FNIRT, but preserve directory structure
	#OUTPUT=${MAINOUTPUT}/run${RUN}

	cp -r ${OUTPUT}.ica ${MAINOUTPUT2}/run${RUN}.ica
	OUTPUT=${MAINOUTPUT2}/run${RUN}
	if [ $GO -eq 1 ]; then
		rm -rf ${OUTPUT}.ica/reg
		rm -rf ${OUTPUT}.ica/filtered_func_data.nii.gz
	fi
	CHECKREG=${OUTPUT}.ica/reg/example_func2standard.png
	if [ -e $CHECKREG ]; then
		echo "registration is complete..."
	else
		if [ $GO -gt 1 ]; then
			echo "registration fail... trying again..."
		fi
		REGDIR=${OUTPUT}.ica/reg
		rm -rf $REGDIR
		mkdir -p $REGDIR
		cd $REGDIR
		
		#prep images
		$FSLDIR/bin/fslmaths $ANAT highres
		$FSLDIR/bin/fslmaths $STANDARD standard
		$FSLDIR/bin/fslmaths $STANDARDHEAD standard_head
		$FSLDIR/bin/fslmaths $STANDARDMASK standard_mask
		$FSLDIR/bin/fslmaths $ANATH highres_head
		$FSLDIR/bin/bet $MF mean_func_brain -f .45 -m
		$FSLDIR/bin/fslmaths $EF -mas mean_func_brain_mask example_func

		
		#make highres2example_func.mat AND example_func2initial_highres.mat
		$FSLDIR/bin/flirt -ref highres -in example_func -out example_func2highres -omat example_func2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
		$FSLDIR/bin/slicer example_func2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres1.png ; $FSLDIR/bin/slicer highres example_func2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres2.png ; $FSLDIR/bin/pngappend example_func2highres1.png - example_func2highres2.png example_func2highres.png; /bin/rm -f sl?.png
		
		
		#registering highres2standard
		#make highres2standard.mat and standard2highres.mat
		#then run fnirt to get warps
		$FSLDIR/bin/flirt -ref standard -in highres -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/fnirt --in=highres_head --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2standard_jac --config=T1_2_MNI152_2mm --ref=standard_head --refmask=standard_mask --warpres=10,10,10
		$FSLDIR/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
		$FSLDIR/bin/slicer highres2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard1.png ; $FSLDIR/bin/slicer standard highres2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard2.png ; $FSLDIR/bin/pngappend highres2standard1.png - highres2standard2.png highres2standard.png; /bin/rm -f sl?.png
		
		
		#make standard2example_func.mat and example_func2standard.mat
		#apply warps
		$FSLDIR/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
		$FSLDIR/bin/applywarp --ref=standard --in=example_func --out=example_func2standard --warp=highres2standard_warp --premat=example_func2highres.mat --interp=sinc
		$FSLDIR/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
		$FSLDIR/bin/slicer example_func2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard1.png ; $FSLDIR/bin/slicer standard example_func2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard2.png ; $FSLDIR/bin/pngappend example_func2standard1.png - example_func2standard2.png example_func2standard.png; /bin/rm -f sl?.png
	fi

fi

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
