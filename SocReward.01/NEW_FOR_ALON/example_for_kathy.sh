#!/bin/bash

for SUBJ in 32953 32958 32976 32984 33642 33732 33746 33754 33757 33771 33784 33467 33744 32918; do
	for RUN in 1 2 3 4 5 6; do
	
		MAINDIR=${EXPERIMENT}/Analysis/Cluster/forAlon_NeuralFinance
		SUBJDIR=${MAINDIR}/${SUBJ}
		MAINOUTPUT=${SUBJDIR}/${SUBJ}_FEAT_Smooth_6mm_denoised
		mkdir -p ${MAINOUTPUT}

		ANAT=${EXPERIMENT}/Analysis/Cluster/Anats/${SUBJ}_anat/${SUBJ}_anat_brain.nii.gz
		DATA=${SUBJDIR}/MELODIC/run${RUN}.ica/denoised_data.nii.gz
		OUTPUT=${MAINOUTPUT}/run${RUN}

		FSLEVDIR=${EXPERIMENT}/Analysis/FSL/EV_files/${SUBJ}/Passive
		ONESTAR=${FSLEVDIR}/Run${RUN}/Run${RUN}_OneStar_${SUBJ}.txt

		TEMPLATEDIR=${EXPERIMENT}/Analysis/Cluster/PassiveTask/AnalysisTemplates
		cd ${TEMPLATEDIR}
		sed -e 's@OUTPUT@'$OUTPUT'@g' \
		-e 's@REGRESSOR@'$REGRESSOR'@g' \
		-e 's@ANAT@'$ANAT'@g' \
		-e 's@DATA@'$DATA'@g' \
		<SR1_template.fsf> ${MAINOUTPUT}/FEAT_0${RUN}.fsf
		feat ${MAINOUTPUT}/FEAT_0${RUN}.fsf

	done
done

