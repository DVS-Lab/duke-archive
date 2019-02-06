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

SUBJ=$1
SMOOTH=0
RUN=1


MAINDIR=${EXPERIMENT}/Analysis

ANATH=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat
ANAT=${MAINDIR}/NIFTI/$SUBJ/${SUBJ}_anat_brain
DATA=$MAINDIR/NIFTI/${SUBJ}/fMRIphysiowholebrain${SUBJ}.nii.gz

MAINOUTPUT=${MAINDIR}/FSL/${SUBJ}/wholebrainEPI_${SMOOTH}mm_smooth
mkdir -p $MAINOUTPUT
OUTPUT=${MAINOUTPUT}/run${RUN}_wB0

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.feat
fi

FIELDMAP=${MAINDIR}/NIFTI/$SUBJ/fmap_rads.nii.gz
MAGIMAGE=${MAINDIR}/NIFTI/$SUBJ/mag_brain.nii.gz

STANDARD=${MAINDIR}/FSL/MNI152_T1_1.8mm_brain
STANDARDH=${MAINDIR}/FSL/MNI152_T1_1.8mm

NVOLUMES=`fslnvols ${DATA}`
TEMPLATE=${MAINDIR}/FSL/templates/prestatsB0.fsf
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@ANAT@'$ANAT'@g' \
-e 's@DATA@'$DATA'@g' \
-e 's@NVOLUMES@'$NVOLUMES'@g' \
-e 's@SMOOTH@'$SMOOTH'@g' \
-e 's@STANDARD@'$STANDARD'@g' \
-e 's@FIELDMAP@'$FIELDMAP'@g' \
-e 's@MAGIMAGE@'$MAGIMAGE'@g' \
<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf

#run feat if it has been already
if [ -d ${OUTPUT}.feat ]; then
	echo "this one is already done"
else
	$FSLDIR/bin/feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
fi


cd ${OUTPUT}.feat
rm -f core.*

cp -r ${OUTPUT}.feat/unwarp ${OUTPUT}.feat/old_unwarp


#------------THE FIX----------------------
#new stuff here:
cd ${OUTPUT}.feat/unwarp
#estimate transforms. no rotations since we have partial brains
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
${FSLDIR}/bin/applywarp -i example_func_orig_distorted -o example_func_sinc -w unwarp/EF_UD_warp -r example_func_orig_distorted --abs --interp=sinc
${FSLDIR}/bin/applywarp -i example_func_orig_distorted -o example_func_trilinear -w unwarp/EF_UD_warp -r example_func_orig_distorted --abs --interp=trilinear

if [ -d ${OUTPUT}.feat/reg ]; then
	mv ${OUTPUT}.feat/reg ${OUTPUT}.feat/old_reg
fi
mkdir -p reg
${FSLDIR}/bin/fslmaths $ANAT reg/highres
${FSLDIR}/bin/fslmaths $STANDARD reg/standard
mv example_func_spline.nii.gz old_example_func_spline.nii.gz
#mv example_func.nii.gz old_example_func.nii.gz
${FSLDIR}/bin/bet old_example_func_spline example_func -f .2 #was .3 #was .4
fslmaths example_func reg/example_func
cd reg


#applywarp --interp=spline -i T2_brain.nii.gz -r T1_brain.nii.gz --premat=T2_to_T1.mat -o T2_to_T1.nii.gz 
#will apply a precalculated transformation matrix (that you calculated earlier from flirt) to an image with spline interpolation. 

${FSLDIR}/bin/flirt -ref highres -in example_func -out example_func2highres -omat example_func2highres.mat -cost corratio -dof 6 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -usesqform
${FSLDIR}/bin/convert_xfm -inverse -omat highres2example_func.mat example_func2highres.mat
${FSLDIR}/bin/flirt -ref standard -in highres -omat highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -usesqform
applywarp --interp=spline -i highres -r standard --premat=highres2standard.mat -o highres2standard
${FSLDIR}/bin/convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
${FSLDIR}/bin/convert_xfm -omat example_func2standard.mat -concat highres2standard.mat example_func2highres.mat
# #${FSLDIR}/bin/flirt -ref standard -in example_func -out example_func2standard -applyxfm -init example_func2standard.mat -interp sinc -sincwindow hanning -usesqform
${FSLDIR}/bin/convert_xfm -inverse -omat standard2example_func.mat example_func2standard.mat
applywarp --interp=spline -i example_func -r standard --premat=example_func2standard.mat -o example_func2standard



${FSLDIR}/bin/slicer example_func2highres highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres1.png ; ${FSLDIR}/bin/slicer highres example_func2highres -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2highres2.png ; ${FSLDIR}/bin/pngappend example_func2highres1.png - example_func2highres2.png example_func2highres.png; /bin/rm -f sl?.png

${FSLDIR}/bin/slicer highres2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard1.png ; ${FSLDIR}/bin/slicer standard highres2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png highres2standard2.png ; ${FSLDIR}/bin/pngappend highres2standard1.png - highres2standard2.png highres2standard.png; /bin/rm -f sl?.png

${FSLDIR}/bin/slicer example_func2standard standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard1.png ; ${FSLDIR}/bin/slicer standard example_func2standard -s 2 -x 0.35 sla.png -x 0.45 slb.png -x 0.55 slc.png -x 0.65 sld.png -y 0.35 sle.png -y 0.45 slf.png -y 0.55 slg.png -y 0.65 slh.png -z 0.35 sli.png -z 0.45 slj.png -z 0.55 slk.png -z 0.65 sll.png ; ${FSLDIR}/bin/pngappend sla.png + slb.png + slc.png + sld.png + sle.png + slf.png + slg.png + slh.png + sli.png + slj.png + slk.png + sll.png example_func2standard2.png ; ${FSLDIR}/bin/pngappend example_func2standard1.png - example_func2standard2.png example_func2standard.png; /bin/rm -f sl?.png


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
