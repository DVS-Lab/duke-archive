#!/bin/bash

#--data type shifted to int16 (short) and scaling factor (only on funcs?) reduced from 1000 to 500 (2/22/10)
#--changed time points starting on 10279. IRG cut to two runs. 

# #subject list from first pass analysis (3/23/10):
# # removed 20100202_10303 (IRB infraction) -- (5/15/10)
# SUBJECTS=( 20091208_10156 20091210_10168 20091210_10169 20091214_10181 20091218_10199 20100119_10255 20100119_10256 20100120_10264 20100120_10265 20100126_10279 20100126_10280 20100126_10281 20100127_10286 20100127_10287 20100128_10294 20100202_10304 20100202_10305 20100202_10306 20100203_10314 20100203_10315 20100212_10335 20100216_10350 20100216_10351 20100216_10352 20100217_10358 20100217_10359 20100217_10360 20100224_10387 20100302_10414 20100302_10415 20100302_10416 20100303_10424 20100303_10425 20100303_10426 20100309_10471 20100309_10472 20100309_10474 20100310_10481 20100310_10482 20100310_10483 20100316_10512 20100316_10515 20100317_10521 20100317_10523 20100317_10524 20100317_10525 )


# #subject list from second pass analysis (5/15/10):
# # removed 10826 (IRB infraction) -- (5/15/10) 
# SUBJECTS=( 20100323_10558 20100323_10560 20100324_10565 20100326_10583 20100330_10602 20100330_10605 20100331_10615 20100406_10657 20100406_10659 20100407_10665 20100407_10670 20100413_10696 20100413_10697 20100413_10698 20100413_10699 20100414_10705 20100414_10706 20100414_10707 20100420_10746 20100420_10747 20100420_10749 20100421_10757 20100423_10762 20100427_10782 20100427_10783 20100427_10785 20100428_10793 20100428_10794 20100428_10795 20100503_10817 20100504_10827 20100507_10844 20100507_10845 20100511_10858 )


#subject list from third pass analysis (9/27/10):
#SUBJECTS=( 20100518_10890 20100615_11021 20100615_11022 20100615_11024 20100616_11029 20100622_11058 20100622_11059 20100623_11065 20100623_11066 20100623_11067 20100720_11171 20100721_11176 20100804_11215 20100804_11216 20100804_11217 20100810_11232 20100810_11233 20100810_11235 20100811_11243 20100811_11244 20100811_11245 20100817_11264 20100817_11266 20100818_11272 20100818_11273 20100818_11274 20100824_11291 20100824_11292 20100824_11293 20100831_11326 20100831_11327 20100831_11328 20100901_11335 20100907_11363 20100907_11364 20100907_11366 20100908_11371 20100908_11372 20100908_11373 20100910_11383 20100914_11393 20100914_11394 20100915_11402 20100921_11430 20100921_11431 )
#skipping subjects (acquisition problems): 20100727_11196, 20100803_11209, 20100803_11210, 20100803_11212

#subject list from fourth pass (11/21/10): (note: still need to re-recon everything once petty finishes conversion from int16 to float32)
#SUBJECTS=( 20100929_11473 20100930_11479 20101006_11511 20101008_11525 20101011_11545 20101014_11578 20101015_11584 20101019_11602 20101019_11605 20101021_11625 20101026_11659 20101026_11660 20101029_11692 20101104_11738 20101108_11762 20101110_11778 20101116_11805 )

