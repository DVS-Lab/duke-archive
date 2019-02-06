#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib
 
#########user section#########################
#user specific constants
username = "rl100"             #your cluster login name (use what shows up in qstatall)
useremail = "rosa.li@duke.edu"    #email to send job notices to
template_f = file("02_L1_framing_ALL_normal.sh")  #job template location (on head node)
experiment = "Imagene.02"    #experiment name for qsub
nodes = 400                   #number of nodes on cluster
maintain_n_jobs = 100         #leave one in q to keep them moving through
min_jobs = 10                 #minimum number of jobs to keep in q even when crowded
n_fake_jobs = 10               #during business hours, pretend there are extra jobs to try and leave a few spots open
sleep_time = 30              #pause time (sec) between job count checks
max_run_time = 2880           #maximum time any job is allowed to run in minutes
max_run_hours = 48	#maximum number of hours submission script can run
warning_time = 24         #send out a warning after this many hours informing you that the deamon is still running
delayt = 5		  #delay time between job submissions

#make job files  these are the lists to be traversed
#all iterated items must be in "[ ]" separated by commas.  

#all subs; broken down below
#subnums =  ["10156","10168","10181","10199","10255","10264","10265","10279","10280","10281","10286","10287","10294","10304","10305","10306","10314","10315","10335","10350","10351","10358","10359","10414","10415","10416","10424","10425","10472","10482","10483","10512","10515","10521","10523","10525","10558","10560","10565","10583","10602","10605","10657","10659","10665","10670","10697","10698","10699","10706","10746","10749","10757","10785","10793","10795","10817","10827","10844","10845","10890","11021","11022","11024","11029","11059","11065","11066","11067","11171","11176","11209","11212","11215","11216","11217","11232","11243","11245","11264","11266","11272","11273","11291","11292","11293","11326","11327","11328","11335","11363","11364","11366","11371","11373","11393","11394","11402","11430","11473","11479","11511","11545","11578","11584","11605","11625","11660","11692","11738","11762","11941","11950","12015","12071","12082","12089","12097","12159","12175","12280","12294","12372","12380","12383","12393","12400","12411","12412","12444","12459","12460","12476","12496","12541","12550","12564","12596","12606","12614","12629","12664","12677","12678","12679","12711","12717","12731","12742","12755","12756","12757","12766","12780","12791","12802","12815","12816","12817","12828","12839","12850","12873","12874","12875","12879","12880","12893","12894","12896","12905","12907","12923","12960","12961","12988","12989","13011","13051", "13060","10387", "10705", "10747", "10762", "11196", "11210", "11274" , "11383", "12165", "12360", "12665", "12758", "12789","10352", "10707", "11235","10524", "10615", "10696", "10783", "10794", "10858", "11233",  "11602", "12132", "12551","10426", "10782", "11058", "11372", "11659", "11865", "11878", "12768", "12840","12176", "10360", "10474", "12314"]

#subs rerun b/c missed first time
#subnums = ["10426", "10782", "11058", "11372", "11659", "11865", "12768", "12840", "12176", "10474", "12314"]

#subs with 3 good runs
#subnums = ["10156","10168","10181","10199","10255","10264","10265","10279","10280","10281","10286","10287","10294","10304","10305","10306","10314","10315","10335","10350","10351","10358","10359","10414","10415","10416","10424","10425","10472","10482","10483","10512","10515","10521","10523","10525","10558","10560","10565","10583","10602","10605","10657","10659","10665","10670","10697","10698","10699","10706","10746","10749","10757","10785","10793","10795","10817","10827","10844","10845","10890","11021","11022","11024","11029","11059","11065","11066","11067","11171","11176","11209","11212","11215","11216","11217","11232","11243","11245","11264","11266","11272","11273","11291","11292","11293","11326","11327","11328","11335","11363","11364","11366","11371","11373","11393","11394","11402","11430","11473","11479","11511","11545","11578","11584","11605","11625","11660","11692","11738","11762","11941","11950","12015","12071","12082","12089","12097","12159","12175","12280","12294","12372","12380","12383","12393","12400","12411","12412","12444","12459","12460","12476","12496","12541","12550","12564","12596","12606","12614","12629","12664","12677","12678","12679","12711","12717","12731","12742","12755","12756","12757","12766","12780","12791","12802","12815","12816","12817","12828","12839","12850","12873","12874","12875","12879","12880","12893","12894","12896","12905","12907","12923","12960","12961","12988","12989","13011"]

