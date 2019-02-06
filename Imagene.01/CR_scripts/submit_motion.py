#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib
 
#########user section#########################
#user specific constants
username = "smith"             #your cluster login name (use what shows up in qstatall)
useremail = "smith@biac.duke.edu"    #email to send job notices to
template_f = file("find_bad_frames.sh")  #job template location (on head node)
experiment = "Imagene.01"    #experiment name for qsub
nodes = 24                   #number of nodes on cluster
maintain_n_jobs = 24         #leave one in q to keep them moving through
min_jobs = 20                 #minimum number of jobs to keep in q even when crowded
n_fake_jobs = 10               #during business hours, pretend there are extra jobs to try and leave a few spots open
sleep_time = 10              #pause time (sec) between job count checks
max_run_time = 180           #maximum time any job is allowed to run in minutes
max_run_hours = 200	#maximum numbersof hours submission script can run
#make job files  these are the lists to be traversed
#all iterated items must be in "[ ]" separated by commas.  

subnums = ["48335", "48339", "47725", "47729", "47731", "47734", "47735", "47737", "47748", "47752", "47851", "47863", "47878", "47885", "47917", "47921", "47945", "47977", "48012", "48061", "48066", "48090", "48097", "48100", "48103", "48112", "48123", "48129", "48145", "48150", "48152", "48156", "48158", "48160", "48165", "48167", "48172", "48176", "48179", "48184", "48187", "48189", "48193", "48196", "48197", "48204", "48206", "48232", "48281", "48288", "48297", "48301", "48309", "48312", "48321", "48326", "48327", "48330", "48337", "48344", "48349", "48350", "48351", "48271"]
#removed: "48105",

#subnums = ["48100", "48112", "48123", "48129", "48145", "48150", "48152", "48156", "48158", "48160", "48165", "48167", "48176", "48179", "48184", "48187", "48189", "48193", "48196", "48204", "48206"]

#subnums = ["48112", "48150", "48152", "48167"]

#subnums = ["48152"]

smooths = ["6"] 
tasks = ["Framing", "MID", "Gambling", "Resting"] #task name
#tasks = ["Gambling"] #task name
GOES = ["1", "2"]
####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
	
start_dir=os.getcwd()
daemonize('/dev/null',os.path.join('home',username,'daemon.log'),os.path.join('home',username,'daemon.log'))
os.chdir(start_dir)
temp=time.localtime()
hour,minute,second=temp[3],temp[4],temp[5]
prev_hr=temp[3]
t0=str(hour)+':'+str(minute)+':'+str(second)
sys.stdout.write('Daemon started at %s with pid %d\n' %(t0,os.getpid()))
sys.stdout.write('To kill this process type "kill %s" at the head node command line\n' % os.getpid())
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
	status = os.popen("status -a")
	status_list = status.readlines()
 
	for line in status_list:
		#are these active or q'd jobs?
		if (line.find("Running") > -1):
			running = 1
		elif (line.find("Waiting") > -1):   #all following jobs are in queue not running
			running = 0
 
		#if job is mine
		if (line.find(username) > 0) & (line.find("interact.q") < 0):   #name is in the line, not including first spot
			n_jobs = n_jobs + 1
			if running == 1:   #if active job, check how long its been running and delete it if too long
				job_info = line.split()  #get job information
				start_date = job_info[4].split("/")  #split job start date
				start_time = job_info[5].split(":")  #split time from hours:minutes:seconds format
				started = datetime.datetime(int(start_date[2]), int(start_date[0]), int(start_date[1]),
							int(start_time[0]), int(start_time[1]), int(start_time[2]))
				if ((cur_time - started) > kill_time_limit) & (line.find("stalled") == -1):   #if the active job is over max run time, delete it
					os.system("qdel %s" % (job_info[0]))   #delete the run away job
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
 
#for each subject
for GO in GOES:
	for subnum in subnums:
		for task in tasks:
			
			if task == "Resting":
				runs = ["1"]
			else:
				runs = ["1","2","3"]
			
			
			
			#runs = range(1,4)  #[ 1, 2, 3, 4, 5, 6, 7, 8 ] range cuts the last number off any single runs should still be in [ ]
	
			
			#for each run
			for run in runs:
				for smooth in smooths:
			
					#Check for changes in user settings
					user_settings=("/home/%s/user_settings.txt") % (username)
					if os.path.isfile(user_settings):
						f=file(user_settings)
						settings=f.readlines()
						f.close()
						for line in settings:
							exec(line)
							
					#define substitutions, make them in template 
					#runstr = "%03d" %(run)
					#smoothstr="%03d" %(smooth)  
					tmp_job_file = template.replace( "SUB_USEREMAIL_SUB", useremail )
					tmp_job_file = tmp_job_file.replace( "SUB_RUN_SUB", str(run) )
					tmp_job_file = tmp_job_file.replace( "SUB_SUBNUM_SUB", str(subnum) )
					tmp_job_file = tmp_job_file.replace("SUB_TASK_SUB",str(task) )
					tmp_job_file = tmp_job_file.replace("SUB_SMOOTH_SUB",str(smooth) )
					tmp_job_file = tmp_job_file.replace("SUB_GO_SUB",str(GO) )

	
					#make fname and write job file to cwd
					tmp_job_fname = "_".join( ["Pre", subnum, task, run, smooth, GO] )
					tmp_job_fname = ".".join( [ tmp_job_fname, "job" ] )
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
							cmd = "qsub -v EXPERIMENT=%s %s"  % ( experiment, tmp_job_fname )
							dummy, f = os.popen2(cmd)
	
				#Check what how long daemon has been running
				t1=time.time()
				hour=(t1-t0)/3600
				sys.stdout.write('Daemon has been running for %s hours\n' % hour)
				now_hr=time.localtime()[3]
				if now_hr>prev_hr:
					master_clock=master_clock+1
				prev_hr=now_hr
				serverURL="email.biac.duke.edu"
				if master_clock==18:
					headers="From: %s\r\nTo: %s\r\nSubject: Daemon job still running!\r\n\r\n" % (useremail,useremail)
					text="""Your daemon job has been running for 18 hours.  It will be killed after %d.
					To kill it now, log onto the head node and type kill %d""" % (max_run_hours,os.getpid())
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
 
