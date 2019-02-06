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
FNIRT=SUB_FNIRT_SUB
SETORIGIN=SUB_SETORIGIN_SUB



MAINDIR=${EXPERIMENT}/Analysis

if [ $SETORIGIN -eq 1 ]; then
	ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
	ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
	DATA=$MAINDIR/NIFTI/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz
	if [ $FNIRT -eq 1 ]; then
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	else
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	fi
else
	ANATH=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat
	ANAT=${MAINDIR}/NIFTI2/$SUBJ/${SUBJ}_anat_brain
	DATA=$MAINDIR/NIFTI2/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz
	if [ $FNIRT -eq 1 ]; then
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FNIRT_noSO/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	else
		MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats_FLIRT_noSO/Smooth_${SMOOTH}mm
		mkdir -p $MAINOUTPUT
		OUTPUT=${MAINOUTPUT}/run${RUN}
	fi
fi

STANDARD=${MAINDIR}/FSL/MNI152_T1_1.8mm_brain
STANDARDH=${MAINDIR}/FSL/MNI152_T1_1.8mm


if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi

if [ -e ${OUTPUT}.feat/filtered_func_data.nii.gz ]; then
	echo "exists: ${OUTPUT}.feat/filtered_func_data.nii.gz"
	XX=`fslstats ${OUTPUT}.feat/filtered_func_data.nii.gz -m`
	if [ $XX == "nan" ]; then
		echo "found $XX in the filtered func file. deleting and starting over..."
		rm -rf ${OUTPUT}.feat
	fi
else
	echo "does not exist: ${OUTPUT}.feat/filtered_func_data.nii.gz"
	rm -rf ${OUTPUT}.feat
fi

NVOLUMES=`fslnvols ${DATA}`
TEMPLATE=${MAINDIR}/FSL/templates/prestats.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@STANDARD@'$STANDARD'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