#iffy subs with 3 runs: possible artifact b/c door didn't seal; excluded in L3
#subnums = ["13051", "13060"]

#subs with runs 1 and 2
#subnums = ["10387", "10705", "10747", "10762", "11196", "11210", "11274" , "11383", "12165", "12360", "12665", "12758", "12789"]
#have 3rd run data missing so change runs array
#subnums = ["10387", "11196", "11210"]

#subs with runs 2 and 3
#subnums = ["10352", "10707", "11235"]

#subs with runs 1 and 3
#subnums = ["10524", "10615", "10696", "10783", "10794", "10858", "11233",  "11602", "12132", "12551"]

#subs with run 1
#subnums = ["10426", "10782", "11058", "11372", "11659", "11865", "11878", "12768", "12840"]

#subs with run 2
#subnums = ["12176"]

#subs with run 3
#subnums = ["10360", "10474", "12314"]

#excluded subs: 12056, 10303, 10471, 10481, 11154, 11244, 11525, 11778, 11805, 12217, 12235, 12277, 12580, 12691, 12911

subnums = ["10156"]

#should be entered in quotes to be used as strings  
runs = range(1,4)  #[ 1, 2, 3, 4, 5, 6, 7, 8 ] range cuts the last number off any single runs should still be in [ ]
goes = [ "2" ]
models = [ "TEST" ]
####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
###############################################
 
 
def daemonize(stdin='/dev/null',stdout='/dev/null',stderr='/dev/null'):
	try:
		#try first fork
		pid=os.fork()
		if pid>0:
			sys.exit(0)
	except OSError, e:
		sys.stderr.write("for #1 failed: (%d) %s\n" % (e.errno,e.strerror))
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
			sys.stderr.write("for #2 failed: (%d) %s\n" % (e.errno, e.strerror))
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
	status = os.popen("qstat -u '*'")
	status_list = status.readlines()
 
	for line in status_list:
		#are these active or q'd jobs?
		if (line.find("  r  ") > -1):
			running = 1
		elif (line.find(" qw ") > -1):   #all following jobs are in queue not running
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
for go in goes:
	for model in models:
		for subnum in subnums:
			#for each run
			for run in runs:
				
				#Check for changes in user settings
				user_settings=("/home/%s/user_settings.txt") % (username)
				if os.path.isfile(user_settings):
					f=file(user_settings)
					settings=f.readlines()
					f.close()
					for line in settings:
						exec(line)
		
				#define substitutions, make them in template 
				runstr = "%02d" %(run)
				#modelstr = "%02d" %(model)
				tmp_job_file = template.replace( "SUB_USEREMAIL_SUB", useremail )
				tmp_job_file = tmp_job_file.replace( "SUB_RUN_SUB", str(run) )
				tmp_job_file = tmp_job_file.replace( "SUB_SUBNUM_SUB", str(subnum) )
				tmp_job_file = tmp_job_file.replace( "SUB_GO_SUB", str(go) )
				tmp_job_file = tmp_job_file.replace( "SUB_MODEL_SUB", str(model) )
	
		
				#make fname and write job file to cwd
				tmp_job_fname = "_".join( ["L1m", model, subnum, runstr, go] )
				tmp_job_fname = ".".join( [ tmp_job_fname, "job" ] )
				tmp_job_f = file( tmp_job_fname, "w" )
				tmp_job_f.write(tmp_job_file)
				tmp_job_f.close()
				
				time.sleep(delayt)
		
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
