function get_choice_data(subnum)

%%%function get_choice_data(subnum)
%Created by JAC 02.26.10
%written to collect/analyze post-scanning choice data for GT project
%Updated by JAC 02.11.11

 
%%%directories%%%
cwd = pwd;
sub = num2str(subnum);
%base_dir = fullfile('/Users','jakeyoung','Projects','SocReward.02');
base_dir = fullfile('/Volumes','Huettel','SocReward.02');
%pilot_dir = fullfile(base_dir, 'Pilot');
sub_dir = fullfile(base_dir,'Stimuli','SocReward02_Task','BehavioralData',sub);
out_dir = fullfile(base_dir, 'Analysis','Behavioral',sub);
if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

%%%load data%%%
data_name = [sub '_image_choices.mat'];
data_file = fullfile(sub_dir,data_name);
load(data_file);

num_trials = length(data);
RT_data = [];
LR_data = [];
ID_data = [];
same_data = [];
trial_type = [];
FP_choice = [];
CP_choice = []; %category perference, added for SocReward02 exp by JSY
rating_type = [];
rating_same = [];
image_category = []; %added for SocReward02 exp by JSY
for i = 1:num_trials
    ID_data = [ID_data;data(i).trial_id];
    RT_data = [RT_data;data(i).RT];
    
    if strmatch('Attractiveness',data(i).rating_type) == 1 %Attractiveness =1
        rating_type = [rating_type;1];
%     elseif strmatch('Brightness',data(i).rating_type) == 1 %Brightness =2 
%         rating_type = [rating_type;2];
%     elseif strmatch('Complexity',data(i).rating_type) == 1
%         rating_type = [rating_type;3];
    end
    
    if data(i).pic_rating_A == data(i).pic_rating_B
        rating_same = [rating_same;1];
    else
        rating_same = [rating_same;0];
    end
%     
%     %%%get image category for left and right picture%%%  added by JSY
%     if strmatch(data(i).image_category_A,data(i).image_category_B) == 1
%         same_data = [same_data;0];
%         if strmatch('left',data(i).response) == 1 %left response
%             mode_choice = data(i).image_category_A;
%         elseif strmatch('right',data(i).response) == 1 %right response
%             mode_choice = data(i).image_category_B;
%         end
%         if strmatch('low',mode_choice) == 1 %low category
%             trial_category = [trial_category;1];
%         elseif strmatch('medium', mode_choice) == 1 %medium category
%             trial_category = [trial_category;2];
%         elseif strmatch('high', mode_choice) == 1 %high category
%             trial_category = [trial_category;3];
%         end
% %     else
% %         same_data = [same_data;1];
% %         trial_category = [trial_category,4];  trying to get low vs medium
% %         and low vs high, etc. comparisons but not sure about how to code
% %         
% 
%     end
        
            
            
    %%%get left or right preference%%%
    if strmatch('left',data(i).response) == 1 %left response
        LR_data = [LR_data;1];
    elseif strmatch('right',data(i).response) == 1 %right response
        LR_data = [LR_data;2];
    end
    %%%get trials where one face and one landscape%%%
    if strmatch(data(i).image_type_A,data(i).image_type_B) == 1
        same_data = [same_data;0];
        if strmatch('left',data(i).response) == 1
            mode_choice = data(i).image_type_A;
        elseif strmatch('right',data(i).response) == 1
            mode_choice = data(i).image_type_B;
        end
        if strmatch('Faces',mode_choice) == 1 %Face choice
            trial_type = [trial_type;1];
        elseif strmatch('Landscapes',mode_choice) == 1 %Landscape choice
            trial_type = [trial_type;2];
        end
    else
        same_data = [same_data;1];
        trial_type = [trial_type;3];
        if strmatch('left',data(i).response) == 1
            mode_choice = data(i).image_type_A;
        elseif strmatch('right',data(i).response) == 1
            mode_choice = data(i).image_type_B;
        end
        if strmatch('Faces',mode_choice) == 1 %Face choice
            FP_choice = [FP_choice;1];
        elseif strmatch('Landscapes',mode_choice) == 1 %Landscape choice
            FP_choice = [FP_choice;2];
        end
    end
