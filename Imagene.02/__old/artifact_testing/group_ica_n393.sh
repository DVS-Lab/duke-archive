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

SMOOTH=6
GO=1

N=0
for SUBJ in 10156 10168 10181 10199 10255 10256 10264 10265 10279 10280 10281 10286 10287 10294 10303 10304 10305 10306 10314 10315 10335 10350 10351 10352 10358 10359 10360 10387 10414 10415 10416 10424 10425 10426 10471 10472 10474 10481 10482 10483 10512 10515 10521 10523 10524 10525; do

##removed: "10169" because all data is in 10168
#subnums = [ "10264", "10265" ]

for TASK in "Framing" "MID" "Risk" "Resting"; do

if [ "$TASK" == "Resting" ]; then
	RUNS=1
else
	RUNS=3
fi

for RUN in `seq $RUNS`; do


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




MAINDIR=${EXPERIMENT}/Analysis/TaskData
SUBJDIR=${MAINDIR}/${SUBJ}
MAINOUTPUT=${SUBJDIR}/${TASK}/PreStats/Smooth_${SMOOTH}mm

OUTPUTREAL=${MAINOUTPUT}/run${RUN}.feat


ANAT=${SUBJDIR}/${SUBJ}_anat_brain.nii.gz
DATA=${OUTPUTREAL}/new_filtered_func_data.nii.gz
DATA2=${OUTPUTREAL}/truncated.nii.gz
fslroi ${DATA} ${DATA2} 0 192

if [ $SKIP -eq 1 ]; then
	continue
else
	let N=$N+1
	FUNCFILENAME=${DATA2}
	ANATFILENAME=${ANAT}
	NN=`printf '%03d' $N` #this pads the numbers with zero
	eval ANAT${NN}=${ANATFILENAME}
	eval DATA${NN}=${FUNCFILENAME}
fi

done
done
done

OUTPUT=${MAINDIR}/all_data2

