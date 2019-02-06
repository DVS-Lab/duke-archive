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


ls /mnt/BIAC/munin.dhe.duke.edu/Huettel/HighRes.01
sleep 5s


SUBJ=SUB_SUBNUM_SUB
RUN=SUB_RUN_SUB
SMOOTH=SUB_SMOOTH_SUB
GO=SUB_GO_SUB
FNIRT=SUB_FNIRT_SUB
SETORIGIN=SUB_SETORIGIN_SUB

if [ $SUBJ -gt 1023 ]; then
	SET_TR=1.99
else
	SET_TR=1.96
fi


MAINDIR=${EXPERIMENT}/Analysis

ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
DATA=$MAINDIR/NIFTI/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz

#correct for physio artifacts
#~/part -s 1 -p ${EXPERIMENT}/Data/Physio/renamed_files2/${SUBJ}/${SUBJ}_run${RUN}.puls ${DATA}
CORRECTEDDATA=$MAINDIR/NIFTI/${SUBJ}/fMRIphysio${RUN}new${SUBJ}.nii.gz

MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/PreStats/Smooth_${SMOOTH}mm
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/run${RUN}

FIELDMAP=${MAINDIR}/NIFTI/$SUBJ/fmap_rads.nii.gz
MAGIMAGE=${MAINDIR}/NIFTI/$SUBJ/mag_brain.nii.gz

STANDARD=${MAINDIR}/FSL/MNI152_T1_1.8mm_brain
STANDARDH=${MAINDIR}/FSL/MNI152_T1_1.8mm


if [ $GO -eq 1 ]; then
	if [ -d ${OUTPUT}.feat ]; then
		rm -rf ${OUTPUT}.feat
	fi
fi


FILE_TO_CHECK=${OUTPUT}.feat/prestats_phase2_2resample.ica/filtered_func_data.nii.gz
if [ -e ${FILE_TO_CHECK} ]; then
	echo "exists: ${OUTPUT}.feat/filtered_func_data.nii.gz"
	XX=`fslstats ${OUTPUT}.feat/filtered_func_data.nii.gz -m`
	if [ $XX == "nan" ]; then
		echo "found $XX in the filtered func file. deleting and starting over..."
		rm -rf ${OUTPUT}.feat
	fi
else
	if [ -d ${OUTPUT}.feat ]; then
		rm -rf ${OUTPUT}.feat
	fi
fi



NVOLUMES=`fslnvols ${CORRECTEDDATA}`
TEMPLATE=${MAINDIR}/FSL/templates/prestats_phase1.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$CORRECTEDDATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@FIELDMAP@'$FIELDMAP'@g' \
-e 's@MAGIMAGE@'$MAGIMAGE'@g' \
-e 's@SET_TR@'$SET_TR'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

