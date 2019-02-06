#!/bin/sh
for DATA in R N; do
	for REP in 1 2 3 4 5; do
		#cp submit_MVPA_ROI_perm_redo_Rbf${DATA}_c2_rep${REP}.py submit_MVPA_ROI_perm_redo_Rbf${DATA}_c3_rep${REP}.py
		python submit_MVPA_ROI_perm_redo_Rbf${DATA}_c3_rep${REP}.py
	done
done
