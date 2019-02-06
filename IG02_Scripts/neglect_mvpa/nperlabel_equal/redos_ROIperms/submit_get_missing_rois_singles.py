#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#########user section#########################
#user specific constants
username = "smith"             		#your cluster login name (use what shows up in qstatall)
useremail = "smith@biac.duke.edu"    	#email to send job notices to
template_f = file("get_missing_rois.sh") 	#job template location (on head node)
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
classifiers = [ "LinearNuSVMC", "RbfNuSVMC" ]
perms = range(6,9)


# make it more selective: & (line.find("HiRes") > 0)

###############################################

def daemonize(stdin='/dev/null',stdout='/dev/null',stderr='/dev/null'):
	try:
		#try first fork
		pid=os.fork()
		if pid>0:
			sys.exit(0)
	except OSError, e:
		sys.stderr.write("fork #1 failed: (%d) %s\n" % (e.errno,e.strerror))
		sys.exit(1)
	os.chdir("/")
	os.umask(0)
	os.setsid()
	try:
		#try second fork
		pid=os.fork()
		if pid>0:
			sys.exit(0)
	except OSError, e:
			sys.stderr.write("fork #2 failed: (%d) %s\n" % (e.errno, e.strerror))
			sys.exit(1)
	for f in sys.stdout, sys.stderr: f.flush()
	si=file(stdin,'r')
	so=file(stdout,'a+')
	se=file(stderr,'a+',0)
	os.dup2(si.fileno(),sys.stdin.fileno())
	os.dup2(so.fileno(),sys.stdout.fileno())
	os.dup2(se.fileno(),sys.stderr.fileno())
	

start_dir = os.getcwd()
 
daemonize('/dev/null',os.path.join(start_dir,'daemon.log'),os.path.join(start_dir,'daemon.log'))
sys.stdout.close()
os.chdir(start_dir)
temp=time.localtime()
hour,minute,second=temp[3],temp[4],temp[5]
prev_hr=temp[3]
t0=str(hour)+':'+str(minute)+':'+str(second)
log_name=os.path.join(start_dir,'daemon.log')
log=file(log_name,'w')
log.write('Daemon started at %s with pid %d\n' %(t0,os.getpid()))
log.write('To kill this process type "kill %s" at the head node command line\n' % os.getpid())
log.close()
t0=time.time()
master_clock=0
 
#build allowed timedelta
kill_time_limit = datetime.timedelta(minutes=max_run_time)
 
 
def _check_jobs(username, kill_time_limit, n_fake_jobs):
#careful, looks like all vars are global
#see how many jobs we have  in
 
	#set number of jobs to maintain based on time of day.
	cur_time = datetime.datetime.now() #get current time  #time.localtime()  #get current time
	if (cur_time.weekday > 4) | (cur_time.hour < 8) | (cur_time.hour > 17):
		n_other_jobs = 0
	else: #its a weekday, fake an extra 6 jobs to leave 5 nodes open
		n_other_jobs = n_fake_jobs
 
	n_jobs = 0
	status = os.popen("qstat  -u '*'")
	status_list = status.readlines()
 
	for line in status_list:
		#are these active or q'd jobs?
		if (line.find("  r  ") > -1):
			running = 1
		elif (line.find("qw") > -1):   #all following jobs are in queue not running
			running = 0
 
		#if job is mine
		if (line.find(username) > 0) & (line.find("interact.q") < 0):   #name is in the line, not including first spot
			n_jobs = n_jobs + 1
			if running == 1:   #if active job, check how long its been running and delete it if too long
				job_info = line.split()  #get job information
				start_date = job_info[5].split("/")  #split job start date
				start_time = job_info[6].split(":")  #split time from hours:minutes:seconds format
				started = datetime.datetime(int(start_date[2]), int(start_date[0]), int(start_date[1]),
							int(start_time[0]), int(start_time[1]), int(start_time[2]))
				if ((cur_time - started) > kill_time_limit) & (line.find("stalled") == -1):   #if the active job is over max run time, delete it
					#os.system("qdel %s" % (job_info[0]))   #delete the run away job
					print("Job %s was deleted because it ran for more than the maximum time." % (job_info[0]))
 
		# if line starts " ###" and isnt an interactive job
		elif bool(re.match( "^\d+", line )) & (line.find("interact") < 0) & (line.find("(Error)") < 0):
			n_other_jobs = n_other_jobs + 1
	return n_jobs, n_other_jobs
 
 
