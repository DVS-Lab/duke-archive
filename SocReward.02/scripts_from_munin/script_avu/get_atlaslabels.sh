#!/bin/sh

THRESHIMG=$1
NAME=$2
OUTDIR=$3
OUTFILE=$OUTDIR/lmax_zstat1_std${NAME}.txt

cluster --in=$THRESHIMG --thresh=2.3 --oindex=$OUTDIR/cluster_idx_info$NAME --olmax=$OUTFILE --mm > $OUTDIR/cluster_info$NAME.txt $OUTDIR/cluster_idx_info$NAME
#changed thresh from .95 to 2.3 
rm $OUTDIR/cort_labels$NAME.txt
rm $OUTDIR/subcort_labels$NAME.txt

count=0
cat $OUTFILE | 
while read a; do 
set -- $a
	let count=$count+1
	echo $a
	if [ $count -gt 1 ]; then
		x=$3
		y=$4
		z=$5
		atlasquery -a "Harvard-Oxford Cortical Structural Atlas" -c $x,$y,$z >> $OUTDIR/cort_labels$NAME.txt
		atlasquery -a "Harvard-Oxford Subcortical Structural Atlas" -c $x,$y,$z >> $OUTDIR/subcort_labels$NAME.txt
	fi
done

sed -e 's@<b>Harvard-.*<br>@@g' <$OUTDIR/cort_labels$NAME.txt> $OUTDIR/cort_labels_edited$NAME.txt
sed -e 's@<b>Harvard-.*<br>@@g' <$OUTDIR/subcort_labels$NAME.txt> $OUTDIR/subcort_labels_edited$NAME.txt
