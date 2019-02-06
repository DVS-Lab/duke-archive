#!/bin/bash

echo "sleeping for one hour before L2"
sleep 1h
python level2_submit.py

# echo "sleeping for a while longer before going back through this..."
# sleep 3h
# python level2_submit.py
sleep 5h
bash submit_L3_linear.sh







