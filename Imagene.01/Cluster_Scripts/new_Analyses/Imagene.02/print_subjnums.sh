#!/bin/bash

#special cases and notes: 
#20091208_10156 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100119_10256 -- no resting state, only 1 of the 3 runs of the Risk Task
#20100120_10264 -- no resting state, missing 3rd run of the Risk Task
#20100120_10265 -- no resting state, missing 3rd run of the Risk Task
#20100126_10280 -- no resting state
#20100127_10287 -- no resting state
#20100128_10294 -- no resting state
#20100224_10387 -- no resting state, also missing framing run3 and all of the Risk task -- subject had to get out of the scanner
#20100310_10481 -- no resting state

#20091210_10168/20091210_10169 (restart; same subject; missing run3 of MID)
#20091214_10179 (has anatomical data, but no functional data. what happened?)

#20100212_10335 -- missing run3 of MID
#20100216_10350 -- missing run3 of MID
#20100216_10351 -- missing run3 of MID

#20100309_10471 -- only has MID runs 1 and 2. missing everything else. scanner fail.

#--data type shifted to int16 (short) and scaling factor (only on funcs?) reduced from 1000 to 500 (2/22/10)
#--changed time points starting on 10279. IRG cut to two runs. 

#subject list from first pass analysis (3/23/10):
SUBJECTS=( 20091208_10156 20091210_10168 20091210_10169 20091214_10181 20091218_10199 20100119_10255 20100119_10256 20100120_10264 20100120_10265 20100126_10279 20100126_10280 20100126_10281 20100127_10286 20100127_10287 20100128_10294 20100202_10303 20100202_10304 20100202_10305 20100202_10306 20100203_10314 20100203_10315 20100212_10335 20100216_10350 20100216_10351 20100216_10352 20100217_10358 20100217_10359 20100217_10360 20100224_10387 20100302_10414 20100302_10415 20100302_10416 20100303_10424 20100303_10425 20100303_10426 20100309_10471 20100309_10472 20100309_10474 20100310_10481 20100310_10482 20100310_10483 20100316_10512 20100316_10515 20100317_10521 20100317_10523 20100317_10524 20100317_10525 )


LENGTH=${#SUBJECTS[@]}
let LENGTH=$LENGTH-1

N=0
for x in `seq 0 $LENGTH`; do
	
	let N=$N+1
	SUBJ_FULL=${SUBJECTS[$x]}
	SUBJ=${SUBJ_FULL:9}

	
	printf "\"${SUBJ}\", "

done
printf "\n"