#run feat if it has been already
if [ -d ${OUTPUT}.feat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi

cd ${OUTPUT}.feat

cp -r ${OUTPUT}.feat/unwarp ${OUTPUT}.feat/old_unwarp


#------------THE FIX----------------------
#new stuff here:
cd ${OUTPUT}.feat/unwarp
#estimate transforms. two steps... http://www.fmrib.ox.ac.uk/fslcourse/lectures/practicals/reg/index.html#partial 
# #$FSLDIR/bin/flirt -in EF_D_example_func -ref FM_D_fmap_mag_brain_siglossed -omat EF_2_FM.mat -cost corratio -dof 6 -schedule $FSLDIR/etc/flirtsch/sch3Dtrans_3dof -o grot -dof 6 -refweight FM_D_fmap_sigloss -usesqform
flirt -in EF_D_example_func -ref FM_D_fmap_mag_brain_siglossed -schedule $FSLDIR/etc/flirtsch/sch3Dtrans_3dof -omat EF_2_FM_pre.mat -refweight FM_D_fmap_sigloss -out grotA -usesqform
flirt -in EF_D_example_func -ref FM_D_fmap_mag_brain_siglossed -dof 6 -omat EF_2_FM.mat -init EF_2_FM_pre.mat -nosearch -out grotB -usesqform
#flirt -in partial_brain -ref whole_brain -schedule $FSLDIR/etc/flirtsch/xyztrans.sch -omat partial2whole.mat -out partial2whole
#flirt -in partial_brain -ref whole_brain -dof 6 -out partial2wholeB -omat partial2wholeB.mat -init partial2whole.mat -nosearch

$FSLDIR/bin/convert_xfm -omat FM_2_EF.mat -inverse EF_2_FM.mat
$FSLDIR/bin/flirt -in FM_UD_fmap                -ref EF_D_example_func -init FM_2_EF.mat -applyxfm -out EF_UD_fmap
$FSLDIR/bin/flirt -in FM_UD_fmap_mag_brain      -ref EF_D_example_func -init FM_2_EF.mat -applyxfm -out EF_UD_fmap_mag_brain
$FSLDIR/bin/flirt -in FM_UD_fmap_mag_brain_mask -ref EF_D_example_func -init FM_2_EF.mat -applyxfm -out EF_UD_fmap_mag_brain_mask
$FSLDIR/bin/flirt -in FM_UD_fmap_sigloss        -ref EF_D_example_func -init FM_2_EF.mat -applyxfm -out EF_UD_fmap_sigloss

$FSLDIR/bin/fslmaths EF_UD_fmap_mag_brain_mask -thr 0.5 -bin EF_UD_fmap_mag_brain_mask -odt float
$FSLDIR/bin/fslmaths EF_UD_fmap_sigloss -thr 0.9 EF_UD_fmap_sigloss -odt float
$FSLDIR/bin/overlay 1 0 EF_UD_fmap_mag_brain -a EF_UD_fmap_sigloss 0 1 grot
$FSLDIR/bin/slicer grot -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png EF_UD_sigloss+mag.png

$FSLDIR/bin/fugue --loadfmap=EF_UD_fmap --dwell=0.000345 --mask=EF_UD_fmap_mag_brain_mask -i EF_D_example_func -u EF_UD_example_func --unwarpdir=y- --saveshift=EF_UD_shift

$FSLDIR/bin/convertwarp -s EF_UD_shift -o EF_UD_warp -r EF_D_example_func --shiftdir=y-

# #$FSLDIR/bin/fslstats EF_UD_shift -R -P 1 -P 99
VAL1=`$FSLDIR/bin/fslstats EF_UD_shift -R -P 1 -P 99 | awk '{ print $1 }'`
VAL2=`$FSLDIR/bin/fslstats EF_UD_shift -R -P 1 -P 99 | awk '{ print $2 }'`
VAL3=`$FSLDIR/bin/fslstats EF_UD_shift -R -P 1 -P 99 | awk '{ print $3 }'`
VAL4=`$FSLDIR/bin/fslstats EF_UD_shift -R -P 1 -P 99 | awk '{ print $4 }'`
$FSLDIR/bin/fslmaths EF_UD_shift -mul -1 grot
VAL3=`echo -1*$VAL3 | bc`
$FSLDIR/bin/overlay 1 0 EF_UD_fmap_mag_brain -a EF_UD_shift 0.0001 $VAL4 grot 0.0001 $VAL3 grot


#make images and movies
$FSLDIR/bin/slicer grot -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png EF_UD_shift+mag.png
/bin/cp $FSLDIR/etc/luts/ramp.gif .ramp.gif
/bin/cp $FSLDIR/etc/luts/ramp2.gif .ramp2.gif
$FSLDIR/bin/slicer EF_D_example_func    -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png EF_D_example_func.gif
$FSLDIR/bin/slicer EF_UD_example_func    -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png EF_UD_example_func.gif

$FSLDIR/bin/slicer EF_UD_fmap_mag_brain    -s 3 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png EF_UD_fmap_mag_brain.gif

$FSLDIR/bin/whirlgif -o EF_UD_movie2.gif -time 50 -loop 0 EF_D_example_func.gif EF_UD_example_func.gif
$FSLDIR/bin/whirlgif -o EF_UD_movie3ud.gif -time 50 -loop 0 EF_UD_example_func.gif EF_UD_fmap_mag_brain.gif
$FSLDIR/bin/whirlgif -o EF_UD_movie3d.gif -time 50 -loop 0 EF_D_example_func.gif EF_UD_fmap_mag_brain.gif
$FSLDIR/bin/whirlgif -o EF_UD_movie3.gif -time 50 -loop 0 EF_D_example_func.gif EF_UD_example_func.gif EF_UD_fmap_mag_brain.gif
/bin/rm -f sla* slb* slc* sld* sle* slf* slg* slh* sli* slj* slk* sll* grot*

#------------THE FIX----------------------


cd ${OUTPUT}.feat
${FSLDIR}/bin/applywarp -i example_func_orig_distorted -o example_func_spline -w unwarp/EF_UD_warp -r example_func_orig_distorted --abs --interp=spline
# #${FSLDIR}/bin/applywarp -i example_func_orig_distorted -o example_func_sinc -w unwarp/EF_UD_warp -r example_func_orig_distorted --abs --interp=sinc


#excess/redundant files that should be deleted
rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz


#generate confoundevs
if [ -e ${OUTPUT}.feat/bad_timepoints.txt ]; then
	echo "found bad_timepoints file..."
else
	$FSLDIR/bin/fsl_motion_outliers ${DATA} 0 ${OUTPUT}.feat/bad_timepoints.txt
fi

INITIALHR=${EXPERIMENT}/Analysis/FSL/${SUBJ}/wholebrainEPI_0mm_smooth/run1_wB0.feat/example_func
CHECKREG=${OUTPUT}.feat/reg/PNG_images/example_func2standard.png
if [ -e $CHECKREG ]; then
	echo "registration is complete..."
else
	if [ $GO -gt 1 ]; then
		echo "registration fail... trying again..."
	fi
	if [ -d ${OUTPUT}.feat/reg ]; then
		mv ${OUTPUT}.feat/reg ${OUTPUT}.feat/reg_old
	fi
	mkdir -p ${OUTPUT}.feat/reg
	cd ${OUTPUT}.feat/reg
	
	#prep images
	$FSLDIR/bin/fslmaths $INITIALHR initial_highres #this is distorted (has 60 slices whereas the fieldmap has 30 slices, covering exactly the same area as the partial FOV example_func)
	$FSLDIR/bin/fslmaths $ANAT highres
	$FSLDIR/bin/fslmaths $EXPERIMENT/Analysis/FSL/MNI152_T1_1.8mm_brain standard
	$FSLDIR/bin/fslmaths $EXPERIMENT/Analysis/FSL/MNI152_T1_1.8mm standard_head
	$FSLDIR/bin/fslmaths standard -bin -dilF -dilF standard_mask -odt char
	$FSLDIR/bin/fslmaths $ANATH highres_head

	#can't use this because it relies on the default B0 unwarping
	# #$FSLDIR/bin/bet ../mean_func ../mean_func_brain -f 0.3 -m
	#mv ../example_func_orig_distorted.nii.gz ../old_example_func_distorted.nii.gz
	#mv ../example_func.nii.gz ../old_example_func_undistorted.nii.gz

	mv ../example_func_spline.nii.gz ../old_example_func_spline.nii.gz
	#mv example_func.nii.gz old_example_func.nii.gz
	${FSLDIR}/bin/bet ../old_example_func_spline ../example_func -f .2 #was .45 #may need to revise this
	# #$FSLDIR/bin/fslmaths ../old_example_func_undistorted -mas ../mean_func_brain_mask ../example_func
	$FSLDIR/bin/fslmaths ../example_func example_func
	
	
	#make initial_highres2example_func.mat AND example_func2initial_highres.mat
	$FSLDIR/bin/flirt -ref initial_highres -in example_func -out example_func2initial_highres -omat example_func2initial_highres.mat -cost corratio -dof 6 -schedule $FSLDIR/etc/flirtsch/sch3Dtrans_3dof -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -usesqform -inweight ../unwarp/EF_UD_fmap_sigloss
	$FSLDIR/bin/convert_xfm -inverse -omat initial_highres2example_func.mat example_func2initial_highres.mat
	$FSLDIR/bin/slicer example_func2initial_highres initial_highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2initial_highres1.png ; $FSLDIR/bin/slicer initial_highres example_func2initial_highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2initial_highres2.png ; $FSLDIR/bin/pngappend example_func2initial_highres1.png - example_func2initial_highres2.png example_func2initial_highres.png; /bin/rm -f sl?.png
	
	
	#make highres2initial_highres.mat AND initial_highres2highres.mat
	$FSLDIR/bin/flirt -ref highres -in initial_highres -out initial_highres2highres -omat initial_highres2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -usesqform
	$FSLDIR/bin/convert_xfm -inverse -omat highres2initial_highres.mat initial_highres2highres.mat
	$FSLDIR/bin/slicer initial_highres2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png initial_highres2highres1.png ; $FSLDIR/bin/slicer highres initial_highres2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png initial_highres2highres2.png ; $FSLDIR/bin/pngappend initial_highres2highres1.png - initial_highres2highres2.png initial_highres2highres.png; /bin/rm -f sl?.png
	
	
	#make highres2example_func.mat AND example_func2initial_highres.mat
	#--this is where one of the -concat options is. there should be another one for the example_func2standard--
	$FSLDIR/bin/convert_xfm -omat example_func2highres.mat -concat initial_highres2highres.mat example_func2initial_highres.mat
	$FSLDIR/bin/flirt -ref highres -in example_func -out example_func2highres -applyxfm -init example_func2highres.mat -usesqform
	$FSLDIR/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
	$FSLDIR/bin/slicer example_func2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres1.png ; $FSLDIR/bin/slicer highres example_func2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres2.png ; $FSLDIR/bin/pngappend example_func2highres1.png - example_func2highres2.png example_func2highres.png; /bin/rm -f sl?.png
	
	
	#registering highres2standard
	#make highres2standard.mat and standard2highres.mat
	#then run fnirt to get warps
	${FSLDIR}/bin/flirt -ref standard -in highres -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -usesqform
	applywarp --interp=spline -i highres -r standard --premat=highres2standard.mat -o highres2standard
	#$FSLDIR/bin/fnirt --in=highres_head --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2standard_jac --config=T1_2_MNI152_2mm --ref=standard_head --refmask=standard_mask --warpres=9,9,9 --applyrefmask=0,1,1,1,1,1
	$FSLDIR/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
	$FSLDIR/bin/slicer highres2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard1.png ; $FSLDIR/bin/slicer standard highres2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard2.png ; $FSLDIR/bin/pngappend highres2standard1.png - highres2standard2.png highres2standard.png; /bin/rm -f sl?.png
	
	
	#make standard2example_func.mat and example_func2standard.mat
	#apply warps
	$FSLDIR/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
	#$FSLDIR/bin/applywarp --ref=standard --in=example_func --out=example_func2standard --warp=highres2standard_warp --premat=example_func2highres.mat --interp=spline
	applywarp --interp=spline -i example_func -r standard --premat=example_func2standard.mat -o example_func2standard
	$FSLDIR/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
	$FSLDIR/bin/slicer example_func2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard1.png ; $FSLDIR/bin/slicer standard example_func2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; $FSLDIR/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard2.png ; $FSLDIR/bin/pngappend example_func2standard1.png - example_func2standard2.png example_func2standard.png; /bin/rm -f sl?.png
	
	#move *.png files to separate directory
	mkdir PNG_images
	mv *.png PNG_images/.
	
	
	#make data folder for all EPI volumes

	MCFDATA=${OUTPUT}.feat/data_out
	mkdir ${MCFDATA}
	fslsplit $CORRECTEDDATA ${MCFDATA}/tmp_data -t
	NVOLS=`fslnvols $DATA`
	let NVOLS=$NVOLS-1
	
	MCMATS=${OUTPUT}.feat/mc/prefiltered_func_data_mcf.mat
	for i in `seq 0 $NVOLS`; do
		#goal: example_func (3 DOF) -> intial_highres (6 DOF) -> highres (12 DOF + FNIRT) -> standard 
		#convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
	
		I=`printf %04d $i`

		#temp for testing only -- opted for the 2 resamplings (7/25/11)
		$FSLDIR/bin/applywarp -i ${MCFDATA}/tmp_data${I} -o ${MCFDATA}/mcf_data${I} --premat=${MCMATS}/MAT_${I} -w ${OUTPUT}.feat/unwarp/EF_UD_warp -r ${OUTPUT}.feat/reg/example_func --abs --mask=${OUTPUT}.feat/unwarp/EF_UD_fmap_mag_brain_mask --interp=spline

	done

	#fslmerge -tr ${MCFDATA}/normed_data ${MCFDATA}/data2standard* 1.96
	fslmerge -tr ${MCFDATA}/mcfdata_4D ${MCFDATA}/mcf_data* $SET_TR

fi


FEATOUTPUT=${OUTPUT}.feat

if [ -e ${FEATOUTPUT}/pmcfdata_4D_dSD.nii.gz ]; then
	echo "found physio SD file... no rerunning..."
else
	~/part -s 1 -1 ${EXPERIMENT}/Data/MRI/${SUBJ}_*/fMRI_physio_${RUN}_new_*/00001.dcm -p ${EXPERIMENT}/Data/Physio/renamed_files2/${SUBJ}/${SUBJ}_run${RUN}.puls ${MCFDATA}/mcfdata_4D.nii.gz
	mv ${MCFDATA}/pmcfdata_4D_dSD.nii.gz ${FEATOUTPUT}/.
	MCFDATAFILE=${MCFDATA}/pmcfdata_4D.nii.gz
fi

#testing-------------------------------: decided to do the two resamplings (7/25/11)

#finishing prestats: filtering, grand mean intensity normalization, and melodic (just for kicks)


OUTPUT=${FEATOUTPUT}/prestats_phase2_2resample
NVOLUMES=`fslnvols ${DATA}`
TEMPLATE=${MAINDIR}/FSL/templates/prestats_phase2.fsf
DOBET=0
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA@'$MCFDATAFILE'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@DOBET@'$DOBET'@g' \
-e 's@SET_TR@'$SET_TR'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_p2_0${RUN}.fsf

#run feat if it hasn't been already
if [ -d ${OUTPUT}.ica ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_p2_0${RUN}.fsf

	if [ -e ${OUTPUT}.ica/filtered_func_data.nii.gz ]; then
		# #${FSLDIR}/bin/applywarp --ref=${FEATOUTPUT}/reg/standard --in=${OUTPUT}.ica/filtered_func_data --out=${OUTPUT}.ica/std_filtered_func_data --warp=${FEATOUTPUT}/reg/highres2standard_warp --premat=${FEATOUTPUT}/reg/example_func2highres.mat --interp=spline
		rm -rf ${MCFDATAFILE}
	fi
fi



OUTDIR=${MAINOUTPUT}/Logs
mkdir -p $OUTDIR


if [ -e ${OUTPUT}.ica/filtered_func_data.nii.gz ]; then
	echo "yay, everything worked... clean up intermediate files to save space..."
	rm -rf $MCFDATA
else
	echo "still missing data..."
	OUTDIR=$MAINDIR/FSL/Logs/missingdata
	mkdir -p $OUTDIR
fi




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
