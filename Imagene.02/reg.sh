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
TASK=SUB_TASK_SUB
GO=SUB_GO_SUB
FNIRT=SUB_FNIRT_SUB


SKIP=0
#-----------EXCEPTIONS FOR FUNCTIONAL DATA--------
#20091214_10179 (has anatomical data, but no functional data. what happened?)

#--changed time points starting on 10279. IRG cut to two runs. 
if [ $SUBJ -ge 10279 ] && [ "$TASK" == "Risk" ] && [ $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20091210_10168/20091210_10169 (restart; same subject; missing run3 of MID) -- everything is under 10168
if [ $SUBJ -eq 10168 ] && [ "$TASK" == "MID" ] && [ $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10169 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20091208_10156 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100119_10256 -- no resting state, only 1 of the 3 runs of the Risk Task
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10156 -o $SUBJ -eq 10256 ] && [ "$TASK" == "Risk" -a $RUN -gt 1 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100120_10264 -- no resting state, missing 3rd run of the Risk Task
#20100120_10265 -- no resting state, missing 3rd run of the Risk Task
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10264 -o $SUBJ -eq 10265 ] && [ "$TASK" == "Risk" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100126_10280 -- no resting state
#20100127_10287 -- no resting state
#20100128_10294 -- no resting state
#20100310_10481 -- no resting state
if [ $SUBJ -eq 10280 -o $SUBJ -eq 10287 -o $SUBJ -eq 10294 -o $SUBJ -eq 10481 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100224_10387 -- no resting state, also missing framing run3 and all of the Risk task -- subject had to get out of the scanner
if [ $SUBJ -eq 10387 -a "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10387 -a "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10387 -a "$TASK" == "Framing" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20100212_10335 -- missing run3 of MID
#20100216_10350 -- missing run3 of MID
#20100216_10351 -- missing run3 of MID
if [ $SUBJ -eq 10335 -o $SUBJ -eq 10350 -o $SUBJ -eq 10351 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100309_10471 -- only has MID runs 1 and 2. missing everything else. scanner fail.
if [ $SUBJ -eq 10471 ] && [ "$TASK" == "Resting" -o "$TASK" == "Risk" -o "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 10471 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100330_10602: no resting state
if [ $SUBJ -eq 10602 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100413_10699: he didn't have any of McKell's task, but he still had resting state in run004_08
if [ $SUBJ -eq 10699 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#new exceptions (9/28/10)
#----new exceptions: june, july, august, september

#20100818_11272/20100810_11235: no resting
if [ $SUBJ -eq 11272 -o $SUBJ -eq 11235 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20100811_11244 -- only has MID runs 1. missing everything else. BIAC fail (server = full).
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "MID" ] && [ $RUN -gt 1 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11244 ] && [ "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20100811_11245 -- missing MID1 and MID2, and resting. BIAC fail (server = full).
if [ $SUBJ -eq 11245 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11245 ] && [ "$TASK" == "MID" -a $RUN -lt 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20110106_12082: no risk
if [ $SUBJ -eq 12082 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20110128_12193 -- nothing after MID2. just two runs of data. fail.
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12193 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi



#20110311_12411 -- no resting
if [ $SUBJ -eq 12411 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#20110401_12580 -- only MID and resting state
if [ $SUBJ -eq 12580 ] && [ "$TASK" == "Risk" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12580 ] && [ "$TASK" == "Framing" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#20110502_12815/20110512_12875: no resting
if [ $SUBJ -eq 12815 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 12875 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#12893/13011 : no resting
if [ $SUBJ -eq 12893 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 13011 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#11196: no resting, no GC3, no IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Risk" -a $RUN -eq 2 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11196 ] && [ "$TASK" == "Framing" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi


#11210: no MID3, no GC3 (CHECK FAT SAT!)
if [ $SUBJ -eq 11210 ] && [ "$TASK" == "MID" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11210 ] && [ "$TASK" == "Framing" -a $RUN -eq 3 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#11212: no resting or IRG2 (CHECK FAT SAT!)
if [ $SUBJ -eq 11212 ] && [ "$TASK" == "Risk" -a $RUN -eq 2 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
if [ $SUBJ -eq 11212 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi

#10783: no resting -- petty: confirmed data lost 5/17/10 (scanner fail)
if [ $SUBJ -eq 10783 ] && [ "$TASK" == "Resting" ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi
#10783: no risk run2 -- petty: confirmed data lost 5/17/10 (scanner fail)
if [ $SUBJ -eq 10783 ] && [ "$TASK" == "Risk" -a $RUN -eq 2 ]; then
	echo "skipping $SUBJ $TASK run $RUN"
	SKIP=1
fi



#--------end exceptions list-------


MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
if [ $FNIRT -eq 1 ]; then
	MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC_FNIRT/Smooth_${SMOOTH}mm
else
	MAINOUTPUT=${SUBJDIR}/${TASK}/MELODIC_FLIRT/Smooth_${SMOOTH}mm
fi

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.ica

ANAT=${SUBJDIR}/${SUBJ}_anat_brain
ANATH=${SUBJDIR}/${SUBJ}_anat

OUTPUT=${MAINOUTPUT}/run${RUN}

DATA=${SUBJDIR}/${TASK}/MELODIC_FLIRT/Smooth_${SMOOTH}mm/run${RUN}.ica/filtered_func_data.nii.gz
EF=${OUTPUTREAL}/example_func
MF=${OUTPUTREAL}/mean_func

if [ $GO -eq 1 ]; then
	rm -rf ${OUTPUT}.ica/reg
fi

if [ $SKIP -eq 1 ]; then
	echo "skipping exceptions..."
else
	if [ $FNIRT -eq 1 ]; then
		CHECKREG=${OUTPUT}.ica/reg/example_func2standard.png
		if [ -e $CHECKREG ]; then
			echo "registration is complete..."
		else
			if [ $GO -gt 1 ]; then
				echo "registration fail... trying again..."
			fi
			REGDIR=${OUTPUT}.ica/reg
mv ${OUTPUT}.ica/reg ${OUTPUT}.ica/reg_old
mkdir -p $REGDIR
cd $REGDIR

#prep images
$FSLDIR/bin/fslmaths $ANAT highres
$FSLDIR/bin/fslmaths $EXPERIMENT/Analysis/TaskData/MNI_diffeo_brain standard
$FSLDIR/bin/fslmaths $EXPERIMENT/Analysis/TaskData/MNI_diffeo standard_head
$FSLDIR/bin/fslmaths standard -bin -dilF -dilF standard_mask -odt char
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
	else
		CHECKREG=${OUTPUT}.ica/reg/example_func2standard.png
		if [ -e $CHECKREG ]; then
			echo "registration is complete..."
		else
			if [ $GO -gt 1 ]; then
				echo "registration fail... trying again..."
			fi
			REGDIR=${OUTPUT}.ica/reg
			mv ${OUTPUT}.ica/reg ${OUTPUT}.ica/reg_old
			mkdir -p $REGDIR
			cd $REGDIR
			
			#prep images
			$FSLDIR/bin/fslmaths $ANAT highres
			$FSLDIR/bin/fslmaths $EXPERIMENT/Analysis/TaskData/MNI_diffeo_brain standard
			$FSLDIR/bin/fslmaths standard -bin -dilF -dilF standard_mask -odt char
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
	fi
fi
OUTDIR=${MAINOUTPUT}/Logs/reg/GO_${GO}
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
