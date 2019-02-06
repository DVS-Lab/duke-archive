headdir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/';
maindir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/';

sublist = load(fullfile(maindir, 'avu', 'final_sub_runs_RTs.txt'));
subs = sublist(:,1);
runs = sublist(:,2);

for i=1:length(sublist);
	subject = subs(i);
	runnum = runs(i);
	
	sub_3_column_dir = fullfile(maindir, 'FSL', 'EV_files', 'Anticipation_Models', num2str(subject), ['run' num2str(runnum)]);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% need to change 3rd column of parametric regressor to -1.5, -.5, .5, 1.5 according to RT,
	%%% as we're using RT as a proxy for preference
	
	face_delay_p = load(fullfile(sub_3_column_dir, 'face_delay_cue.txt'));
	face_value_p = load(fullfile(sub_3_column_dir, 'face_value_cue.txt'));
	land_delay_p = load(fullfile(sub_3_column_dir, 'land_delay_cue.txt'));
	land_value_p = load(fullfile(sub_3_column_dir, 'land_value_cue.txt'));
	
	RTs = sublist(:, 3:6); %3 = FD; 4 = FV; 5 = LD; 6 = LV
	scannersubj = sublist(:,1);
	SRsubj = sublist(:,2);
	
	tmpRts = RTs(i,:);
	tmpRts = tmpRts*-1
	%values = [1.5 0.5 -0.5 -1.5];
	%[tmp, ind] = sort(tmpRts);
	%values_sorted = values(ind);
	face_delay_p(:,3) = tmpRts(1);
	face_value_p(:,3) = tmpRts(2);
	land_delay_p(:,3) = tmpRts(3);
	land_value_p(:,3) = tmpRts(4);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	parametric = [face_value_p; face_delay_p; land_value_p; land_delay_p];

	%% make anticipation onset .75s after cue onset for new 'anticipation' period (5/8/14)para
	new_onset = parametric(:,1) - 0.75;
	parametric(:,1) = new_onset;
	
	%% make duration 2.25s
	parametric(:,2) = 2.25;
	
	%% write out new file
	parametric_output = fullfile(sub_3_column_dir,'parametric_anticip_ev_avgRTs_au.txt');
	dlmwrite(parametric_output, parametric, 'delimiter', '\t');
	
	disp(['finished subject ' num2str(subject) ', run ' num2str(runnum)]);
end
	
	