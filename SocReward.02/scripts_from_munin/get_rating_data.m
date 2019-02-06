function [choice_trials] = get_rating_data(subjectnum)

% function get_rating_data(subjectnum)
%
% This function is called by "image_choice_postscan" and creates the
% following file: "SUBJECTNUM_choice_trial_structure.mat"
% This function should be located in the same folder as
% "image_choice_postscan"
% It will create the trials needed for the 2AFC task. It will crash if the
% ratings have not first been completed.
%
% Written by John Clithero (john.clithero@duke.edu)
% Last edit: 12 February 2011

% Converts argument passed to function into a char array if necessary.
if ~ischar(subjectnum)
    subjectnum = num2str(subjectnum);
end

% only need to save present working directory
currentdir = pwd;
maindir = pwd;
outputdir = fullfile(maindir,'BehavioralData',subjectnum);

%parameters and display preferences
dateandtime = datestr(now);
%rand('state',sum(100*clock));
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
warning('off','MATLAB:dispatcher:InexactMatch');
HideCursor;

try
    
    %need to fix this to account for restarts
    cd(outputdir);
    scanfiles = dir('*_All_RatingData_Consolidated.mat');
    scanfiles = struct2cell(scanfiles);
    scanfiles = scanfiles(1,1:end);
    
    categories = {'Attractiveness', 'Brightness', 'Complexity'};
    %Attractiveness = att = 1
    %Brightness = bri = 2
    %Complexity = com = 3
    
    i = 0;j = 0;k = 0;
    a = 0;b = 0;c = 0;
    for x = 1:length(scanfiles)
        scanfile = scanfiles{x};
        load(scanfile);
        for n = 1:length(rated_data)
            if strcmp(rated_data(n).image_type, 'Faces') %Face ratings
                if strcmp(rated_data(n).rate_dimension, 'Attractiveness')
                    i = i + 1;
                    pic_faces_id_1{i} = rated_data(n).pic_shown;
                    pic_faces_rating_1(i) = rated_data(n).rating;
                    pic_faces_category_1{i} = rated_data(n).image_category;
                elseif strcmp(rated_data(n).rate_dimension, 'Brightness')
                    k = k + 1;
                    pic_faces_id_2{k} = rated_data(n).pic_shown;
                    pic_faces_rating_2(k) = rated_data(n).rating;
                    pic_faces_category_2{k} = rated_data(n).image_category;
                elseif strcmp(rated_data(n).rate_dimension, 'Complexity')
                    j = j + 1;
                    pic_faces_id_3{j} = rated_data(n).pic_shown;
                    pic_faces_rating_3(j) = rated_data(n).rating;
                    pic_faces_category_3{j} = rated_data(n).image_category;
                end
            elseif strcmp(rated_data(n).image_type, 'Landscapes') %Landscape ratings
                if strcmp(rated_data(n).rate_dimension, 'Attractiveness')
                    a = a + 1;
                    pic_landscapes_id_1{a} = rated_data(n).pic_shown;
                    pic_landscapes_rating_1(a) = rated_data(n).rating;
                    pic_landscapes_category_1{a} = rated_data(n).image_category;
                elseif strcmp(rated_data(n).rate_dimension, 'Brightness')
                    c = c + 1;
                    pic_landscapes_id_2{c} = rated_data(n).pic_shown;
                    pic_landscapes_rating_2(c) = rated_data(n).rating;
                    pic_landscapes_category_2{c} = rated_data(n).image_category;
                elseif strcmp(rated_data(n).rate_dimension, 'Complexity')
                    b = b + 1;
                    pic_landscapes_id_3{b} = rated_data(n).pic_shown;
                    pic_landscapes_rating_3(b) = rated_data(n).rating;
                    pic_landscapes_category_3{b} = rated_data(n).image_category;
                end
            end
            
        end
    end
    %%%sort%%%
    [Y_l_att,I_l_att]=sort(pic_landscapes_rating_1,'descend'); %highest ratings first in index
    [Y_l_bri,I_l_bri]=sort(pic_landscapes_rating_2,'descend'); %highest ratings first in index
    [Y_l_com,I_l_com]=sort(pic_landscapes_rating_3,'descend'); %highest ratings first in index
    [Y_f_att,I_f_att]=sort(pic_faces_rating_1,'descend'); %highest ratings first in index
    [Y_f_bri,I_f_bri]=sort(pic_faces_rating_2,'descend'); %highest ratings first in index
    [Y_f_com,I_f_com]=sort(pic_faces_rating_3,'descend'); %highest ratings first in index
    %%%indices%%%
    num_ratings = 15; nr = num_ratings - 1;%take the top or bottom N=num_ratings in each category to use in trials
    I_top_faces_1 = I_f_att(1:num_ratings); I_bottom_faces_1 = I_f_att((end-nr):end);
    I_top_faces_2 = I_f_bri(1:num_ratings); I_bottom_faces_2 = I_f_bri((end-nr):end);
    I_top_faces_3 = I_f_com(1:num_ratings); I_bottom_faces_3 = I_f_com((end-nr):end);
    I_top_landscapes_1 = I_l_att(1:num_ratings); I_bottom_landscapes_1 = I_l_att((end-nr):end);
    I_top_landscapes_2 = I_l_bri(1:num_ratings); I_bottom_landscapes_2 = I_l_bri((end-nr):end);
    I_top_landscapes_3 = I_l_com(1:num_ratings); I_bottom_landscapes_3 = I_l_com((end-nr):end);
    groups = {'top','bottom'}; %highest and lowest ratings group names
    
    %%%face vs landscape choices%%%
    choice_trials = []; %empty vector to make choice_trials
    for r = 1:3 %rating categories
        eval(['I_top_faces = I_top_faces_' num2str(r) ';']);
        eval(['I_bottom_faces = I_bottom_faces_' num2str(r) ';']);
        eval(['I_top_landscapes = I_top_landscapes_' num2str(r) ';']);
        eval(['I_bottom_landscapes = I_bottom_landscapes_' num2str(r) ';']);
        eval(['pic_faces_id = pic_faces_id_' num2str(r) ';']);
        eval(['pic_landscapes_id = pic_landscapes_id_' num2str(r) ';']);
        eval(['pic_faces_category = pic_faces_category_' num2str(r) ';']);
        eval(['pic_landscapes_category = pic_landscapes_category_' num2str(r) ';']);
        eval(['pic_faces_rating = pic_faces_rating_' num2str(r) ';']);
        eval(['pic_landscapes_rating = pic_landscapes_rating_' num2str(r) ';']);
        eval(['I_faces = I_top_faces;']); %only make face vs landscape comparisons for top faces and landscapes
        eval(['I_landscapes = I_top_landscapes;']); %%only make face vs landscape comparisons for top faces and landscapes
        for m = 1:num_ratings
            n = length(choice_trials) + 1;
            choice_trials(n).image_type_A = 'Faces';
            choice_trials(n).image_type_B = 'Landscapes';
            choice_trials(n).image_category_A = pic_faces_category{I_faces(m)};
            choice_trials(n).image_category_B = pic_landscapes_category{I_landscapes(m)};
            choice_trials(n).pic_shown_A = pic_faces_id{I_faces(m)};
            choice_trials(n).pic_shown_B = pic_landscapes_id{I_landscapes(m)};
            choice_trials(n).rating_type = categories{r};
            choice_trials(n).pic_rating_A = pic_faces_rating(I_faces(m));
            choice_trials(n).pic_rating_B = pic_landscapes_rating(I_landscapes(m));
        end
    end
    %%%face vs face choices%%%
    num_att_ratings = length(pic_faces_rating_1);
    num_trials = 30;
    perm_id_faces = Shuffle(1:num_att_ratings); %use attractiveness ratings
    face_id = perm_id_faces(1:(2*num_trials));
    for m = 1:num_trials
        n = length(choice_trials) + 1;
        choice_trials(n).image_type_A = 'Faces';
        choice_trials(n).image_type_B = 'Faces';
        choice_trials(n).image_category_A = pic_faces_category_1{face_id(m)};
        choice_trials(n).image_category_B = pic_faces_category_1{face_id(m+num_trials-1)};
        choice_trials(n).pic_shown_A = pic_faces_id_1{face_id(m)};
        choice_trials(n).pic_shown_B = pic_faces_id_1{face_id(m+num_trials-1)};
        choice_trials(n).rating_type = categories{1};
        choice_trials(n).pic_rating_A = pic_faces_rating_1(face_id(m));
        choice_trials(n).pic_rating_B = pic_faces_rating_1(face_id(m+num_trials-1));
    end
    %%%landscape vs landscape choices%%%
    num_att_ratings = length(pic_landscapes_rating_1);
    num_trials = 30;
    perm_id_landscapes = Shuffle(1:num_att_ratings); %use attractiveness ratings
    landscape_id = perm_id_landscapes(1:(2*num_trials));
    for m = 1:num_trials
        n = length(choice_trials) + 1;
        choice_trials(n).image_type_A = 'Landscapes';
        choice_trials(n).image_type_B = 'Landscapes';
        choice_trials(n).image_category_A = pic_landscapes_category_1{landscape_id(m)};
        choice_trials(n).image_category_B = pic_landscapes_category_1{landscape_id(m+num_trials-1)};
        choice_trials(n).pic_shown_A = pic_landscapes_id_1{landscape_id(m)};
        choice_trials(n).pic_shown_B = pic_landscapes_id_1{landscape_id(m+num_trials-1)};
        choice_trials(n).rating_type = categories{1};
        choice_trials(n).pic_rating_A = pic_landscapes_rating_1(landscape_id(m));
        choice_trials(n).pic_rating_B = pic_landscapes_rating_1(landscape_id(m+num_trials-1));
    end
    outputname = fullfile(outputdir, [subjectnum '_choice_trial_structure.mat']);
    save(outputname,'choice_trials','num_trials','perm_id_faces','perm_id_landscapes','pic_faces_id_1','pic_faces_rating_1','pic_faces_category_1',...
        'pic_faces_id_2','pic_faces_rating_2','pic_faces_category_2','pic_faces_id_3','pic_faces_rating_3','pic_faces_category_3',...
        'pic_landscapes_id_1','pic_landscapes_rating_1','pic_landscapes_category_1','pic_landscapes_id_2','pic_landscapes_rating_2','pic_landscapes_category_2',...
        'pic_landscapes_id_3','pic_landscapes_rating_3','pic_landscapes_category_3');
catch
    q = lasterror
    Screen('CloseAll');
    cd(currentdir);
    
    keyboard
end
cd(currentdir);