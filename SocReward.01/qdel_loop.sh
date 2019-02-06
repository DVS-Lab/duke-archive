#!/bin/sh

JOB1=$1
JOBn=$2

let "total=${JOBn}-${JOB1}+1"

counter=0
for i in `seq ${total}`; do
	
	let "JOBS=${JOB1}+${counter}"
	qdel $JOBS
	let "counter=${counter}+1"
done



