clear;

maindir = '/Volumes/Huettel/SocReward.02/Analysis/';
sublist = load(fullfile(maindir, 'avu', 'final_sub_runs_task.txt')); %get list of subs and runs

subs = sublist(:,1);
runs = sublist(:,2);
scannernum = sublist(:,3);
    
for i=1:length(sublist)
    %maindir = '/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Analysis/';
    
    
    RT_faces = nan(1,36);
    RT_lands = nan(1,36);
    
    % behavedata = load(['/mnt/BIAC/munin.dhe.duke.edu/Huettel/SocReward.02/Stimuli/SocReward02_Task/BehavioralData/' num2str(scannernum(i)) '/cumulative_arrays' num2str(runs(i)) '.mat']); %get RTs
    behavedata = load(['/Volumes/Huettel/SocReward.02/Stimuli/SocReward02_Task/BehavioralData/' num2str(scannernum(i)) '/cumulative_arrays' num2str(runs(i)) '.mat']); %get RTs
    data = behavedata.data; %get just data
    sub_3_column_dir = fullfile(maindir, 'FSL', 'EV_files', 'Anticipation_Models', num2str(subs(i)), ['run' num2str(runs(i))]); %get previous 3 column files
    
    face = load(fullfile(sub_3_column_dir, 'face_constant_image.txt')); %load face outcome 3 column file
    land = load(fullfile(sub_3_column_dir, 'land_constant_image.txt')); %load land outcome 3 colum  file
    
    for j=1:(length(data)-1) % get subsequent trial's RTs
        if strcmp(data(j).image_type, 'Faces')
            RT_faces(j) = data(j+1).RT;
        elseif strcmp(data(j).image_type, 'Landscapes')
            RT_lands(j) = data(j+1).RT;
        end
    end
    RT_faces(isnan(RT_faces)) = []; %remove all zeros
    RT_lands(isnan(RT_lands)) = []; %remove all zeros
    
    mean_RT_faces = mean(RT_faces); %get mean for last trial
    mean_RT_lands = mean(RT_lands); %get mean for last trial
    
    
    if strcmp(data(length(data)).image_type, 'Faces') %if last was faces, replace w/mean
        RT_faces(1,18) = mean_RT_faces;
    elseif strcmp(data(length(data)).image_type, 'Landscapes') %if last was lands, replace w/mean
        RT_lands(1,18) = mean_RT_lands;
    end
        
    mean_RT_faces = mean(RT_faces); %get mean for demeaning (last trial should have RT = 0)
    mean_RT_lands = mean(RT_lands); %get mean for demeaning (last trial should have RT = 0)
    
    RT_faces = RT_faces - mean_RT_faces; %demean
    RT_lands = RT_lands - mean_RT_lands; %demean
    
    RT_faces = RT_faces'; %turn into column
    RT_lands = RT_lands'; %turn into column
    
    % make 3rd column = RTs
    face(:,3) = RT_faces; %replace 3rd column
    land(:,3) = RT_lands; %replace 3rd column 
    
    % write out new files
    face_output = fullfile(sub_3_column_dir,'face_constant_parametric_subsequentRT.txt');
    dlmwrite(face_output, face, 'delimiter', '\t');
    
    land_output = fullfile(sub_3_column_dir,'land_constant_parametric_subsequentRT.txt');
    dlmwrite(land_output, land, 'delimiter', '\t');
    if exist(face_output) && exist(land_output)
        disp(['finished subject ' num2str(subs(i)) ', run ' num2str(runs(i))]);
    end
    
end

