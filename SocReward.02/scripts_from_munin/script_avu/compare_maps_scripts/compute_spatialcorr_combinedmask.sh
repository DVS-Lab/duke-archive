#! /bin/sh
######### Pearson's R correlation between two image volumes
#############

img1=$1
img2=$2
mask1=$3
mask2=$4
#echo "inputs: $img1 $img2 $mask"

fslmaths $mask1 -mas $mask2 combined_mask.nii.gz
mask=combined_mask.nii.gz

## --- Compute the correlation from 1st principles
## --- i.e., account for the mask when determining which voxels to include 
## --- in the computation
# Note that within the mask, we will treat 0's as valid data
M1=`fslstats $img1 -k $mask -m`
M2=`fslstats $img2 -k $mask -m`
#echo $M1 $M2

fslmaths $img1 -sub $M1 -mas $mask demeaned1 -odt float
fslmaths $img2 -sub $M2 -mas $mask demeaned2 -odt float
fslmaths demeaned1 -mul demeaned2 demeaned_prod
num=`fslstats demeaned_prod -k $mask -m`
#echo $num

fslmaths demeaned1 -sqr demeaned1sqr
fslmaths demeaned2 -sqr demeaned2sqr
den1=`fslstats demeaned1sqr -k $mask -m`
den2=`fslstats demeaned2sqr -k $mask -m`
denprod=`echo "scale=4; sqrt($den1*$den2)" | bc -l`
#echo $den1 $den2 $denprod

# The mean can be used instead of the sum because the 
# factor N/sqrt(N*N) will cancel
true_r=`echo "scale=4; $num/$denprod" | bc -l`
echo $true_r

rm combined_mask.nii.gz