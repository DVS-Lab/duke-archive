#!/bin/bash

for SUBJ in 0001 0002 0003 0004 0005; do
	for RUN in 1 2 3 4 5 6; do
	
		FSLDATADIR2=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}/${SUBJ}_ica_6mm_ST/${SUBJ}_run${RUN}.ica
		MAINDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/${SUBJ}
		MAINOUTPUT=${MAINDIR}/${SUBJ}_Reward_M1
		mkdir -p ${MAINOUTPUT}
		
		OUTPUT=${MAINOUTPUT}/${SUBJ}_run${RUN} #output directory
		DATA=${FSLDATADIR2}/denoised_data.nii.gz #4d data file
		ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz #anatomical scan

		
		#ev files that make my model
		FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_Logs_3-7-08_new/Model_1/${SUBJ}/Passive

		GAIN1=${FSLEVDIR}/Run${RUN}/Run${RUN}_GainOne_${SUBJ}.txt
		LOSS1=${FSLEVDIR}/Run${RUN}/Run${RUN}_LossOne_${SUBJ}.txt
		GAIN2=${FSLEVDIR}/Run${RUN}/Run${RUN}_GainTwo_${SUBJ}.txt
		LOSS2=${FSLEVDIR}/Run${RUN}/Run${RUN}_LossTwo_${SUBJ}.txt
		GAIN5=${FSLEVDIR}/Run${RUN}/Run${RUN}_GainFive_${SUBJ}.txt
		LOSS5=${FSLEVDIR}/Run${RUN}/Run${RUN}_LossFive_${SUBJ}.txt
		MOTOR=${FSLEVDIR}/Run${RUN}/Run${RUN}_MotorResponse_${SUBJ}.txt
		

		#make subject/run specific design.fsf file
		TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates/feat
		cd $TEMPLATEDIR
		TEMPLATE=reward_template.fsf #template file
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@GAIN5@'$GAIN5'@g' \
		-e 's@LOSS5@'$LOSS5'@g' \
		-e 's@GAIN2@'$GAIN2'@g' \
		-e 's@LOSS2@'$LOSS2'@g' \
		-e 's@GAIN1@'$GAIN1'@g' \
		-e 's@LOSS1@'$LOSS1'@g' \
		-e 's@MOTOR@'$MOTOR'@g' \
		-e 's@ANAT@'$ANAT'@g' \
		-e 's@DATA@'$DATA'@g' \
		<$TEMPLATE> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
		
		#run feat with new template
		feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf
		
	done
done