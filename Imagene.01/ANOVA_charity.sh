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

#Vinod:  L:\Imagene.01\Analysis\Framing\FSL\47729\47729_model3_slbycope\cope9.gfeat\cope1.feat
#thats an example of second level output.. u shud use copes 9, 10, 11 and 12 in order.. so all 61 cope9s, #then 61 cope10s and so on.
# Sent at 3:13 PM on Thursday
# me:  13, 14, 15, 16 is charity

MAINDIR=${EXPERIMENT}/Analysis/Framing/FSL
OUTPUT=${MAINDIR}/Level3/Model3bycope/ANOVA_charity

N=0
for COPE in 13 14 15 16; do 
for SUBJ in 47729 47731 47734 47735 47748 47752 47851 47863 47878 47885 47917 47921 47945 47977 48012 48061 48066 48090 48097 48100 48103 48112 48123 48129 48145 48150 48152 48156 48158 48160 48165 48167 48176 48179 48184 48187 48189 48193 48196 48197 48204 48206 48232 48271 48281 48288 48297 48301 48309 48312 48321 48326 48327 48330 48335 48337 48339 48344 48349 48350 48351; do

		let N=$N+1
		FILENAME=${MAINDIR}/${SUBJ}/${SUBJ}_model3_slbycope/cope${COPE}.gfeat/cope1.feat/stats/cope1.nii.gz
		if [ $N -lt 10 ]; then
			eval INPUT00${N}=${FILENAME}
		elif [ $N -lt 100 -a $N -gt 9 ]; then
			eval INPUT0${N}=${FILENAME}
		elif [ $N -gt 99 ]; then
			eval INPUT${N}=${FILENAME}
		fi
done
done

