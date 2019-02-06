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

FSLDIR=/usr/local/packages/fsl-4.1.8
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH


SMOOTH=6
GO=1
N=0

#is this complete subject list for resting state data in IG.02? Or is this just pre-artifact?
#if this is just pre/post artifact, then i would suggest make a script for each one.
#and actually, shouldn't you have a script like this for ever group comparison that contains different subjects?
#for SUBJ in 47731 47734 47735 47737 47851 47863 47878 47917 47977 48012 48097 48100 48112 48145 48160 48176 48288 48327 48335 48339 48350 47729 47748 47885 47945 48090 48103 48179 48187 48193 48196 48204 48206 48232 48301 48309 48312 48321 48326 48330 48344 48351 ; do

for SUBJ in 11067 	11171 	11176 	11210 	11215 	11216 	11217 	11232 	11233 	11243 	11264 	11274 	11291 	11292 	11293 	11326 	11327 	11328 	11335 	11363 	11364 	11366 	11371 	11372 	11373 	11383 	11393 	11394 	11402 	11430 	11473 	11479 	11511 	11525 	11545 	11578 	11584 	11602 	11625 	11659 	11692 	11738 	11762 	11778 	11805 	11865 	11878 	11941 	11950 	12015 	12071 	12082 	12089 	12097 	12132 	12159 	12165 	12175 	12176 	12217 	12235 	12280 	12294 	12360 	12372 	12380 	12383 	12393 	12400 	12412 	12444 	12459 	12460 	12476 	12496 	12541 	12550 	12551 	12564 	12580 	12596 	12606 	12614 	12629 	12664 	12665 	12677 	12678 	12711 	12717 	12731 	12742 	12755 	12756 	12757 	12758 	12766 	12768 	12780 	12791 	12802 	12816 	12817 	12828 	12840 	12850 	12873 	12874 	12879 	12880 	12894 	12896 	12905 	12907 	12911 	12923 	12960 	12961 	12989; do
	
	
	
	# for TASK in "Framing" "MID" "Risk" "Resting"; do
	for TASK in "Resting"; do
		
		if [ "$TASK" == "Resting" ]; then
			RUNS=1
		else
			RUNS=3
		fi
		
		for RUN in `seq $RUNS`; do
			
			#since we don't have different data inputs now, let's just hardcode this (i.e., no $1 and $2)
			#DATANAME=unconfounded_data.nii.gz
			#OUTNAME=GroupICA_for_unconfound
			
			MAINDIR=${EXPERIMENT}/Analysis/TaskData
			OUTDIR=${EXPERIMENT}/Analysis/TaskData/GroupICA
			if [ ! -d $OUTDIR ]; then
				mkdir -p $OUTDIR
			fi
			DATAINPUT=${MAINDIR}/${SUBJ}/Resting/MELODIC_150/Smooth_6mm/run1.ica
			
			ANAT=${MAINDIR}/${SUBJ}/${SUBJ}_anat_brain.nii.gz
			DATA=${DATAINPUT}/unconfounded_data.nii.gz
			
			#this skip parameter will be useful for the task vs resting comparison
			if [ $SKIP -eq 1 ]; then
				continue
			else
				let N=$N+1
				FUNCFILENAME=${DATA}
				ANATFILENAME=${ANAT}
				#adding checks that should facilitate debugging. check .out file
				if [ ! -e $FUNCFILENAME ]; then
					echo "DOES NOT EXIST: ${FUNCFILENAME}"
				fi
				if [ ! -e $ANATFILENAME ]; then
					echo "DOES NOT EXIST: ${ANATFILENAME}"
				fi
				NN=`printf '%03d' $N` #this pads the numbers with zero
				eval ANAT${NN}=${ANATFILENAME}
				eval DATA${NN}=${FUNCFILENAME}
			fi
			
		done
	done
done


OUTPUT=${OUTDIR}/Resting_IG02_n119
#if [ -d $OUTPUT.gica ]; then
	#rm -rf $OUTPUT.gica
#fi

#REGSTANDARD=${MAINDIR}/MNI_diffeo_brain.nii.gz

