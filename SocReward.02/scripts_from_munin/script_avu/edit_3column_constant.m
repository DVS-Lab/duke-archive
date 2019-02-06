headdir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/';
maindir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/';

sublist = load(fullfile(maindir, 'avu', 'final_sub_runs.txt'));
subs = sublist(:,1);
runs = sublist(:,2);


for i=1:length(sublist);
	subject = subs(i);
	runnum = runs(i);
	
	sub_3_column_dir = fullfile(maindir, 'FSL', 'EV_files', 'Anticipation_Models', num2str(subject), ['run' num2str(runnum)]);

	%% make constant anticipation EV
	%face_value = load(fullfile(sub_3_column_dir, 'face_value_cue.txt'));
	%face_delay = load(fullfile(sub_3_column_dir, 'face_delay_cue.txt'));
	%land_value = load(fullfile(sub_3_column_dir, 'land_value_cue.txt'));
	%land_delay = load(fullfile(sub_3_column_dir, 'land_delay_cue.txt'));
	
	%constant = [face_value; face_delay; land_value; land_delay];
	%constant(:,3)=1; %change third column of this regressor to all 1s
	%constant_output = fullfile(sub_3_column_dir,'constant_anticip_ev_au.txt');
	%dlmwrite(constant_output, constant, 'delimiter', '\t');
	
	%% make anticipation onset .75s after cue onset for new 'anticipation' period (5/8/14)
	%current_anticip = load(fullfile(sub_3_column_dir, 'constant_anticip_ev_au.txt'));
	%new_onset = current_anticip;
	%new_onset(:,1) = new_onset(:,1) - 0.75;
	%new_onset_file = fullfile(sub_3_column_dir, 'constant_anticip_newonset_ev_au.txt');
	%dlmwrite(new_onset_file, new_onset, 'delimiter', '\t');
	
	%% make duration = 2.25s
	current_duration = load(fullfile(sub_3_column_dir, 'constant_anticip_newonset_ev_au.txt'));
	new_duration = current_duration;
	new_duration(:,2) = 2.25;
	new_duration_file = fullfile(sub_3_column_dir, 'constant_anticip_newonset_duration_ev_au.txt');
	dlmwrite(new_duration_file, new_duration, 'delimiter', '\t');
	
	disp(['finished subject ' num2str(subject) ', run ' num2str(runnum)]);
end