#---------------------------------------the big re-do... (1/4/11)------------------------------------------
#all subjects up to about n=150
#SUBJECTS=( 20091208_10156 20091210_10168 20091210_10169 20091214_10181 20091218_10199 20100119_10255 20100119_10256 20100120_10264 20100120_10265 20100126_10279 20100126_10280 20100126_10281 20100127_10286 20100127_10287 20100128_10294 20100202_10304 20100202_10305 20100202_10306 20100203_10314 20100203_10315 20100212_10335 20100216_10350 20100216_10351 20100216_10352 20100217_10358 20100217_10359 20100217_10360 20100224_10387 20100302_10414 20100302_10415 20100302_10416 20100303_10424 20100303_10425 20100303_10426 20100309_10471 20100309_10472 20100309_10474 20100310_10481 20100310_10482 20100310_10483 20100316_10512 20100316_10515 20100317_10521 20100317_10523 20100317_10524 20100317_10525 20100323_10558 20100323_10560 20100324_10565 20100326_10583 20100330_10602 20100330_10605 20100331_10615 20100406_10657 20100406_10659 20100407_10665 20100407_10670 20100413_10696 20100413_10697 20100413_10698 20100413_10699 20100414_10705 20100414_10706 20100414_10707 20100420_10746 20100420_10747 20100420_10749 20100421_10757 20100423_10762 20100427_10782 20100427_10783 20100427_10785 20100428_10793 20100428_10794 20100428_10795 20100503_10817 20100504_10827 20100507_10844 20100507_10845 20100511_10858 20100518_10890 20100615_11021 20100615_11022 20100615_11024 20100616_11029 20100622_11058 20100622_11059 20100623_11065 20100623_11066 20100623_11067 20100720_11171 20100721_11176 20100804_11215 20100804_11216 20100804_11217 20100810_11232 20100810_11233 20100810_11235 20100811_11243 20100811_11244 20100811_11245 20100817_11264 20100817_11266 20100818_11272 20100818_11273 20100818_11274 20100824_11291 20100824_11292 20100824_11293 20100831_11326 20100831_11327 20100831_11328 20100901_11335 20100907_11363 20100907_11364 20100907_11366 20100908_11371 20100908_11372 20100908_11373 20100910_11383 20100914_11393 20100914_11394 20100915_11402 20100921_11430 20100921_11431 20100929_11473 20100930_11479 20101006_11511 20101008_11525 20101011_11545 20101014_11578 20101015_11584 20101019_11602 20101019_11605 20101021_11625 20101026_11659 20101026_11660 20101029_11692 20101104_11738 20101108_11762 20101110_11778 20101116_11805 20101129_11865 20101130_11878 20101207_11941 20101208_11950 20101216_12015 20101229_12071 )

#SUBJECTS=( 20100810_11232 20091210_10168 20091210_10169 )
#sSUBJECTS=( 20100810_11232 20091210_10168 20091210_10169 20091214_10181 20100119_10255 20100414_10706 20100427_10785 )

#SUBJECTS=( 20110106_12082 20110107_12089 20110110_12097 20110114_12132 20110120_12159 20110121_12165 20110124_12175 20110124_12176 20110128_12193 20110204_12217 20110209_12235 20110217_12277 20110217_12280 20110218_12294 20110222_12314 )

#SUBJECTS=( 20110301_12360 20110307_12372 20110308_12380 20110308_12383 20110309_12393 20110310_12400 20110311_12411 20110311_12412 20110316_12444 20110318_12459 20110318_12460 20110321_12476 20110323_12496 20110328_12541 20110329_12550 20110329_12551 20110330_12564 20110401_12580 20110404_12596 20110405_12606 20110406_12614 20110407_12629 20110412_12664 20110412_12665 20110413_12677 20110413_12678 20110413_12679 20110414_12691 20110418_12711 20110419_12717 20110420_12731 20110421_12742 20110425_12755 20110425_12756 20110425_12757 20110425_12758 20110426_12766 20110426_12768 20110427_12780 20110428_12789 20110428_12791 20110429_12802 20110502_12815 20110502_12816 20110502_12817 20110503_12828 20110504_12839 20110504_12840 20110506_12850 20110511_12873 20110512_12874 20110512_12875 20110512_12879 20110512_12880  )

#SUBJECTS=( 20100727_11196 20100803_11209 20100803_11210 20100803_11212 20110516_12893 20110516_12894 20110516_12896 20110517_12905 20110517_12907 20110518_12911 20110519_12923 20110524_12960 20110524_12961 20110527_12988 20110527_12989 20110601_13011 20110606_13051 20110607_13060 )

SUBJECTS=( 20091208_10156 )

LENGTH=${#SUBJECTS[@]}
let LENGTH=$LENGTH-1

N=0
for x in `seq 0 $LENGTH`; do
	
	let N=$N+1
	SUBJ_FULL=${SUBJECTS[$x]}
	SUBJ=${SUBJ_FULL:9}

	qsub -v EXPERIMENT=Imagene.02 initialconvert2.sh ${SUBJ_FULL} ${SUBJ}
	sleep 8s
done