TEMPLATEDIR=${EXPERIMENT}/Analysis/TaskData/GroupICA/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@DATA001@'$DATA001'@g' \
-e 's@DATA002@'$DATA002'@g' \
-e 's@DATA003@'$DATA003'@g' \
-e 's@DATA004@'$DATA004'@g' \
-e 's@DATA005@'$DATA005'@g' \
-e 's@DATA006@'$DATA006'@g' \
-e 's@DATA007@'$DATA007'@g' \
-e 's@DATA008@'$DATA008'@g' \
-e 's@DATA009@'$DATA009'@g' \
-e 's@DATA010@'$DATA010'@g' \
-e 's@DATA011@'$DATA011'@g' \
-e 's@DATA012@'$DATA012'@g' \
-e 's@DATA013@'$DATA013'@g' \
-e 's@DATA014@'$DATA014'@g' \
-e 's@DATA015@'$DATA015'@g' \
-e 's@DATA016@'$DATA016'@g' \
-e 's@DATA017@'$DATA017'@g' \
-e 's@DATA018@'$DATA018'@g' \
-e 's@DATA019@'$DATA019'@g' \
-e 's@DATA020@'$DATA020'@g' \
-e 's@DATA021@'$DATA021'@g' \
-e 's@DATA022@'$DATA022'@g' \
-e 's@DATA023@'$DATA023'@g' \
-e 's@DATA024@'$DATA024'@g' \
-e 's@DATA025@'$DATA025'@g' \
-e 's@DATA026@'$DATA026'@g' \
-e 's@DATA027@'$DATA027'@g' \
-e 's@DATA028@'$DATA028'@g' \
-e 's@DATA029@'$DATA029'@g' \
-e 's@DATA030@'$DATA030'@g' \
-e 's@DATA031@'$DATA031'@g' \
-e 's@DATA032@'$DATA032'@g' \
-e 's@DATA033@'$DATA033'@g' \
-e 's@DATA034@'$DATA034'@g' \
-e 's@DATA035@'$DATA035'@g' \
-e 's@DATA036@'$DATA036'@g' \
-e 's@DATA037@'$DATA037'@g' \
-e 's@DATA038@'$DATA038'@g' \
-e 's@DATA039@'$DATA039'@g' \
-e 's@DATA040@'$DATA040'@g' \
-e 's@DATA041@'$DATA041'@g' \
-e 's@DATA042@'$DATA042'@g' \
-e 's@DATA043@'$DATA043'@g' \
-e 's@DATA044@'$DATA044'@g' \
-e 's@DATA045@'$DATA045'@g' \
-e 's@DATA046@'$DATA046'@g' \
-e 's@DATA047@'$DATA047'@g' \
-e 's@DATA048@'$DATA048'@g' \
-e 's@DATA049@'$DATA049'@g' \
-e 's@DATA050@'$DATA050'@g' \
-e 's@DATA051@'$DATA051'@g' \
-e 's@DATA052@'$DATA052'@g' \
-e 's@DATA053@'$DATA053'@g' \
-e 's@DATA054@'$DATA054'@g' \
-e 's@DATA055@'$DATA055'@g' \
-e 's@DATA056@'$DATA056'@g' \
-e 's@DATA057@'$DATA057'@g' \
-e 's@DATA058@'$DATA058'@g' \
-e 's@DATA059@'$DATA059'@g' \
-e 's@DATA060@'$DATA060'@g' \
-e 's@DATA061@'$DATA061'@g' \
-e 's@DATA062@'$DATA062'@g' \
-e 's@DATA063@'$DATA063'@g' \
-e 's@DATA064@'$DATA064'@g' \
-e 's@DATA065@'$DATA065'@g' \
-e 's@DATA066@'$DATA066'@g' \
-e 's@DATA067@'$DATA067'@g' \
-e 's@DATA068@'$DATA068'@g' \
-e 's@DATA069@'$DATA069'@g' \
-e 's@DATA070@'$DATA070'@g' \
-e 's@DATA071@'$DATA071'@g' \
-e 's@DATA072@'$DATA072'@g' \
-e 's@DATA073@'$DATA073'@g' \
-e 's@DATA074@'$DATA074'@g' \
-e 's@DATA075@'$DATA075'@g' \
-e 's@DATA076@'$DATA076'@g' \
-e 's@DATA077@'$DATA077'@g' \
-e 's@DATA078@'$DATA078'@g' \
-e 's@DATA079@'$DATA079'@g' \
-e 's@DATA080@'$DATA080'@g' \
-e 's@DATA081@'$DATA081'@g' \
-e 's@DATA082@'$DATA082'@g' \
-e 's@DATA083@'$DATA083'@g' \
-e 's@DATA084@'$DATA084'@g' \
-e 's@DATA085@'$DATA085'@g' \
-e 's@DATA086@'$DATA086'@g' \
-e 's@DATA087@'$DATA087'@g' \
-e 's@DATA088@'$DATA088'@g' \
-e 's@DATA089@'$DATA089'@g' \
-e 's@DATA090@'$DATA090'@g' \
-e 's@DATA091@'$DATA091'@g' \
-e 's@DATA092@'$DATA092'@g' \
-e 's@DATA093@'$DATA093'@g' \
-e 's@DATA094@'$DATA094'@g' \
-e 's@DATA095@'$DATA095'@g' \
-e 's@DATA096@'$DATA096'@g' \
-e 's@DATA097@'$DATA097'@g' \
-e 's@DATA098@'$DATA098'@g' \
-e 's@DATA099@'$DATA099'@g' \
-e 's@DATA100@'$DATA100'@g' \
-e 's@DATA101@'$DATA101'@g' \
-e 's@DATA102@'$DATA102'@g' \
-e 's@DATA103@'$DATA103'@g' \
-e 's@DATA104@'$DATA104'@g' \
-e 's@DATA105@'$DATA105'@g' \
-e 's@DATA106@'$DATA106'@g' \
-e 's@DATA107@'$DATA107'@g' \
-e 's@DATA108@'$DATA108'@g' \
-e 's@DATA109@'$DATA109'@g' \
-e 's@DATA110@'$DATA110'@g' \
-e 's@DATA111@'$DATA111'@g' \
-e 's@DATA112@'$DATA112'@g' \
-e 's@DATA113@'$DATA113'@g' \
-e 's@DATA114@'$DATA114'@g' \
-e 's@DATA115@'$DATA115'@g' \
-e 's@DATA116@'$DATA116'@g' \
-e 's@DATA117@'$DATA117'@g' \
-e 's@DATA118@'$DATA118'@g' \
-e 's@DATA119@'$DATA119'@g' \
-e 's@ANAT001@'$ANAT001'@g' \
-e 's@ANAT002@'$ANAT002'@g' \
-e 's@ANAT003@'$ANAT003'@g' \
-e 's@ANAT004@'$ANAT004'@g' \
-e 's@ANAT005@'$ANAT005'@g' \
-e 's@ANAT006@'$ANAT006'@g' \
-e 's@ANAT007@'$ANAT007'@g' \
-e 's@ANAT008@'$ANAT008'@g' \
-e 's@ANAT009@'$ANAT009'@g' \
-e 's@ANAT010@'$ANAT010'@g' \
-e 's@ANAT011@'$ANAT011'@g' \
-e 's@ANAT012@'$ANAT012'@g' \
-e 's@ANAT013@'$ANAT013'@g' \
-e 's@ANAT014@'$ANAT014'@g' \
-e 's@ANAT015@'$ANAT015'@g' \
-e 's@ANAT016@'$ANAT016'@g' \
-e 's@ANAT017@'$ANAT017'@g' \
-e 's@ANAT018@'$ANAT018'@g' \
-e 's@ANAT019@'$ANAT019'@g' \
-e 's@ANAT020@'$ANAT020'@g' \
-e 's@ANAT021@'$ANAT021'@g' \
-e 's@ANAT022@'$ANAT022'@g' \
-e 's@ANAT023@'$ANAT023'@g' \
-e 's@ANAT024@'$ANAT024'@g' \
-e 's@ANAT025@'$ANAT025'@g' \
-e 's@ANAT026@'$ANAT026'@g' \
-e 's@ANAT027@'$ANAT027'@g' \
-e 's@ANAT028@'$ANAT028'@g' \
-e 's@ANAT029@'$ANAT029'@g' \
-e 's@ANAT030@'$ANAT030'@g' \
-e 's@ANAT031@'$ANAT031'@g' \
-e 's@ANAT032@'$ANAT032'@g' \
-e 's@ANAT033@'$ANAT033'@g' \
-e 's@ANAT034@'$ANAT034'@g' \
-e 's@ANAT035@'$ANAT035'@g' \
-e 's@ANAT036@'$ANAT036'@g' \
-e 's@ANAT037@'$ANAT037'@g' \
-e 's@ANAT038@'$ANAT038'@g' \
-e 's@ANAT039@'$ANAT039'@g' \
-e 's@ANAT040@'$ANAT040'@g' \
-e 's@ANAT041@'$ANAT041'@g' \
-e 's@ANAT042@'$ANAT042'@g' \
-e 's@ANAT043@'$ANAT043'@g' \
-e 's@ANAT044@'$ANAT044'@g' \
-e 's@ANAT045@'$ANAT045'@g' \
-e 's@ANAT046@'$ANAT046'@g' \
-e 's@ANAT047@'$ANAT047'@g' \
-e 's@ANAT048@'$ANAT048'@g' \
-e 's@ANAT049@'$ANAT049'@g' \
-e 's@ANAT050@'$ANAT050'@g' \
-e 's@ANAT051@'$ANAT051'@g' \
-e 's@ANAT052@'$ANAT052'@g' \
-e 's@ANAT053@'$ANAT053'@g' \
-e 's@ANAT054@'$ANAT054'@g' \
-e 's@ANAT055@'$ANAT055'@g' \
-e 's@ANAT056@'$ANAT056'@g' \
-e 's@ANAT057@'$ANAT057'@g' \
-e 's@ANAT058@'$ANAT058'@g' \
-e 's@ANAT059@'$ANAT059'@g' \
-e 's@ANAT060@'$ANAT060'@g' \
-e 's@ANAT061@'$ANAT061'@g' \
-e 's@ANAT062@'$ANAT062'@g' \
-e 's@ANAT063@'$ANAT063'@g' \
-e 's@ANAT064@'$ANAT064'@g' \
-e 's@ANAT065@'$ANAT065'@g' \
-e 's@ANAT066@'$ANAT066'@g' \
-e 's@ANAT067@'$ANAT067'@g' \
-e 's@ANAT068@'$ANAT068'@g' \
-e 's@ANAT069@'$ANAT069'@g' \
-e 's@ANAT070@'$ANAT070'@g' \
-e 's@ANAT071@'$ANAT071'@g' \
-e 's@ANAT072@'$ANAT072'@g' \
-e 's@ANAT073@'$ANAT073'@g' \
-e 's@ANAT074@'$ANAT074'@g' \
-e 's@ANAT075@'$ANAT075'@g' \
-e 's@ANAT076@'$ANAT076'@g' \
-e 's@ANAT077@'$ANAT077'@g' \
-e 's@ANAT078@'$ANAT078'@g' \
-e 's@ANAT079@'$ANAT079'@g' \
-e 's@ANAT080@'$ANAT080'@g' \
-e 's@ANAT081@'$ANAT081'@g' \
-e 's@ANAT082@'$ANAT082'@g' \
-e 's@ANAT083@'$ANAT083'@g' \
-e 's@ANAT084@'$ANAT084'@g' \
-e 's@ANAT085@'$ANAT085'@g' \
-e 's@ANAT086@'$ANAT086'@g' \
-e 's@ANAT087@'$ANAT087'@g' \
-e 's@ANAT088@'$ANAT088'@g' \
-e 's@ANAT089@'$ANAT089'@g' \
-e 's@ANAT090@'$ANAT090'@g' \
-e 's@ANAT091@'$ANAT091'@g' \
-e 's@ANAT092@'$ANAT092'@g' \
-e 's@ANAT093@'$ANAT093'@g' \
-e 's@ANAT094@'$ANAT094'@g' \
-e 's@ANAT095@'$ANAT095'@g' \
-e 's@ANAT096@'$ANAT096'@g' \
-e 's@ANAT097@'$ANAT097'@g' \
-e 's@ANAT098@'$ANAT098'@g' \
-e 's@ANAT099@'$ANAT099'@g' \
-e 's@ANAT100@'$ANAT100'@g' \
-e 's@ANAT101@'$ANAT101'@g' \
-e 's@ANAT102@'$ANAT102'@g' \
-e 's@ANAT103@'$ANAT103'@g' \
-e 's@ANAT104@'$ANAT104'@g' \
-e 's@ANAT105@'$ANAT105'@g' \
-e 's@ANAT106@'$ANAT106'@g' \
-e 's@ANAT107@'$ANAT107'@g' \
-e 's@ANAT108@'$ANAT108'@g' \
-e 's@ANAT109@'$ANAT109'@g' \
-e 's@ANAT110@'$ANAT110'@g' \
-e 's@ANAT111@'$ANAT111'@g' \
-e 's@ANAT112@'$ANAT112'@g' \
-e 's@ANAT113@'$ANAT113'@g' \
-e 's@ANAT114@'$ANAT114'@g' \
-e 's@ANAT115@'$ANAT115'@g' \
-e 's@ANAT116@'$ANAT116'@g' \
-e 's@ANAT117@'$ANAT117'@g' \
-e 's@ANAT118@'$ANAT118'@g' \
-e 's@ANAT119@'$ANAT119'@g' \
<Imagene_02_ICA_n119_IC.fsf> ${OUTDIR}/Imagene_02_ICA_n119_IC.fsf

feat ${OUTDIR}/Imagene_02_ICA_n119_IC.fsf


OUTLOG=$OUTDIR/Logs
mkdir -p $OUTLOG

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
