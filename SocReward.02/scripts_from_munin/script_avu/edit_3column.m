
maindir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/';

sublist = load(fullfile(maindir, 'avu', 'final_sub_runs.txt'));
subs = sublist(:,1);
runs = sublist(:,2);


for i=1:length(sublist);
	subject = subs(i);
	runnum = runs(i);

	sub_3_column_dir = fullfile(maindir, 'FSL', 'EV_files', 'Anticipation_Models', num2str(subject), ['run' num2str(runnum)]);
	
	%% concatenating all face trials and all land trials for social/nonsocial study
	%face_value = load(fullfile(sub_3_column_dir, 'face_value_cue.txt'));
	%face_delay = load(fullfile(sub_3_column_dir, 'face_delay_cue.txt'));
	%land_value = load(fullfile(sub_3_column_dir, 'land_value_cue.txt'));
	%land_delay = load(fullfile(sub_3_column_dir, 'land_delay_cue.txt'));

	%face_concat = [face_value; face_delay];
	%land_concat = [land_value; land_delay];
	
	%concat face and land files, coding faces as +1 and lands as -1 for PPI (6/2/14)
	face_output = load(fullfile(sub_3_column_dir,'face_constant_image.txt'));
	land_output = load(fullfile(sub_3_column_dir,'land_constant_image.txt'));
	land_output(:,3) = -1;

	PPI_EV = [face_output; land_output];
	PPI_outputfile = fullfile(sub_3_column_dir, 'face_land_outcome_PPI.txt');
	dlmwrite(PPI_outputfile, PPI_EV, 'delimiter', '\t');
	
	%concat face and land files, coding faces as +1 and lands as -1 for PPI addition EV (6/2/14)
	face_outputpos = load(fullfile(sub_3_column_dir,'face_constant_image.txt'));
	land_outputpos = load(fullfile(sub_3_column_dir,'land_constant_image.txt'));
	
	PPI_EVpos = [face_outputpos; land_outputpos];
	PPI_outputfilepos = fullfile(sub_3_column_dir, 'face_land_outcome_PPIpos.txt');
	dlmwrite(PPI_outputfilepos, PPI_EVpos, 'delimiter', '\t');

	disp(['finished subject ' num2str(subject) ', run ' num2str(runnum)]);
end
