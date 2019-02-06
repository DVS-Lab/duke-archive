function Score_Surveys_jsy_dvs()

try
    
    %%%directories%%%
    cwd = pwd;
    %base_dir = fullfile('/Users','jakeyoung','Projects','SocReward.02');
    base_dir = fullfile('/Volumes','Huettel','SocReward.02');
    %pilot_dir = fullfile(base_dir, 'Pilot');
    main_dir = fullfile(base_dir,'Analysis','Behavioral','SurveyData');
    out_dir = fullfile(base_dir, 'Analysis','Behavioral','SurveyData', 'SurveyData_Scored');
    if ~exist(out_dir,'dir')
        mkdir(out_dir);
    end
    
    %%%load data%%%
    data_file = fullfile(main_dir,'SurveyData_Scanner.mat');
    load(data_file);
    
    q = 1:6;
    t = num2str(q);
    
    
    for n = 1:6 %number of surveys
        k = num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
        for i = 1:num_sub
            eval(['raw_score' k '(i,1) = sum(Survey' k '(i,2:end));'])
        end
    end
    
    
    for i = 2:size(Survey1,2)
        if i == 6
            dummy = Survey1(:,i);
            dummy(find(Survey1(:,i)==2)) = 4;
            dummy(find(Survey1(:,i)==1)) = 5;
            dummy(find(Survey1(:,i)==4)) = 2;
            dummy(find(Survey1(:,i)==5)) = 1;
            Survey1(:,i) = dummy;
            clear dummy
        end
    end
    
    
    for i = 2:size(Survey2,2)
        
        if i == 3 || i == 4 || i == 7 || i == 12 || i == 13 || i == 14 || i == 15 || i == 18 || i == 19
            dummy = Survey2(:,i);
            dummy(find(Survey2(:,i)==2)) = 4;
            dummy(find(Survey2(:,i)==1)) = 5;
            dummy(find(Survey2(:,i)==4)) = 2;
            dummy(find(Survey2(:,i)==5)) = 1;
            Survey2(:,i) = dummy;
            clear dummy
        end
        
    end
    
    for i = 2:size(Survey3,2)
        if i == 2 || i == 22
        else
            dummy = Survey3(:,i);
            dummy(find(Survey3(:,i)==2)) = 4;
            dummy(find(Survey3(:,i)==1)) = 5;
            dummy(find(Survey3(:,i)==4)) = 2;
            dummy(find(Survey3(:,i)==5)) = 1;
            Survey3(:,i) = dummy;
            clear dummy
        end
    end
    
    %what I'm adding to her script
    
    for ii =2:size(Survey5,2)
        i = ii - 1;
        if i==1 || i==7 || i==8 || i==9 || i==10 || i==12 || i==13 || i==15 || i==20 || i==29 || i==30 %questions that need to be reverse scored in the BIS-11
            dummy = Survey5(:,i);
            dummy(find(Survey5(:,ii)==1)) = 4;
            dummy(find(Survey5(:,ii)==2)) = 3;
            dummy(find(Survey5(:,ii)==3)) = 2;
            dummy(find(Survey5(:,ii)==4)) = 1;
            Survey3(:,i) = dummy;
            clear dummy
        end
    end
    
    
    for ii = 2:size(Survey6,2) %scoring the Autism Scale Survey
        i = ii - 1;
        if i==1 || i==2 || i==4 || i==5 || i==6 || i==7 || i==9 || i==12 || i==13 || i==16 || i==18 || i==19 || i==20 || i==21 || i==22 || i==23 || i==26 || i==33 || i==35 || i==39 || i==41 || i==42 || i==43 || i==45 || i==46
            dummy = Survey6(:,i);
            dummy(find(Survey6(:,ii)==1)) = 1; %making 'definitely agree' and 'slightly agree' recieve a score of 1
            dummy(find(Survey6(:,ii)==2)) = 1;
            dummy(find(Survey6(:,ii)==3)) = 0;
            dummy(find(Survey6(:,ii)==4)) = 0;
            Survey6(:,i) = dummy;
        end
        if i==3 || i==8 || i==10 || i==11 || i==14 || i==15 || i==17 || i==24 || i==25 || i==27 || i==28 || i==29 || i==30 || i==31 || i==32 || i==34 || i==36 || i==37 || i==38 || i==40 || i==44 || i==47 || i==48 || i==49 || i==50
            dummy = Survey6(:,i);
            dummy(find(Survey6(:,ii)==1)) = 0; %making 'definitely disagree' and 'slightly disagree' recieve a score of 1
            dummy(find(Survey6(:,ii)==2)) = 0;
            dummy(find(Survey6(:,ii)==3)) = 1;
            dummy(find(Survey6(:,ii)==4)) = 1;
            Survey6(:,i) = dummy;
            clear dummy
        end
    end
    
    
    for n = [1 2 3 4 6] %number of surveys minus the BIS-11 (which is scored using 6 first order factors and 3 second order factors)
        k = num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
        for i = 1:num_sub
            eval(['reverse_corrected_score' k '(i,1) = sum(Survey' k '(i,2:end));'])
        end
    end
    
    %%%save data%%%
    save_data_name = ['Scored_Survey_1'];
    sname = fullfile(out_dir,save_data_name);
    save(sname, 'reverse_corrected_score1');
    
    save_data_name = ['Scored_Survey_2'];
    sname = fullfile(out_dir,save_data_name);
    save(sname, 'reverse_corrected_score2');
    
    save_data_name = ['Scored_Survey_3'];
    sname = fullfile(out_dir,save_data_name);
    save(sname, 'reverse_corrected_score3');
    
    save_data_name = ['Scored_Survey_4'];
    sname = fullfile(out_dir,save_data_name);
    save(sname, 'reverse_corrected_score4');
    
    save_data_name = ['Scored_Survey_6'];
    sname = fullfile(out_dir,save_data_name);
    save(sname, 'reverse_corrected_score6');
    
    
    for n = 5 %scoring for BIS-11 first and second order factors separately
        k=num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
        x = [5 9 11 20 28]; %rows needed to score each individual first order factor
        y = [2 3 4 17 19 22 25];
        z = [1 7 8 12 13 14];
        a = [10 15 18 27 29];
        b = [16 21 23 30];
        c = [6 24 26];
        
        r = [6 5 9 11 20 24 26 28]; %rows needed to score each individual second order factor
        s = [2 3 4 16 17 19 21 22 23 25 30];
        t = [1 7 8 10 12 13 14 15 18 27 29];
        
        for i = 1:num_sub
            eval(['Attention_score_' k '(i,1) = sum(Survey' k '(i,x));'])
            eval(['Motor_score_' k '(i,1) = sum(Survey' k '(i,y));'])
            eval(['Self_Control_score_' k '(i,1) = sum(Survey' k '(i,z));'])
            eval(['Congitive_Complexity_score_' k '(i,1) = sum(Survey' k '(i,a));'])
            eval(['Perseverance_score_' k '(i,1) = sum(Survey' k '(i,b));'])
            eval(['Cognitive_Instability_score_' k '(i,1) = sum(Survey' k '(i,c));'])
            eval(['Attentional_Impulsiveness_score_' k '(i,1) = sum(Survey' k '(i,r));'])
            eval(['Motor_Impulsiveness_score_' k '(i,1) = sum(Survey' k '(i,s));'])
            eval(['Attention_score_' k '(i,1) = sum(Survey' k '(i,t));'])
        end
        
        %%%save data%%%
        save_data_name = ['Scored_BIS-11'];
        sname = fullfile(out_dir,save_data_name);
        save(sname, 'Attention_score_5','Motor_score_5','Self_Control_score_5','Congitive_Complexity_score_5','Perseverance_score_5'...
            ,'Cognitive_Instability_score_5','Attentional_Impulsiveness_score_5','Motor_Impulsiveness_score_5','Attention_score_5');
    end
    cd(cwd);
    
catch ME
    fprintf('\n%s\ncheck line %d\n',ME.message,ME.stack.line);
    keyboard
end