#make a directory to write job files to and store the start directory
tmp_dir = str(os.getpid())
os.mkdir(tmp_dir)
 
 
#read in template
template = template_f.read()
template_f.close()
os.chdir(tmp_dir)



#neglect_combo2_LinearCSVMC_old_CV_performance_rawdata_missingROIs.txt
#neglect_combo2_LinearNuSVMC_old_CV_performance_rawdata_missingROIs.txt
#neglect_combo2_SMLR_old_CV_performance_rawdata_missingROIs.txt


#------START SCRIPT HERE----------------
for combo in combos:
	for perm in perms:
		for classifier in classifiers:
			for datatype in datatypes:

				ROI_str = '000'
		
				tmp_job_file = template.replace( "SUB_USEREMAIL_SUB", useremail )
				tmp_job_file = tmp_job_file.replace("SUB_ROI_SUB", ROI_str )
				tmp_job_file = tmp_job_file.replace("SUB_COMBO_SUB", combo )
				tmp_job_file = tmp_job_file.replace("SUB_DATATYPE_SUB", datatype )
				tmp_job_file = tmp_job_file.replace("SUB_CLASSIFIER_SUB", classifier )
				tmp_job_file = tmp_job_file.replace("SUB_PERM_SUB", str(perm) )
				tmp_job_fname = "_".join( [ "missing", combo, classifier, datatype, str(perm)] )
				tmp_job_f = file( tmp_job_fname, "w" )
				tmp_job_f.write(tmp_job_file)
				tmp_job_f.close()
				
		
				#wait to submit the job until we have fewer than maintain in q
				n_jobs = maintain_n_jobs
				while n_jobs >= maintain_n_jobs: 
		
					#count jobs
					n_jobs, n_other_jobs = _check_jobs(username, kill_time_limit, n_fake_jobs)   #count jobs, delete jobs that are too old
		
					#adjust job submission by how may jobs are submitted
					#set to minimum number if all nodes are occupied
					#should still try to leave # open on weekdays
					if ((n_other_jobs+ n_jobs) > (nodes+1)): 
						n_jobs = maintain_n_jobs  - (min_jobs - n_jobs)
		
					if n_jobs >= maintain_n_jobs: 
						time.sleep(sleep_time)
					elif n_jobs < maintain_n_jobs:
						cmd = "qsub -l h_vmem=3G -v EXPERIMENT=%s %s"  % ( experiment, tmp_job_fname )
						dummy, f = os.popen2(cmd)
		
		
				#need to pause after each job submission
				time.sleep(delayt)
				os.remove(tmp_job_fname) #need to clean up as i go.
		
				#Check what how long daemon has been running
				#don't need to do this every loop
				t1=time.time()
				hour=(t1-t0)/3600
				log=file(log_name,'a+')
				log.write('Daemon has been running for %s hours\n' % hour)
				log.close()
				now_hr=time.localtime()[3]
				if now_hr>prev_hr:
					master_clock=master_clock+1
				prev_hr=now_hr
				serverURL="email.biac.duke.edu"
				if master_clock==warning_time:
					headers="From: %s\r\nTo: %s\r\nSubject: Daemon job still running!\r\n\r\n" % (useremail,useremail)
					text="""Your daemon job has been running for %d hours.  It will be killed after %d.
					To kill it now, log onto the head node and type kill %d""" % (warning_time,max_run_hours,os.getpid())
					message=headers+text
					mailServer=smtplib.SMTP(serverURL)
					mailServer.sendmail(useremail,useremail,message)
					mailServer.quit()
				elif master_clock==max_run_hours:
					headers="From: %s\r\nTo: %s\r\nSubject: Daemon job killed!\r\n\r\n" % (useremail,useremail)
					text="Your daemon job has been killed.  It has run for the maximum time alotted"
					message=headers+text
					mailServer=smtplib.SMTP(serverURL)
					mailServer.sendmail(useremail,useremail,message)
					mailServer.quit()
					ID=os.getpid()
					os.system('kill '+str(ID))
			


#wait for jobs to complete
#delete them if they run too long
n_jobs = 1
while n_jobs > 0:
	n_jobs, n_other_jobs = _check_jobs(username, kill_time_limit, n_fake_jobs)
	time.sleep(sleep_time)
 
 
#remove tmp job files move to start dir and delete tmpdir
#terminated jobs will prevent this from executing
#you will then have to clean up a "#####" directory with
# ".job" files written in it.
cmd = "rm *.job"
os.system(cmd)
os.chdir(start_dir)
os.rmdir(tmp_dir)
 
