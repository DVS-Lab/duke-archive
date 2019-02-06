#!/bin/sh

MAINDIR=/home/dvs3/linux/experiments/Imagene.02/Analysis/AU_connectivity/DVS/TPJparcellation

for MODELS in A B C; do
for SUBJ in 10168 10181 10199 10279 10286 10304 10305 10306 10314 10315 10335 10350 10351 10352 10358 10359 10414 10415 10416 10424 10425 10426 10472 10482 10483 10512 10515 10521 10523 10524 10525 10558 10560 10565 10583 10605 10615 10657 10659 10665 10670 10698 10699 10705 10706 10746 10747 10749 10757 10762 10785 10793 10794 10795 10827 10844 10845 10858 10890 11021 11022 11024 11029 11058 11059 11065 11066 11067 11171 11215 11216 11217 11232 11233 11243 11264 11266 11273 11274 11291 11292 11293 11326 11327 11328 11335 11363 11364 11366 11371 11372 11373 11383 11393 11394 11402 11430 11473 11479 11511 11525 11545 11578 11584 11602 11625 11660 11692 11738 11762 11865 11878 11941 11950 12015 12071 12082 12089 12097 12132 12159 12165 12175 12176 12217 12235 12280 12294 12372 12380 12383 12393 12400 12412 12444 12459 12460 12476 12496 12541 12550 12551 12564 12596 12606 12614 12629 12664 12665 12677 12678 12711 12731 12742 12755 12756 12757 12758 12766 12768 12780 12789 12791 12802 12816 12817 12828 12839 12850 12873 12874 12879 12894 12896 12905 12907 12911 12923 12960 12961 12988 12989 13051 13060; do
	
	for RUN in 1 2 3; do 
	
	EV1_PARA=${MAINDIR}/TPJparcEVs/${SUBJ}/run${RUN}/${SUBJ}_m${MODELS}_para_run${RUN}.txt
	if [ ! -e $EV1_PARA ]; then
		echo "skipping $SUBJ $RUN"
		continue
	fi

	EV2_CONS=${MAINDIR}/TPJparcEVs/${SUBJ}/run${RUN}/${SUBJ}_m${MODELS}_cons_run${RUN}.txt
	
	EV3_MISS=${MAINDIR}/TPJparcEVs/${SUBJ}/run${RUN}/${SUBJ}_m${MODELS}_miss_run${RUN}.txt
	if [ -s $EV3_MISS ]; then
		EV3_SHAPE=3
	else
		EV3_SHAPE=10
		echo "no lapses"
	fi
	
	MAINOUTPUT=${MAINDIR}/newRegressions_modelsABC/${SUBJ}
	mkdir -p $MAINOUTPUT
	OUTPUT=${MAINOUTPUT}/design_model${MODELS}_run${RUN}
	TEMPLATE=${MAINDIR}/TPJmodelsABC_230vols.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@EV1_PARA@'$EV1_PARA'@g' \
	-e 's@EV2_CONS@'$EV2_CONS'@g' \
	-e 's@EV3_MISS@'$EV3_MISS'@g' \
	-e 's@EV3_SHAPE@'$EV3_SHAPE'@g' \
	<${TEMPLATE}> ${OUTPUT}.fsf
	feat_model ${OUTPUT}
	
	done
done
done
