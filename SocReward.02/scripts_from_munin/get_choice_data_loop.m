function get_choice_data_loop

%%%function get_choice_data_loop
%Created by JAC 04.16.11
%written to collect/analyze post-scanning choice data for GT project
%Updated by JAC 05.24.11

%%%directories%%%
cwd = pwd;
base_dir = fullfile('/Volumes','Huettel','SocReward.02');
summary_dir = fullfile(base_dir, 'Analysis','Behavioral','Summary');
if ~exist(summary_dir,'dir')
    mkdir(summary_dir);
end

%subnums = [5001;5002;5003;5004;5005;5006;5007;5008;5009;5010;5011;5012;5013;5014;5015;5016;5017;];
sub_list = 5001:5050;
subnums = sub_list';
nsubjects = length(sub_list);

face_FP_choice_Xsubj = [];
place_FP_choice_Xsubj = [];
RT_Xsubj = [];
RT_3_Xsubj = [];
skips = zeros(length(subnums),1);
for n = 1:nsubjects
    
    %skip some subjects%
    %if subnums(n) == 1021
    %    skips(n) = 1;
    %    continue
    %end
    
    sub = num2str(subnums(n));
    %get_choice_data(subnums(n));
    
    sub_dir = fullfile(base_dir,'Behavioral',sub);
    sub_data_name = ['post_choice_' sub];
    load(fullfile(sub_dir,sub_data_name));
    face_FP_choice_Xsubj = [face_FP_choice_Xsubj;face_FP_choice];
    place_FP_choice_Xsubj = [place_FP_choice_Xsubj;place_FP_choice];
    RT_Xsubj = [RT_Xsubj;ave_RT];
    RT_3_Xsubj = [RT_3_Xsubj;ave_RT_3];
end

%%%FP comparison%%%
FvP.ratio = face_FP_choice_Xsubj./place_FP_choice_Xsubj;
FvP.dif = face_FP_choice_Xsubj - place_FP_choice_Xsubj;

I1 = find(skips == 1);
subnums(I1) = [];
sum_save_sname = ['post_choice_Xsubj_n' num2str(length(subnums))];
cd(summary_dir);
save(sum_save_sname,'subnums','face_FP_choice_Xsubj','place_FP_choice_Xsubj','RT_Xsubj','RT_3_Xsubj','FvP');
cd(cwd);