# Y:\Huettel\Imagene.01\Analysis\Framing\Templates
TEMPLATEDIR=${EXPERIMENT}/Analysis/Framing/Templates
cd ${TEMPLATEDIR}
sed -e 's@OUTPUT@'$OUTPUT'@g' \
-e 's@INPUT001@'$INPUT001'@g' \
-e 's@INPUT002@'$INPUT002'@g' \
-e 's@INPUT003@'$INPUT003'@g' \
-e 's@INPUT004@'$INPUT004'@g' \
-e 's@INPUT005@'$INPUT005'@g' \
-e 's@INPUT006@'$INPUT006'@g' \
-e 's@INPUT007@'$INPUT007'@g' \
-e 's@INPUT008@'$INPUT008'@g' \
-e 's@INPUT009@'$INPUT009'@g' \
-e 's@INPUT010@'$INPUT010'@g' \
-e 's@INPUT011@'$INPUT011'@g' \
-e 's@INPUT012@'$INPUT012'@g' \
-e 's@INPUT013@'$INPUT013'@g' \
-e 's@INPUT014@'$INPUT014'@g' \
-e 's@INPUT015@'$INPUT015'@g' \
-e 's@INPUT016@'$INPUT016'@g' \
-e 's@INPUT017@'$INPUT017'@g' \
-e 's@INPUT018@'$INPUT018'@g' \
-e 's@INPUT019@'$INPUT019'@g' \
-e 's@INPUT020@'$INPUT020'@g' \
-e 's@INPUT021@'$INPUT021'@g' \
-e 's@INPUT022@'$INPUT022'@g' \
-e 's@INPUT023@'$INPUT023'@g' \
-e 's@INPUT024@'$INPUT024'@g' \
-e 's@INPUT025@'$INPUT025'@g' \
-e 's@INPUT026@'$INPUT026'@g' \
-e 's@INPUT027@'$INPUT027'@g' \
-e 's@INPUT028@'$INPUT028'@g' \
-e 's@INPUT029@'$INPUT029'@g' \
-e 's@INPUT030@'$INPUT030'@g' \
-e 's@INPUT031@'$INPUT031'@g' \
-e 's@INPUT032@'$INPUT032'@g' \
-e 's@INPUT033@'$INPUT033'@g' \
-e 's@INPUT034@'$INPUT034'@g' \
-e 's@INPUT035@'$INPUT035'@g' \
-e 's@INPUT036@'$INPUT036'@g' \
-e 's@INPUT037@'$INPUT037'@g' \
-e 's@INPUT038@'$INPUT038'@g' \
-e 's@INPUT039@'$INPUT039'@g' \
-e 's@INPUT040@'$INPUT040'@g' \
-e 's@INPUT041@'$INPUT041'@g' \
-e 's@INPUT042@'$INPUT042'@g' \
-e 's@INPUT043@'$INPUT043'@g' \
-e 's@INPUT044@'$INPUT044'@g' \
-e 's@INPUT045@'$INPUT045'@g' \
-e 's@INPUT046@'$INPUT046'@g' \
-e 's@INPUT047@'$INPUT047'@g' \
-e 's@INPUT048@'$INPUT048'@g' \
-e 's@INPUT049@'$INPUT049'@g' \
-e 's@INPUT050@'$INPUT050'@g' \
-e 's@INPUT051@'$INPUT051'@g' \
-e 's@INPUT052@'$INPUT052'@g' \
-e 's@INPUT053@'$INPUT053'@g' \
-e 's@INPUT054@'$INPUT054'@g' \
-e 's@INPUT055@'$INPUT055'@g' \
-e 's@INPUT056@'$INPUT056'@g' \
-e 's@INPUT057@'$INPUT057'@g' \
-e 's@INPUT058@'$INPUT058'@g' \
-e 's@INPUT059@'$INPUT059'@g' \
-e 's@INPUT060@'$INPUT060'@g' \
-e 's@INPUT061@'$INPUT061'@g' \
-e 's@INPUT062@'$INPUT062'@g' \
-e 's@INPUT063@'$INPUT063'@g' \
-e 's@INPUT064@'$INPUT064'@g' \
-e 's@INPUT065@'$INPUT065'@g' \
-e 's@INPUT066@'$INPUT066'@g' \
-e 's@INPUT067@'$INPUT067'@g' \
-e 's@INPUT068@'$INPUT068'@g' \
-e 's@INPUT069@'$INPUT069'@g' \
-e 's@INPUT070@'$INPUT070'@g' \
-e 's@INPUT071@'$INPUT071'@g' \
-e 's@INPUT072@'$INPUT072'@g' \
-e 's@INPUT073@'$INPUT073'@g' \
-e 's@INPUT074@'$INPUT074'@g' \
-e 's@INPUT075@'$INPUT075'@g' \
-e 's@INPUT076@'$INPUT076'@g' \
-e 's@INPUT077@'$INPUT077'@g' \
-e 's@INPUT078@'$INPUT078'@g' \
-e 's@INPUT079@'$INPUT079'@g' \
-e 's@INPUT080@'$INPUT080'@g' \
-e 's@INPUT081@'$INPUT081'@g' \
-e 's@INPUT082@'$INPUT082'@g' \
-e 's@INPUT083@'$INPUT083'@g' \
-e 's@INPUT084@'$INPUT084'@g' \
-e 's@INPUT085@'$INPUT085'@g' \
-e 's@INPUT086@'$INPUT086'@g' \
-e 's@INPUT087@'$INPUT087'@g' \
-e 's@INPUT088@'$INPUT088'@g' \
-e 's@INPUT089@'$INPUT089'@g' \
-e 's@INPUT090@'$INPUT090'@g' \
-e 's@INPUT091@'$INPUT091'@g' \
-e 's@INPUT092@'$INPUT092'@g' \
-e 's@INPUT093@'$INPUT093'@g' \
-e 's@INPUT094@'$INPUT094'@g' \
-e 's@INPUT095@'$INPUT095'@g' \
-e 's@INPUT096@'$INPUT096'@g' \
-e 's@INPUT097@'$INPUT097'@g' \
-e 's@INPUT098@'$INPUT098'@g' \
-e 's@INPUT099@'$INPUT099'@g' \
-e 's@INPUT100@'$INPUT100'@g' \
-e 's@INPUT101@'$INPUT101'@g' \
-e 's@INPUT102@'$INPUT102'@g' \
-e 's@INPUT103@'$INPUT103'@g' \
-e 's@INPUT104@'$INPUT104'@g' \
-e 's@INPUT105@'$INPUT105'@g' \
-e 's@INPUT106@'$INPUT106'@g' \
-e 's@INPUT107@'$INPUT107'@g' \
-e 's@INPUT108@'$INPUT108'@g' \
-e 's@INPUT109@'$INPUT109'@g' \
-e 's@INPUT110@'$INPUT110'@g' \
-e 's@INPUT111@'$INPUT111'@g' \
-e 's@INPUT112@'$INPUT112'@g' \
-e 's@INPUT113@'$INPUT113'@g' \
-e 's@INPUT114@'$INPUT114'@g' \
-e 's@INPUT115@'$INPUT115'@g' \
-e 's@INPUT116@'$INPUT116'@g' \
-e 's@INPUT117@'$INPUT117'@g' \
-e 's@INPUT118@'$INPUT118'@g' \
-e 's@INPUT119@'$INPUT119'@g' \
-e 's@INPUT120@'$INPUT120'@g' \
-e 's@INPUT121@'$INPUT121'@g' \
-e 's@INPUT122@'$INPUT122'@g' \
-e 's@INPUT123@'$INPUT123'@g' \
-e 's@INPUT124@'$INPUT124'@g' \
-e 's@INPUT125@'$INPUT125'@g' \
-e 's@INPUT126@'$INPUT126'@g' \
-e 's@INPUT127@'$INPUT127'@g' \
-e 's@INPUT128@'$INPUT128'@g' \
-e 's@INPUT129@'$INPUT129'@g' \
-e 's@INPUT130@'$INPUT130'@g' \
-e 's@INPUT131@'$INPUT131'@g' \
-e 's@INPUT132@'$INPUT132'@g' \
-e 's@INPUT133@'$INPUT133'@g' \
-e 's@INPUT134@'$INPUT134'@g' \
-e 's@INPUT135@'$INPUT135'@g' \
-e 's@INPUT136@'$INPUT136'@g' \
-e 's@INPUT137@'$INPUT137'@g' \
-e 's@INPUT138@'$INPUT138'@g' \
-e 's@INPUT139@'$INPUT139'@g' \
-e 's@INPUT140@'$INPUT140'@g' \
-e 's@INPUT141@'$INPUT141'@g' \
-e 's@INPUT142@'$INPUT142'@g' \
-e 's@INPUT143@'$INPUT143'@g' \
-e 's@INPUT144@'$INPUT144'@g' \
-e 's@INPUT145@'$INPUT145'@g' \
-e 's@INPUT146@'$INPUT146'@g' \
-e 's@INPUT147@'$INPUT147'@g' \
-e 's@INPUT148@'$INPUT148'@g' \
-e 's@INPUT149@'$INPUT149'@g' \
-e 's@INPUT150@'$INPUT150'@g' \
-e 's@INPUT151@'$INPUT151'@g' \
-e 's@INPUT152@'$INPUT152'@g' \
-e 's@INPUT153@'$INPUT153'@g' \
-e 's@INPUT154@'$INPUT154'@g' \
-e 's@INPUT155@'$INPUT155'@g' \
-e 's@INPUT156@'$INPUT156'@g' \
-e 's@INPUT157@'$INPUT157'@g' \
-e 's@INPUT158@'$INPUT158'@g' \
-e 's@INPUT159@'$INPUT159'@g' \
-e 's@INPUT160@'$INPUT160'@g' \
-e 's@INPUT161@'$INPUT161'@g' \
-e 's@INPUT162@'$INPUT162'@g' \
-e 's@INPUT163@'$INPUT163'@g' \
-e 's@INPUT164@'$INPUT164'@g' \
-e 's@INPUT165@'$INPUT165'@g' \
-e 's@INPUT166@'$INPUT166'@g' \
-e 's@INPUT167@'$INPUT167'@g' \
-e 's@INPUT168@'$INPUT168'@g' \
-e 's@INPUT169@'$INPUT169'@g' \
-e 's@INPUT170@'$INPUT170'@g' \
-e 's@INPUT171@'$INPUT171'@g' \
-e 's@INPUT172@'$INPUT172'@g' \
-e 's@INPUT173@'$INPUT173'@g' \
-e 's@INPUT174@'$INPUT174'@g' \
-e 's@INPUT175@'$INPUT175'@g' \
-e 's@INPUT176@'$INPUT176'@g' \
-e 's@INPUT177@'$INPUT177'@g' \
-e 's@INPUT178@'$INPUT178'@g' \
-e 's@INPUT179@'$INPUT179'@g' \
-e 's@INPUT180@'$INPUT180'@g' \
-e 's@INPUT181@'$INPUT181'@g' \
-e 's@INPUT182@'$INPUT182'@g' \
-e 's@INPUT183@'$INPUT183'@g' \
-e 's@INPUT184@'$INPUT184'@g' \
-e 's@INPUT185@'$INPUT185'@g' \
-e 's@INPUT186@'$INPUT186'@g' \
-e 's@INPUT187@'$INPUT187'@g' \
-e 's@INPUT188@'$INPUT188'@g' \
-e 's@INPUT189@'$INPUT189'@g' \
-e 's@INPUT190@'$INPUT190'@g' \
-e 's@INPUT191@'$INPUT191'@g' \
-e 's@INPUT192@'$INPUT192'@g' \
-e 's@INPUT193@'$INPUT193'@g' \
-e 's@INPUT194@'$INPUT194'@g' \
-e 's@INPUT195@'$INPUT195'@g' \
-e 's@INPUT196@'$INPUT196'@g' \
-e 's@INPUT197@'$INPUT197'@g' \
-e 's@INPUT198@'$INPUT198'@g' \
-e 's@INPUT199@'$INPUT199'@g' \
-e 's@INPUT200@'$INPUT200'@g' \
-e 's@INPUT201@'$INPUT201'@g' \
-e 's@INPUT202@'$INPUT202'@g' \
-e 's@INPUT203@'$INPUT203'@g' \
-e 's@INPUT204@'$INPUT204'@g' \
-e 's@INPUT205@'$INPUT205'@g' \
-e 's@INPUT206@'$INPUT206'@g' \
-e 's@INPUT207@'$INPUT207'@g' \
-e 's@INPUT208@'$INPUT208'@g' \
-e 's@INPUT209@'$INPUT209'@g' \
-e 's@INPUT210@'$INPUT210'@g' \
-e 's@INPUT211@'$INPUT211'@g' \
-e 's@INPUT212@'$INPUT212'@g' \
-e 's@INPUT213@'$INPUT213'@g' \
-e 's@INPUT214@'$INPUT214'@g' \
-e 's@INPUT215@'$INPUT215'@g' \
-e 's@INPUT216@'$INPUT216'@g' \
-e 's@INPUT217@'$INPUT217'@g' \
-e 's@INPUT218@'$INPUT218'@g' \
-e 's@INPUT219@'$INPUT219'@g' \
-e 's@INPUT220@'$INPUT220'@g' \
-e 's@INPUT221@'$INPUT221'@g' \
-e 's@INPUT222@'$INPUT222'@g' \
-e 's@INPUT223@'$INPUT223'@g' \
-e 's@INPUT224@'$INPUT224'@g' \
-e 's@INPUT225@'$INPUT225'@g' \
-e 's@INPUT226@'$INPUT226'@g' \
-e 's@INPUT227@'$INPUT227'@g' \
-e 's@INPUT228@'$INPUT228'@g' \
-e 's@INPUT229@'$INPUT229'@g' \
-e 's@INPUT230@'$INPUT230'@g' \
-e 's@INPUT231@'$INPUT231'@g' \
-e 's@INPUT232@'$INPUT232'@g' \
-e 's@INPUT233@'$INPUT233'@g' \
-e 's@INPUT234@'$INPUT234'@g' \
-e 's@INPUT235@'$INPUT235'@g' \
-e 's@INPUT236@'$INPUT236'@g' \
-e 's@INPUT237@'$INPUT237'@g' \
-e 's@INPUT238@'$INPUT238'@g' \
-e 's@INPUT239@'$INPUT239'@g' \
-e 's@INPUT240@'$INPUT240'@g' \
-e 's@INPUT241@'$INPUT241'@g' \
-e 's@INPUT242@'$INPUT242'@g' \
-e 's@INPUT243@'$INPUT243'@g' \
-e 's@INPUT244@'$INPUT244'@g' \
<template_model3_2wayanova.fsf> ${MAINDIR}/Level3/Model3bycope/ANOVA_charity.fsf

feat ${MAINDIR}/Level3/Model3bycope/ANOVA_charity.fsf
cd $OUTPUT.gfeat
rm -f filtered_func_data.nii.gz
rm -f stats/res4d.nii.gz
rm -f var_filtered_func_data.nii.gz



OUTDIR=${MAINDIR}/Level3/Model3bycope/

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