end

%%%indexes for trial types%%%
I_t1 = find(trial_type == 1); %Face vs Face
I_t2 = find(trial_type == 2); %Place vs Place
I_t3 = find(trial_type == 3); %Face vs Place
% I_tL = find(trial_category == 1); %low vs low
% I_tM = find(trial_category == 2); %medium vs medium
% I_tH = find(trial_category == 3); %high vs high
I_tA = find(rating_type == 1); %Attractiveness trials
% I_tB = find(rating_type == 2); %Brightness trials
% I_tC = find(rating_type == 3); %Complexity
I_s1 = find(rating_same == 1); %same rating value
I_s0 = find(rating_same == 0); %dif rating value

num_trials_type_info = [length(I_t1) length(I_t2) length(I_t3)];
num_trials_rating_info = [length(I_tA)]; %length(I_tB) length(I_tC)];
num_trials_same_info = [length(I_s1) length(I_s0)];

face_FP_choice = length(find(FP_choice==1));
place_FP_choice = length(find(FP_choice==2));
ave_RT = mean(RT_data);
ave_RT_1 = mean(RT_data(I_t1));
ave_RT_2 = mean(RT_data(I_t2));
ave_RT_3 = mean(RT_data(I_t3));
std_RT_1 = std(RT_data(I_t1)); sem_RT_1 = (std(RT_data(I_t1))/sqrt(length(RT_data(I_t1))));
std_RT_2 = std(RT_data(I_t2)); sem_RT_2 = (std(RT_data(I_t2))/sqrt(length(RT_data(I_t2))));
std_RT_3 = std(RT_data(I_t3)); sem_RT_3 = (std(RT_data(I_t3))/sqrt(length(RT_data(I_t3))));
ave_RT_A = mean(RT_data(I_tA));
% ave_RT_B = mean(RT_data(I_tB));
% ave_RT_C = mean(RT_data(I_tC));
std_RT_A = std(RT_data(I_tA)); sem_RT_A = (std(RT_data(I_tA))/sqrt(length(RT_data(I_tA))));
% std_RT_B = std(RT_data(I_tB)); sem_RT_B = (std(RT_data(I_tB))/sqrt(length(RT_data(I_tB))));
% std_RT_C = std(RT_data(I_tC)); sem_RT_C = (std(RT_data(I_tC))/sqrt(length(RT_data(I_tC))));
ave_RT_s1 = mean(RT_data(I_s1));
ave_RT_s0 = mean(RT_data(I_s0));
std_RT_s1 = std(RT_data(I_s1)); sem_RT_s1 = (std(RT_data(I_s1))/length(RT_data(I_s1)));
std_RT_s0 = std(RT_data(I_s0)); sem_RT_s0 = (std(RT_data(I_s0))/length(RT_data(I_s0)));

%%%save data%%%
save_data_name = ['post_choice_' sub];
sname = fullfile(out_dir,save_data_name);

save(sname,'run_time','RT_data','LR_data','ID_data','FP_choice','face_FP_choice','place_FP_choice','same_data',...
    'ave_RT','ave_RT_1','ave_RT_2','ave_RT_3','std_RT_1','std_RT_2','std_RT_3',...
    'ave_RT_A','std_RT_A',...
    'ave_RT_s1','ave_RT_s0','std_RT_s1','std_RT_s0',...
    'sem_RT_1','sem_RT_2','sem_RT_3','sem_RT_A','sem_RT_s1','sem_RT_s0',...
    'num_trials_type_info','num_trials_rating_info','num_trials_same_info'); %'ave_RT_B','ave_RT_C','sem_RT_B','sem_RT_C','std_RT_B','std_RT_C',