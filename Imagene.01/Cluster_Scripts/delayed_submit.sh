#!/bin/bash

echo "waiting 6 hours to submit..."
sleep 6h
python submit_L2_m6.py
python submit_L2_m4.py
python submit_L2_m5.py
python submit_FSL_sl.py


# qsub -v EXPERIMENT=Imagene.01 ANOVA_2x2_n58_m6.sh

