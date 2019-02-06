#!/bin/sh

#for LIST in "1 face-land" "2 land-face" "3 face_lin" "4 land_lin"; do

for F in 1 0; do
	for SMOOTH in 0 2; do
		qsub -v EXPERIMENT=HighRes.01 L3_highres.sh $SMOOTH $F
		sleep 5s
	done
done

# Lower-level contrast 1 (Face>Land)
# Lower-level contrast 2 (Land>Face)
# Lower-level contrast 3 (Rating)
# Lower-level contrast 4 (Face_L)
# Lower-level contrast 5 (Face_Q)
# Lower-level contrast 6 (Land_L)
# Lower-level contrast 7 (Land_Q)
# Lower-level contrast 8 (Face_L>Land_L)
# Lower-level contrast 9 (Land_L>Face_L)
# Lower-level contrast 10 (Face_Q>Land_Q)
# Lower-level contrast 11 (Land_Q>Face_Q)