function Score_Surveys_jsy_dvs_cgc_correctedAgain()

try
    
    %%%directories%%%
    %cwd = pwd;
    %base_dir = fullfile('/Users','jakeyoung','Projects','SocReward.02');
    %base_dir = fullfile('M:','SocReward.02');   %cgc:changed to win path
    %pilot_dir = fullfile(base_dir, 'Pilot');
    %main_dir = fullfile(base_dir,'Analysis','Behavioral','SurveyData');
    %out_dir = fullfile(base_dir, 'Analysis','Behavioral','SurveyData', 'SurveyData_Scored');
    
    main_dir=pwd;
    out_dir=fullfile(main_dir, 'SurveyData_Scored_avu');
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
      
   %cgc removed messed up reverse scoring for Survey1 (TEPS)here
    
    for i = 2:size(Survey2,2) %scoring for the Interpersonality Reactivity Index needs to be fixed and broken down into Fantasy-empathy, Perspective-taking, Empathic conern, and personal distress scales
        
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
        if i == 3 || i == 23
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
    
     for n = 1 %scoring for TEPS
        k=num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
       
        %cgc: Added reverse scoring of number 7:
        %This reverses number 7, "Don't look forward to eating out..."
        Survey1Orig=Survey1; %Keep unreversed copy 
        Survey1OrigItem=Survey1Orig(:,7);
        Survey1RevItem=Survey1Orig(:,7);
        Survey1RevItem(Survey1OrigItem==1)=6;
        Survey1RevItem(Survey1OrigItem==2)=5;
        Survey1RevItem(Survey1OrigItem==3)=4;
        Survey1RevItem(Survey1OrigItem==4)=3;
        Survey1RevItem(Survey1OrigItem==5)=2;
        Survey1RevItem(Survey1OrigItem==6)=1;
        Survey1=[Survey1(:,1:6), Survey1RevItem, Survey1(:,8:19)];  
        
        x = [2 4 5 7 9 10 12 14 16 19]; %Anticipatory % cgc corrected #s 
        y = [3 6 8 11 13 15 17 18]; %Consummatory % cgc corrected #s
        for i = 1:num_sub
            eval(['Anticipatory_' k '(i,1) = sum(Survey' k '(i,x));'])
            eval(['Consummatory_' k '(i,1) = sum(Survey' k '(i,y));'])
        end
        
        %%%save data%%%
        save_data_name = ['Scored_TEPS'];
        sname = fullfile(out_dir,save_data_name);
        save(sname, 'Anticipatory_1','Consummatory_1');
    end
    
    
    for n = 3 %scoring for BIS/BAS
        k=num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
        x = [4 10 13 22]; %BAS Drive
        y = [6 11 16 21]; %BAS Fun-Seeking
        z = [5 8 15 19 24]; %BAS Reward-Responsiveness
        a = [3 9 14 17 20 23 25]; %BIS
        for i = 1:num_sub
            eval(['BAS_Drive_' k '(i,1) = sum(Survey' k '(i,x));'])
            eval(['BAS_Fun_Seeking_' k '(i,1) = sum(Survey' k '(i,y));'])
            eval(['BAS_Reward_Responsiveness_' k '(i,1) = sum(Survey' k '(i,z));'])
            eval(['BIS_' k '(i,1) = sum(Survey' k '(i,a));'])
        end
        %%%save data%%%
        save_data_name = ['Scored_BIS-BAS'];
        sname = fullfile(out_dir,save_data_name);
        save(sname, 'BAS_Drive_3','BAS_Fun_Seeking_3','BAS_Reward_Responsiveness_3','BIS_3');
    end
    
    for n = 2 %scoring for IRI - added by jsy 8/26/12
        k=num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
        x = [4 9 12 16 22 26 29]; %Perspective-Taking Scale
        y = [2 6 8 13 17 24 27]; %Fantasy-Empathy Scale
        z = [3 5 10 15 19 21 23]; %Empathic Concern Scale
        a = [7 11 14 18 20 25 28]; %Personal Distress Scale
        for i = 1:num_sub
            eval(['IRI_Perspective-Taking_' k '(i,1) = sum(Survey' k '(i,x));'])
            eval(['IRI_Fantasy-Empathy Scale_' k '(i,1) = sum(Survey' k '(i,y));'])
            eval(['IRI_Empathic Concern_' k '(i,1) = sum(Survey' k '(i,z));'])
            eval(['IRI_Personal Distress_' k '(i,1) = sum(Survey' k '(i,a));'])
        end
        %%%save data%%%
        save_data_name = ['Scored_BSSS'];
        sname = fullfile(out_dir,save_data_name);
        save(sname, 'BSSS_Experience_Seeking_4','BSSS_Boredom_Susceptibility_4','BSSS_Thrill_Adventure_Seeking_4','BSSS_Disinhibition_4');
    
        for n = 4 %scoring for BSSS
        k=num2str(n);
        eval(['s = size(Survey' k ');'])
        num_sub = s(1);
        x = [2 6]; %Experience Seeking
        y = [3 7]; %Boredom susceptibility
        z = [4 8]; %Thrill and Adventure Seeking
        a = [5 9]; %Disinhibition
        for i = 1:num_sub
            eval(['BSSS_Experience_Seeking_' k '(i,1) = sum(Survey' k '(i,x));'])
            eval(['BSSS_Boredom_Susceptibility_' k '(i,1) = sum(Survey' k '(i,y));'])
            eval(['BSSS_Thrill_Adventure_Seeking_' k '(i,1) = sum(Survey' k '(i,z));'])
            eval(['BSSS_Disinhibition_' k '(i,1) = sum(Survey' k '(i,a));'])
        end
        %%%save data%%%
        save_data_name = ['Scored_BSSS'];
        sname = fullfile(out_dir,save_data_name);
        save(sname, 'BSSS_Experience_Seeking_4','BSSS_Boredom_Susceptibility_4','BSSS_Thrill_Adventure_Seeking_4','BSSS_Disinhibition_4');
    end
    for i =2:size(Survey5,2)
        if i==2 || i==8 || i==9 || i==10 || i==11 || i==13 || i==14 || i==16 || i==21 || i==30 || i==31 %questions that need to be reverse scored in the BIS-11
            dummy = Survey5(:,i);
            dummy(find(Survey5(:,i)==1)) = 4;
            dummy(find(Survey5(:,i)==2)) = 3;
            dummy(find(Survey5(:,i)==3)) = 2;
            dummy(find(Survey5(:,i)==4)) = 1;
            Survey3(:,i) = dummy;
            clear dummy
        end
    end
    
    
    for i = 2:size(Survey6,2) %scoring the Autism Scale Survey
        if i==2 || i==3 || i==5 || i==6 || i==7 || i==8 || i==10 || i==13 || i==14 || i==17 || i==19 || i==20 || i==21 || i==22 || i==23 || i==24 || i==27 || i==34 || i==36 || i==40 || i==42 || i==43 || i==44 || i==46 || i==47
            dummy = Survey6(:,i);
            dummy(find(Survey6(:,i)==1)) = 1; %making 'definitely agree' and 'slightly agree' recieve a score of 1
            dummy(find(Survey6(:,i)==2)) = 1;
            dummy(find(Survey6(:,i)==3)) = 0;
            dummy(find(Survey6(:,i)==4)) = 0;
            Survey6(:,i) = dummy;
        end
        if i==4 || i==9 || i==11 || i==12 || i==15 || i==16 || i==18 || i==25 || i==26 || i==28 || i==29 || i==30 || i==31 || i==32 || i==33 || i==35 || i==37 || i==38 || i==39 || i==41 || i==44 || i==48 || i==49 || i==50 || i==51
            dummy = Survey6(:,i);
            dummy(find(Survey6(:,i)==1)) = 0; %making 'definitely disagree' and 'slightly disagree' recieve a score of 1
            dummy(find(Survey6(:,i)==2)) = 0;
            dummy(find(Survey6(:,i)==3)) = 1;
            dummy(find(Survey6(:,i)==4)) = 1;
            Survey6(:,i) = dummy;
            clear dummy
        end
    end
    
    
    for n = [1 2 4 6] %number of surveys minus the BIS-11 and BIS/BAS (scored using subcategories)
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
        x = [6 10 12 21 29]; %rows needed to score each individual first order factor
        y = [3 4 5 18 20 23 26];
        z = [2 8 9 13 14 15];
        a = [11 16 19 28 30];
        b = [17 22 24 31];
        c = [7 25 27];
        
        r = [7 6 10 12 21 25 27 29]; %rows needed to score each individual second order factor
        s = [3 4 5 17 18 20 22 23 24 26 31];
        t = [2 8 9 11 13 14 15 16 19 28 30];
        
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