TEMPLATEDIR=${EXPERIMENT}/Analysis/TaskData/Templates
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
-e 's@DATA120@'$DATA120'@g' \
-e 's@DATA121@'$DATA121'@g' \
-e 's@DATA122@'$DATA122'@g' \
-e 's@DATA123@'$DATA123'@g' \
-e 's@DATA124@'$DATA124'@g' \
-e 's@DATA125@'$DATA125'@g' \
-e 's@DATA126@'$DATA126'@g' \
-e 's@DATA127@'$DATA127'@g' \
-e 's@DATA128@'$DATA128'@g' \
-e 's@DATA129@'$DATA129'@g' \
-e 's@DATA130@'$DATA130'@g' \
-e 's@DATA131@'$DATA131'@g' \
-e 's@DATA132@'$DATA132'@g' \
-e 's@DATA133@'$DATA133'@g' \
-e 's@DATA134@'$DATA134'@g' \
-e 's@DATA135@'$DATA135'@g' \
-e 's@DATA136@'$DATA136'@g' \
-e 's@DATA137@'$DATA137'@g' \
-e 's@DATA138@'$DATA138'@g' \
-e 's@DATA139@'$DATA139'@g' \
-e 's@DATA140@'$DATA140'@g' \
-e 's@DATA141@'$DATA141'@g' \
-e 's@DATA142@'$DATA142'@g' \
-e 's@DATA143@'$DATA143'@g' \
-e 's@DATA144@'$DATA144'@g' \
-e 's@DATA145@'$DATA145'@g' \
-e 's@DATA146@'$DATA146'@g' \
-e 's@DATA147@'$DATA147'@g' \
-e 's@DATA148@'$DATA148'@g' \
-e 's@DATA149@'$DATA149'@g' \
-e 's@DATA150@'$DATA150'@g' \
-e 's@DATA151@'$DATA151'@g' \
-e 's@DATA152@'$DATA152'@g' \
-e 's@DATA153@'$DATA153'@g' \
-e 's@DATA154@'$DATA154'@g' \
-e 's@DATA155@'$DATA155'@g' \
-e 's@DATA156@'$DATA156'@g' \
-e 's@DATA157@'$DATA157'@g' \
-e 's@DATA158@'$DATA158'@g' \
-e 's@DATA159@'$DATA159'@g' \
-e 's@DATA160@'$DATA160'@g' \
-e 's@DATA161@'$DATA161'@g' \
-e 's@DATA162@'$DATA162'@g' \
-e 's@DATA163@'$DATA163'@g' \
-e 's@DATA164@'$DATA164'@g' \
-e 's@DATA165@'$DATA165'@g' \
-e 's@DATA166@'$DATA166'@g' \
-e 's@DATA167@'$DATA167'@g' \
-e 's@DATA168@'$DATA168'@g' \
-e 's@DATA169@'$DATA169'@g' \
-e 's@DATA170@'$DATA170'@g' \
-e 's@DATA171@'$DATA171'@g' \
-e 's@DATA172@'$DATA172'@g' \
-e 's@DATA173@'$DATA173'@g' \
-e 's@DATA174@'$DATA174'@g' \
-e 's@DATA175@'$DATA175'@g' \
-e 's@DATA176@'$DATA176'@g' \
-e 's@DATA177@'$DATA177'@g' \
-e 's@DATA178@'$DATA178'@g' \
-e 's@DATA179@'$DATA179'@g' \
-e 's@DATA180@'$DATA180'@g' \
-e 's@DATA181@'$DATA181'@g' \
-e 's@DATA182@'$DATA182'@g' \
-e 's@DATA183@'$DATA183'@g' \
-e 's@DATA184@'$DATA184'@g' \
-e 's@DATA185@'$DATA185'@g' \
-e 's@DATA186@'$DATA186'@g' \
-e 's@DATA187@'$DATA187'@g' \
-e 's@DATA188@'$DATA188'@g' \
-e 's@DATA189@'$DATA189'@g' \
-e 's@DATA190@'$DATA190'@g' \
-e 's@DATA191@'$DATA191'@g' \
-e 's@DATA192@'$DATA192'@g' \
-e 's@DATA193@'$DATA193'@g' \
-e 's@DATA194@'$DATA194'@g' \
-e 's@DATA195@'$DATA195'@g' \
-e 's@DATA196@'$DATA196'@g' \
-e 's@DATA197@'$DATA197'@g' \
-e 's@DATA198@'$DATA198'@g' \
-e 's@DATA199@'$DATA199'@g' \
-e 's@DATA200@'$DATA200'@g' \
-e 's@DATA201@'$DATA201'@g' \
-e 's@DATA202@'$DATA202'@g' \
-e 's@DATA203@'$DATA203'@g' \
-e 's@DATA204@'$DATA204'@g' \
-e 's@DATA205@'$DATA205'@g' \
-e 's@DATA206@'$DATA206'@g' \
-e 's@DATA207@'$DATA207'@g' \
-e 's@DATA208@'$DATA208'@g' \
-e 's@DATA209@'$DATA209'@g' \
-e 's@DATA210@'$DATA210'@g' \
-e 's@DATA211@'$DATA211'@g' \
-e 's@DATA212@'$DATA212'@g' \
-e 's@DATA213@'$DATA213'@g' \
-e 's@DATA214@'$DATA214'@g' \
-e 's@DATA215@'$DATA215'@g' \
-e 's@DATA216@'$DATA216'@g' \
-e 's@DATA217@'$DATA217'@g' \
-e 's@DATA218@'$DATA218'@g' \
-e 's@DATA219@'$DATA219'@g' \
-e 's@DATA220@'$DATA220'@g' \
-e 's@DATA221@'$DATA221'@g' \
-e 's@DATA222@'$DATA222'@g' \
-e 's@DATA223@'$DATA223'@g' \
-e 's@DATA224@'$DATA224'@g' \
-e 's@DATA225@'$DATA225'@g' \
-e 's@DATA226@'$DATA226'@g' \
-e 's@DATA227@'$DATA227'@g' \
-e 's@DATA228@'$DATA228'@g' \
-e 's@DATA229@'$DATA229'@g' \
-e 's@DATA230@'$DATA230'@g' \
-e 's@DATA231@'$DATA231'@g' \
-e 's@DATA232@'$DATA232'@g' \
-e 's@DATA233@'$DATA233'@g' \
-e 's@DATA234@'$DATA234'@g' \
-e 's@DATA235@'$DATA235'@g' \
-e 's@DATA236@'$DATA236'@g' \
-e 's@DATA237@'$DATA237'@g' \
-e 's@DATA238@'$DATA238'@g' \
-e 's@DATA239@'$DATA239'@g' \
-e 's@DATA240@'$DATA240'@g' \
-e 's@DATA241@'$DATA241'@g' \
-e 's@DATA242@'$DATA242'@g' \
-e 's@DATA243@'$DATA243'@g' \
-e 's@DATA244@'$DATA244'@g' \
-e 's@DATA245@'$DATA245'@g' \
-e 's@DATA246@'$DATA246'@g' \
-e 's@DATA247@'$DATA247'@g' \
-e 's@DATA248@'$DATA248'@g' \
-e 's@DATA249@'$DATA249'@g' \
-e 's@DATA250@'$DATA250'@g' \
-e 's@DATA251@'$DATA251'@g' \
-e 's@DATA252@'$DATA252'@g' \
-e 's@DATA253@'$DATA253'@g' \
-e 's@DATA254@'$DATA254'@g' \
-e 's@DATA255@'$DATA255'@g' \
-e 's@DATA256@'$DATA256'@g' \
-e 's@DATA257@'$DATA257'@g' \
-e 's@DATA258@'$DATA258'@g' \
-e 's@DATA259@'$DATA259'@g' \
-e 's@DATA260@'$DATA260'@g' \
-e 's@DATA261@'$DATA261'@g' \
-e 's@DATA262@'$DATA262'@g' \
-e 's@DATA263@'$DATA263'@g' \
-e 's@DATA264@'$DATA264'@g' \
-e 's@DATA265@'$DATA265'@g' \
-e 's@DATA266@'$DATA266'@g' \
-e 's@DATA267@'$DATA267'@g' \
-e 's@DATA268@'$DATA268'@g' \
-e 's@DATA269@'$DATA269'@g' \
-e 's@DATA270@'$DATA270'@g' \
-e 's@DATA271@'$DATA271'@g' \
-e 's@DATA272@'$DATA272'@g' \
-e 's@DATA273@'$DATA273'@g' \
-e 's@DATA274@'$DATA274'@g' \
-e 's@DATA275@'$DATA275'@g' \
-e 's@DATA276@'$DATA276'@g' \
-e 's@DATA277@'$DATA277'@g' \
-e 's@DATA278@'$DATA278'@g' \
-e 's@DATA279@'$DATA279'@g' \
-e 's@DATA280@'$DATA280'@g' \
-e 's@DATA281@'$DATA281'@g' \
-e 's@DATA282@'$DATA282'@g' \
-e 's@DATA283@'$DATA283'@g' \
-e 's@DATA284@'$DATA284'@g' \
-e 's@DATA285@'$DATA285'@g' \
-e 's@DATA286@'$DATA286'@g' \
-e 's@DATA287@'$DATA287'@g' \
-e 's@DATA288@'$DATA288'@g' \
-e 's@DATA289@'$DATA289'@g' \
-e 's@DATA290@'$DATA290'@g' \
-e 's@DATA291@'$DATA291'@g' \
-e 's@DATA292@'$DATA292'@g' \
-e 's@DATA293@'$DATA293'@g' \
-e 's@DATA294@'$DATA294'@g' \
-e 's@DATA295@'$DATA295'@g' \
-e 's@DATA296@'$DATA296'@g' \
-e 's@DATA297@'$DATA297'@g' \
-e 's@DATA298@'$DATA298'@g' \
-e 's@DATA299@'$DATA299'@g' \
-e 's@DATA300@'$DATA300'@g' \
-e 's@DATA301@'$DATA301'@g' \
-e 's@DATA302@'$DATA302'@g' \
-e 's@DATA303@'$DATA303'@g' \
-e 's@DATA304@'$DATA304'@g' \
-e 's@DATA305@'$DATA305'@g' \
-e 's@DATA306@'$DATA306'@g' \
-e 's@DATA307@'$DATA307'@g' \
-e 's@DATA308@'$DATA308'@g' \
-e 's@DATA309@'$DATA309'@g' \
-e 's@DATA310@'$DATA310'@g' \
-e 's@DATA311@'$DATA311'@g' \
-e 's@DATA312@'$DATA312'@g' \
-e 's@DATA313@'$DATA313'@g' \
-e 's@DATA314@'$DATA314'@g' \
-e 's@DATA315@'$DATA315'@g' \
-e 's@DATA316@'$DATA316'@g' \
-e 's@DATA317@'$DATA317'@g' \
-e 's@DATA318@'$DATA318'@g' \
-e 's@DATA319@'$DATA319'@g' \
-e 's@DATA320@'$DATA320'@g' \
-e 's@DATA321@'$DATA321'@g' \
-e 's@DATA322@'$DATA322'@g' \
-e 's@DATA323@'$DATA323'@g' \
-e 's@DATA324@'$DATA324'@g' \
-e 's@DATA325@'$DATA325'@g' \
-e 's@DATA326@'$DATA326'@g' \
-e 's@DATA327@'$DATA327'@g' \
-e 's@DATA328@'$DATA328'@g' \
-e 's@DATA329@'$DATA329'@g' \
-e 's@DATA330@'$DATA330'@g' \
-e 's@DATA331@'$DATA331'@g' \
-e 's@DATA332@'$DATA332'@g' \
-e 's@DATA333@'$DATA333'@g' \
-e 's@DATA334@'$DATA334'@g' \
-e 's@DATA335@'$DATA335'@g' \
-e 's@DATA336@'$DATA336'@g' \
-e 's@DATA337@'$DATA337'@g' \
-e 's@DATA338@'$DATA338'@g' \
-e 's@DATA339@'$DATA339'@g' \
-e 's@DATA340@'$DATA340'@g' \
-e 's@DATA341@'$DATA341'@g' \
-e 's@DATA342@'$DATA342'@g' \
-e 's@DATA343@'$DATA343'@g' \
-e 's@DATA344@'$DATA344'@g' \
-e 's@DATA345@'$DATA345'@g' \
-e 's@DATA346@'$DATA346'@g' \
-e 's@DATA347@'$DATA347'@g' \
-e 's@DATA348@'$DATA348'@g' \
-e 's@DATA349@'$DATA349'@g' \
-e 's@DATA350@'$DATA350'@g' \
-e 's@DATA351@'$DATA351'@g' \
-e 's@DATA352@'$DATA352'@g' \
-e 's@DATA353@'$DATA353'@g' \
-e 's@DATA354@'$DATA354'@g' \
-e 's@DATA355@'$DATA355'@g' \
-e 's@DATA356@'$DATA356'@g' \
-e 's@DATA357@'$DATA357'@g' \
-e 's@DATA358@'$DATA358'@g' \
-e 's@DATA359@'$DATA359'@g' \
-e 's@DATA360@'$DATA360'@g' \
-e 's@DATA361@'$DATA361'@g' \
-e 's@DATA362@'$DATA362'@g' \
-e 's@DATA363@'$DATA363'@g' \
-e 's@DATA364@'$DATA364'@g' \
-e 's@DATA365@'$DATA365'@g' \
-e 's@DATA366@'$DATA366'@g' \
-e 's@DATA367@'$DATA367'@g' \
-e 's@DATA368@'$DATA368'@g' \
-e 's@DATA369@'$DATA369'@g' \
-e 's@DATA370@'$DATA370'@g' \
-e 's@DATA371@'$DATA371'@g' \
-e 's@DATA372@'$DATA372'@g' \
-e 's@DATA373@'$DATA373'@g' \
-e 's@DATA374@'$DATA374'@g' \
-e 's@DATA375@'$DATA375'@g' \
-e 's@DATA376@'$DATA376'@g' \
-e 's@DATA377@'$DATA377'@g' \
-e 's@DATA378@'$DATA378'@g' \
-e 's@DATA379@'$DATA379'@g' \
-e 's@DATA380@'$DATA380'@g' \
-e 's@DATA381@'$DATA381'@g' \
-e 's@DATA382@'$DATA382'@g' \
-e 's@DATA383@'$DATA383'@g' \
-e 's@DATA384@'$DATA384'@g' \
-e 's@DATA385@'$DATA385'@g' \
-e 's@DATA386@'$DATA386'@g' \
-e 's@DATA387@'$DATA387'@g' \
-e 's@DATA388@'$DATA388'@g' \
-e 's@DATA389@'$DATA389'@g' \
-e 's@DATA390@'$DATA390'@g' \
-e 's@DATA391@'$DATA391'@g' \
-e 's@DATA392@'$DATA392'@g' \
-e 's@DATA393@'$DATA393'@g' \
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
-e 's@ANAT120@'$ANAT120'@g' \
-e 's@ANAT121@'$ANAT121'@g' \
-e 's@ANAT122@'$ANAT122'@g' \
-e 's@ANAT123@'$ANAT123'@g' \
-e 's@ANAT124@'$ANAT124'@g' \
-e 's@ANAT125@'$ANAT125'@g' \
-e 's@ANAT126@'$ANAT126'@g' \
-e 's@ANAT127@'$ANAT127'@g' \
-e 's@ANAT128@'$ANAT128'@g' \
-e 's@ANAT129@'$ANAT129'@g' \
-e 's@ANAT130@'$ANAT130'@g' \
-e 's@ANAT131@'$ANAT131'@g' \
-e 's@ANAT132@'$ANAT132'@g' \
-e 's@ANAT133@'$ANAT133'@g' \
-e 's@ANAT134@'$ANAT134'@g' \
-e 's@ANAT135@'$ANAT135'@g' \
-e 's@ANAT136@'$ANAT136'@g' \
-e 's@ANAT137@'$ANAT137'@g' \
-e 's@ANAT138@'$ANAT138'@g' \
-e 's@ANAT139@'$ANAT139'@g' \
-e 's@ANAT140@'$ANAT140'@g' \
-e 's@ANAT141@'$ANAT141'@g' \
-e 's@ANAT142@'$ANAT142'@g' \
-e 's@ANAT143@'$ANAT143'@g' \
-e 's@ANAT144@'$ANAT144'@g' \
-e 's@ANAT145@'$ANAT145'@g' \
-e 's@ANAT146@'$ANAT146'@g' \
-e 's@ANAT147@'$ANAT147'@g' \
-e 's@ANAT148@'$ANAT148'@g' \
-e 's@ANAT149@'$ANAT149'@g' \
-e 's@ANAT150@'$ANAT150'@g' \
-e 's@ANAT151@'$ANAT151'@g' \
-e 's@ANAT152@'$ANAT152'@g' \
-e 's@ANAT153@'$ANAT153'@g' \
-e 's@ANAT154@'$ANAT154'@g' \
-e 's@ANAT155@'$ANAT155'@g' \
-e 's@ANAT156@'$ANAT156'@g' \
-e 's@ANAT157@'$ANAT157'@g' \
-e 's@ANAT158@'$ANAT158'@g' \
-e 's@ANAT159@'$ANAT159'@g' \
-e 's@ANAT160@'$ANAT160'@g' \
-e 's@ANAT161@'$ANAT161'@g' \
-e 's@ANAT162@'$ANAT162'@g' \
-e 's@ANAT163@'$ANAT163'@g' \
-e 's@ANAT164@'$ANAT164'@g' \
-e 's@ANAT165@'$ANAT165'@g' \
-e 's@ANAT166@'$ANAT166'@g' \
-e 's@ANAT167@'$ANAT167'@g' \
-e 's@ANAT168@'$ANAT168'@g' \
-e 's@ANAT169@'$ANAT169'@g' \
-e 's@ANAT170@'$ANAT170'@g' \
-e 's@ANAT171@'$ANAT171'@g' \
-e 's@ANAT172@'$ANAT172'@g' \
-e 's@ANAT173@'$ANAT173'@g' \
-e 's@ANAT174@'$ANAT174'@g' \
-e 's@ANAT175@'$ANAT175'@g' \
-e 's@ANAT176@'$ANAT176'@g' \
-e 's@ANAT177@'$ANAT177'@g' \
-e 's@ANAT178@'$ANAT178'@g' \
-e 's@ANAT179@'$ANAT179'@g' \
-e 's@ANAT180@'$ANAT180'@g' \
-e 's@ANAT181@'$ANAT181'@g' \
-e 's@ANAT182@'$ANAT182'@g' \
-e 's@ANAT183@'$ANAT183'@g' \
-e 's@ANAT184@'$ANAT184'@g' \
-e 's@ANAT185@'$ANAT185'@g' \
-e 's@ANAT186@'$ANAT186'@g' \
-e 's@ANAT187@'$ANAT187'@g' \
-e 's@ANAT188@'$ANAT188'@g' \
-e 's@ANAT189@'$ANAT189'@g' \
-e 's@ANAT190@'$ANAT190'@g' \
-e 's@ANAT191@'$ANAT191'@g' \
-e 's@ANAT192@'$ANAT192'@g' \
-e 's@ANAT193@'$ANAT193'@g' \
-e 's@ANAT194@'$ANAT194'@g' \
-e 's@ANAT195@'$ANAT195'@g' \
-e 's@ANAT196@'$ANAT196'@g' \
-e 's@ANAT197@'$ANAT197'@g' \
-e 's@ANAT198@'$ANAT198'@g' \
-e 's@ANAT199@'$ANAT199'@g' \
-e 's@ANAT200@'$ANAT200'@g' \
-e 's@ANAT201@'$ANAT201'@g' \
-e 's@ANAT202@'$ANAT202'@g' \
-e 's@ANAT203@'$ANAT203'@g' \
-e 's@ANAT204@'$ANAT204'@g' \
-e 's@ANAT205@'$ANAT205'@g' \
-e 's@ANAT206@'$ANAT206'@g' \
-e 's@ANAT207@'$ANAT207'@g' \
-e 's@ANAT208@'$ANAT208'@g' \
-e 's@ANAT209@'$ANAT209'@g' \
-e 's@ANAT210@'$ANAT210'@g' \
-e 's@ANAT211@'$ANAT211'@g' \
-e 's@ANAT212@'$ANAT212'@g' \
-e 's@ANAT213@'$ANAT213'@g' \
-e 's@ANAT214@'$ANAT214'@g' \
-e 's@ANAT215@'$ANAT215'@g' \
-e 's@ANAT216@'$ANAT216'@g' \
-e 's@ANAT217@'$ANAT217'@g' \
-e 's@ANAT218@'$ANAT218'@g' \
-e 's@ANAT219@'$ANAT219'@g' \
-e 's@ANAT220@'$ANAT220'@g' \
-e 's@ANAT221@'$ANAT221'@g' \
-e 's@ANAT222@'$ANAT222'@g' \
-e 's@ANAT223@'$ANAT223'@g' \
-e 's@ANAT224@'$ANAT224'@g' \
-e 's@ANAT225@'$ANAT225'@g' \
-e 's@ANAT226@'$ANAT226'@g' \
-e 's@ANAT227@'$ANAT227'@g' \
-e 's@ANAT228@'$ANAT228'@g' \
-e 's@ANAT229@'$ANAT229'@g' \
-e 's@ANAT230@'$ANAT230'@g' \
-e 's@ANAT231@'$ANAT231'@g' \
-e 's@ANAT232@'$ANAT232'@g' \
-e 's@ANAT233@'$ANAT233'@g' \
-e 's@ANAT234@'$ANAT234'@g' \
-e 's@ANAT235@'$ANAT235'@g' \
-e 's@ANAT236@'$ANAT236'@g' \
-e 's@ANAT237@'$ANAT237'@g' \
-e 's@ANAT238@'$ANAT238'@g' \
-e 's@ANAT239@'$ANAT239'@g' \
-e 's@ANAT240@'$ANAT240'@g' \
-e 's@ANAT241@'$ANAT241'@g' \
-e 's@ANAT242@'$ANAT242'@g' \
-e 's@ANAT243@'$ANAT243'@g' \
-e 's@ANAT244@'$ANAT244'@g' \
-e 's@ANAT245@'$ANAT245'@g' \
-e 's@ANAT246@'$ANAT246'@g' \
-e 's@ANAT247@'$ANAT247'@g' \
-e 's@ANAT248@'$ANAT248'@g' \
-e 's@ANAT249@'$ANAT249'@g' \
-e 's@ANAT250@'$ANAT250'@g' \
-e 's@ANAT251@'$ANAT251'@g' \
-e 's@ANAT252@'$ANAT252'@g' \
-e 's@ANAT253@'$ANAT253'@g' \
-e 's@ANAT254@'$ANAT254'@g' \
-e 's@ANAT255@'$ANAT255'@g' \
-e 's@ANAT256@'$ANAT256'@g' \
-e 's@ANAT257@'$ANAT257'@g' \
-e 's@ANAT258@'$ANAT258'@g' \
-e 's@ANAT259@'$ANAT259'@g' \
-e 's@ANAT260@'$ANAT260'@g' \
-e 's@ANAT261@'$ANAT261'@g' \
-e 's@ANAT262@'$ANAT262'@g' \
-e 's@ANAT263@'$ANAT263'@g' \
-e 's@ANAT264@'$ANAT264'@g' \
-e 's@ANAT265@'$ANAT265'@g' \
-e 's@ANAT266@'$ANAT266'@g' \
-e 's@ANAT267@'$ANAT267'@g' \
-e 's@ANAT268@'$ANAT268'@g' \
-e 's@ANAT269@'$ANAT269'@g' \
-e 's@ANAT270@'$ANAT270'@g' \
-e 's@ANAT271@'$ANAT271'@g' \
-e 's@ANAT272@'$ANAT272'@g' \
-e 's@ANAT273@'$ANAT273'@g' \
-e 's@ANAT274@'$ANAT274'@g' \
-e 's@ANAT275@'$ANAT275'@g' \
-e 's@ANAT276@'$ANAT276'@g' \
-e 's@ANAT277@'$ANAT277'@g' \
-e 's@ANAT278@'$ANAT278'@g' \
-e 's@ANAT279@'$ANAT279'@g' \
-e 's@ANAT280@'$ANAT280'@g' \
-e 's@ANAT281@'$ANAT281'@g' \
-e 's@ANAT282@'$ANAT282'@g' \
-e 's@ANAT283@'$ANAT283'@g' \
-e 's@ANAT284@'$ANAT284'@g' \
-e 's@ANAT285@'$ANAT285'@g' \
-e 's@ANAT286@'$ANAT286'@g' \
-e 's@ANAT287@'$ANAT287'@g' \
-e 's@ANAT288@'$ANAT288'@g' \
-e 's@ANAT289@'$ANAT289'@g' \
-e 's@ANAT290@'$ANAT290'@g' \
-e 's@ANAT291@'$ANAT291'@g' \
-e 's@ANAT292@'$ANAT292'@g' \
-e 's@ANAT293@'$ANAT293'@g' \
-e 's@ANAT294@'$ANAT294'@g' \
-e 's@ANAT295@'$ANAT295'@g' \
-e 's@ANAT296@'$ANAT296'@g' \
-e 's@ANAT297@'$ANAT297'@g' \
-e 's@ANAT298@'$ANAT298'@g' \
-e 's@ANAT299@'$ANAT299'@g' \
-e 's@ANAT300@'$ANAT300'@g' \
-e 's@ANAT301@'$ANAT301'@g' \
-e 's@ANAT302@'$ANAT302'@g' \
-e 's@ANAT303@'$ANAT303'@g' \
-e 's@ANAT304@'$ANAT304'@g' \
-e 's@ANAT305@'$ANAT305'@g' \
-e 's@ANAT306@'$ANAT306'@g' \
-e 's@ANAT307@'$ANAT307'@g' \
-e 's@ANAT308@'$ANAT308'@g' \
-e 's@ANAT309@'$ANAT309'@g' \
-e 's@ANAT310@'$ANAT310'@g' \
-e 's@ANAT311@'$ANAT311'@g' \
-e 's@ANAT312@'$ANAT312'@g' \
-e 's@ANAT313@'$ANAT313'@g' \
-e 's@ANAT314@'$ANAT314'@g' \
-e 's@ANAT315@'$ANAT315'@g' \
-e 's@ANAT316@'$ANAT316'@g' \
-e 's@ANAT317@'$ANAT317'@g' \
-e 's@ANAT318@'$ANAT318'@g' \
-e 's@ANAT319@'$ANAT319'@g' \
-e 's@ANAT320@'$ANAT320'@g' \
-e 's@ANAT321@'$ANAT321'@g' \
-e 's@ANAT322@'$ANAT322'@g' \
-e 's@ANAT323@'$ANAT323'@g' \
-e 's@ANAT324@'$ANAT324'@g' \
-e 's@ANAT325@'$ANAT325'@g' \
-e 's@ANAT326@'$ANAT326'@g' \
-e 's@ANAT327@'$ANAT327'@g' \
-e 's@ANAT328@'$ANAT328'@g' \
-e 's@ANAT329@'$ANAT329'@g' \
-e 's@ANAT330@'$ANAT330'@g' \
-e 's@ANAT331@'$ANAT331'@g' \
-e 's@ANAT332@'$ANAT332'@g' \
-e 's@ANAT333@'$ANAT333'@g' \
-e 's@ANAT334@'$ANAT334'@g' \
-e 's@ANAT335@'$ANAT335'@g' \
-e 's@ANAT336@'$ANAT336'@g' \
-e 's@ANAT337@'$ANAT337'@g' \
-e 's@ANAT338@'$ANAT338'@g' \
-e 's@ANAT339@'$ANAT339'@g' \
-e 's@ANAT340@'$ANAT340'@g' \
-e 's@ANAT341@'$ANAT341'@g' \
-e 's@ANAT342@'$ANAT342'@g' \
-e 's@ANAT343@'$ANAT343'@g' \
-e 's@ANAT344@'$ANAT344'@g' \
-e 's@ANAT345@'$ANAT345'@g' \
-e 's@ANAT346@'$ANAT346'@g' \
-e 's@ANAT347@'$ANAT347'@g' \
-e 's@ANAT348@'$ANAT348'@g' \
-e 's@ANAT349@'$ANAT349'@g' \
-e 's@ANAT350@'$ANAT350'@g' \
-e 's@ANAT351@'$ANAT351'@g' \
-e 's@ANAT352@'$ANAT352'@g' \
-e 's@ANAT353@'$ANAT353'@g' \
-e 's@ANAT354@'$ANAT354'@g' \
-e 's@ANAT355@'$ANAT355'@g' \
-e 's@ANAT356@'$ANAT356'@g' \
-e 's@ANAT357@'$ANAT357'@g' \
-e 's@ANAT358@'$ANAT358'@g' \
-e 's@ANAT359@'$ANAT359'@g' \
-e 's@ANAT360@'$ANAT360'@g' \
-e 's@ANAT361@'$ANAT361'@g' \
-e 's@ANAT362@'$ANAT362'@g' \
-e 's@ANAT363@'$ANAT363'@g' \
-e 's@ANAT364@'$ANAT364'@g' \
-e 's@ANAT365@'$ANAT365'@g' \
-e 's@ANAT366@'$ANAT366'@g' \
-e 's@ANAT367@'$ANAT367'@g' \
-e 's@ANAT368@'$ANAT368'@g' \
-e 's@ANAT369@'$ANAT369'@g' \
-e 's@ANAT370@'$ANAT370'@g' \
-e 's@ANAT371@'$ANAT371'@g' \
-e 's@ANAT372@'$ANAT372'@g' \
-e 's@ANAT373@'$ANAT373'@g' \
-e 's@ANAT374@'$ANAT374'@g' \
-e 's@ANAT375@'$ANAT375'@g' \
-e 's@ANAT376@'$ANAT376'@g' \
-e 's@ANAT377@'$ANAT377'@g' \
-e 's@ANAT378@'$ANAT378'@g' \
-e 's@ANAT379@'$ANAT379'@g' \
-e 's@ANAT380@'$ANAT380'@g' \
-e 's@ANAT381@'$ANAT381'@g' \
-e 's@ANAT382@'$ANAT382'@g' \
-e 's@ANAT383@'$ANAT383'@g' \
-e 's@ANAT384@'$ANAT384'@g' \
-e 's@ANAT385@'$ANAT385'@g' \
-e 's@ANAT386@'$ANAT386'@g' \
-e 's@ANAT387@'$ANAT387'@g' \
-e 's@ANAT388@'$ANAT388'@g' \
-e 's@ANAT389@'$ANAT389'@g' \
-e 's@ANAT390@'$ANAT390'@g' \
-e 's@ANAT391@'$ANAT391'@g' \
-e 's@ANAT392@'$ANAT392'@g' \
-e 's@ANAT393@'$ANAT393'@g' \
<group_melodic_n393.fsf> ${MAINOUTPUT}/all_n393.fsf


feat ${MAINOUTPUT}/all_n393.fsf


# -- END USER SCRIPT -- #

# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis} #set above
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
rm -rf $HOME/$JOB_NAME.$JOB_ID.out
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