#run feat if it has been already
if [ -d ${OUTPUT}.feat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

#generate confoundevs
if [ -e ${OUTPUT}.feat/bad_timepoints.txt ]; then
	echo "found bad_timepoints file..."
else
	$FSLDIR/bin/fsl_motion_outliers ${DATA} 0 ${OUTPUT}.feat/bad_timepoints.txt
fi

INITIALHR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/wholebrainEPI_0mm_smooth/run3.feat/example_func
CHECKREG=${OUTPUT}.feat/reg/example_func2standard.png
if [ -e $CHECKREG ]; then
	echo "registration is complete..."
else
	echo "registration fail... trying again..."
	rm -rf $OUTPUT.feat/reg
	if [ $FNIRT -eq 1 ]; then
		cd ${OUTPUT}.feat
		mkdir -p reg
		${FSLDIR}/bin/fslmaths $INITIALHR reg/initial_highres
		${FSLDIR}/bin/fslmaths $ANAT reg/highres
		${FSLDIR}/bin/fslmaths $STANDARD reg/standard
		${FSLDIR}/bin/fslmaths $STANDARDH reg/standard_head
		${FSLDIR}/bin/fslmaths $ANATH  reg/highres_head
		${FSLDIR}/bin/bet mean_func mean_func_brain -f 0.3 -m
		mv example_func.nii.gz old_example_func.nii.gz
		${FSLDIR}/bin/fslmaths old_example_func -mas mean_func_brain_mask example_func
		${FSLDIR}/bin/fslmaths example_func reg/example_func
		${FSLDIR}/bin/fslmaths $STANDARD -bin -dilF -dilF reg/standard_mask -odt char
		cd reg
	
		#use initial high-res
		$FSLDIR/bin/flirt -ref initial_highres -in example_func -out example_func2initial_highres -omat example_func2initial_highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat initial_highres2example_func.mat example_func2initial_highres.mat
		$FSLDIR/bin/flirt -ref highres -in initial_highres -out initial_highres2highres -omat initial_highres2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat highres2initial_highres.mat initial_highres2highres.mat
		$FSLDIR/bin/convert_xfm -omat example_func2highres.mat -concat initial_highres2highres.mat example_func2initial_highres.mat
		
		$FSLDIR/bin/slicer example_func2initial_highres initial_highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2initial_highres1.png ; $FSLDIR/bin/slicer initial_highres example_func2initial_highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2initial_highres2.png ; $FSLDIR/bin/pngappend example_func2initial_highres1.png - example_func2initial_highres2.png example_func2initial_highres.png; /bin/rm -f sl?.png
	
		$FSLDIR/bin/slicer initial_highres2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png initial_highres2highres1.png ; $FSLDIR/bin/slicer highres initial_highres2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png initial_highres2highres2.png ; $FSLDIR/bin/pngappend initial_highres2highres1.png - initial_highres2highres2.png initial_highres2highres.png; /bin/rm -f sl?.png
	
	
		${FSLDIR}/bin/flirt -ref highres -in example_func -out example_func2highres -omat example_func2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		
		${FSLDIR}/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
		
		${FSLDIR}/bin/slicer example_func2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres1.png ; ${FSLDIR}/bin/slicer highres example_func2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres2.png ; ${FSLDIR}/bin/pngappend example_func2highres1.png - example_func2highres2.png example_func2highres.png; /bin/rm -f sl?.png
		
		${FSLDIR}/bin/flirt -ref standard -in highres -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		
		${FSLDIR}/bin/fnirt --in=highres_head --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2standard_jac --config=T1_2_MNI152_2mm --ref=standard_head --refmask=standard_mask --warpres=9,9,9 --applyrefmask=0,1,1,1,1,1
		
		${FSLDIR}/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
		
		${FSLDIR}/bin/slicer highres2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard1.png ; ${FSLDIR}/bin/slicer standard highres2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard2.png ; ${FSLDIR}/bin/pngappend highres2standard1.png - highres2standard2.png highres2standard.png; /bin/rm -f sl?.png
		
		${FSLDIR}/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
		
		${FSLDIR}/bin/applywarp --ref=standard --in=example_func --out=example_func2standard --warp=highres2standard_warp --premat=example_func2highres.mat --interp=sinc
		
		${FSLDIR}/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
		
		${FSLDIR}/bin/slicer example_func2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard1.png ; ${FSLDIR}/bin/slicer standard example_func2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard2.png ; ${FSLDIR}/bin/pngappend example_func2standard1.png - example_func2standard2.png example_func2standard.png; /bin/rm -f sl?.png
	
	else
		cd ${OUTPUT}.feat
		mkdir -p reg
		${FSLDIR}/bin/fslmaths $INITIALHR reg/initial_highres
		${FSLDIR}/bin/fslmaths $ANAT reg/highres
		${FSLDIR}/bin/fslmaths $STANDARD reg/standard
		${FSLDIR}/bin/bet mean_func mean_func_brain -f 0.3 -m
		mv example_func.nii.gz old_example_func.nii.gz
		${FSLDIR}/bin/fslmaths old_example_func -mas mean_func_brain_mask example_func
		${FSLDIR}/bin/fslmaths example_func reg/example_func
		cd reg
		
		#use initial high-res
		$FSLDIR/bin/flirt -ref initial_highres -in example_func -out example_func2initial_highres -omat example_func2initial_highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat initial_highres2example_func.mat example_func2initial_highres.mat
		$FSLDIR/bin/flirt -ref highres -in initial_highres -out initial_highres2highres -omat initial_highres2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		$FSLDIR/bin/convert_xfm -inverse -omat highres2initial_highres.mat initial_highres2highres.mat
		$FSLDIR/bin/convert_xfm -omat example_func2highres.mat -concat initial_highres2highres.mat example_func2initial_highres.mat
	
		$FSLDIR/bin/slicer example_func2initial_highres initial_highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2initial_highres1.png ; $FSLDIR/bin/slicer initial_highres example_func2initial_highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2initial_highres2.png ; $FSLDIR/bin/pngappend example_func2initial_highres1.png - example_func2initial_highres2.png example_func2initial_highres.png; /bin/rm -f sl?.png
		
		$FSLDIR/bin/slicer initial_highres2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png initial_highres2highres1.png ; $FSLDIR/bin/slicer highres initial_highres2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png initial_highres2highres2.png ; $FSLDIR/bin/pngappend initial_highres2highres1.png - initial_highres2highres2.png initial_highres2highres.png; /bin/rm -f sl?.png
	
	
		${FSLDIR}/bin/flirt -ref highres -in example_func -out example_func2highres -omat example_func2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		${FSLDIR}/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
		${FSLDIR}/bin/flirt -ref standard -in highres -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp sinc -sincwindow hanning -usesqform
		${FSLDIR}/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
		${FSLDIR}/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
		${FSLDIR}/bin/flirt -ref standard -in example_func -out example_func2standard -applyxfm -init example_func2standard.mat -interp sinc -sincwindow hanning -usesqform
		${FSLDIR}/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
		
		${FSLDIR}/bin/slicer example_func2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres1.png ; ${FSLDIR}/bin/slicer highres example_func2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres2.png ; ${FSLDIR}/bin/pngappend example_func2highres1.png - example_func2highres2.png example_func2highres.png; /bin/rm -f sl?.png
		
		${FSLDIR}/bin/slicer highres2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard1.png ; ${FSLDIR}/bin/slicer standard highres2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard2.png ; ${FSLDIR}/bin/pngappend highres2standard1.png - highres2standard2.png highres2standard.png; /bin/rm -f sl?.png
		
		${FSLDIR}/bin/slicer example_func2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard1.png ; ${FSLDIR}/bin/slicer standard example_func2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard2.png ; ${FSLDIR}/bin/pngappend example_func2standard1.png - example_func2standard2.png example_func2standard.png; /bin/rm -f sl?.png
	
	fi
fi

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
