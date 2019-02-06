#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#########user section#########################
#user specific constants
username = "smith"             		#your cluster login name (use what shows up in qstatall)
useremail = "smith@biac.duke.edu"    	#email to send job notices to
template_f = file("MVPA_ROI_perm_redo.sh") 	#job template location (on head node)
experiment = "Imagene.02"   		#experiment name for qsub
nodes = 400                  		#number of nodes on cluster
maintain_n_jobs = 250        		#leave one in q to keep them moving through
min_jobs = 10                 		#minimum number of jobs to keep in q even when crowded
n_fake_jobs = 25              	 	#during business hours, pretend there are extra jobs to try and leave a few spots open
sleep_time = 1             	 	#pause time (sec) between job count checks
max_run_time = 999999          		#maximum time any job is allowed to run in minutes
max_run_hours = 999999			#maximum number of hours submission script can run
warning_time = 999999         		#send out a warning after this many hours informing you that the deamon is still running
delayt = 1		  		#delay time between job submissions

combos = [ "1" ]
datatypes = [ "raw", "normed" ]
classifiers = [ "LinearNuSVMC" ]
reps = range(1,6)

#masks = [ "old" ]
#combos = [ "2" ]


#------START SCRIPT HERE----------------
for combo in combos:
	for rep in reps:
		
		for classifier in classifiers:
			for datatype in datatypes:
			
		
				fname = ("/home/%s/Imagene.02/neglect_mvpa/nperlabel_equal/redos_ROIperms/missing_lists/combo%s/missingROIs_combo%s_%s_%sdata_rep%s.txt") % (username,combo,combo,classifier,datatype,str(rep))
				
				if os.path.isfile(fname):
					combo_f = open(fname,"r")
					combo_list = combo_f.readlines()
					combo_f.close()
				else:
					continue
			
			
				for line in combo_list:
					c = line.split()
					ROI = c[0]
					perm = c[1]
					print ROI, perm
