function compare_maps_rsn_corr_1112(~)

maindir = pwd;

groupicadirs = {'Framing_Rest_firstgroup_taskorder_25dim','Framing_Rest_secondgroup_taskorder_25dim',...
    'MID_Rest_firstgroup_taskorder_25dim', 'MID_Rest_secondgroup_taskorder_25dim', 'Risk_Rest_firstgroup_taskorder_25dim'...
    'Risk_Rest_secondgroup_taskorder_25dim'};

map_sum = {'map_summary_Framing_Rest_firstgroup_taskorder_25dim.txt', 'map_summary_Framing_Rest_secondgroup_taskorder_25dim.txt', ...
    'map_summary_MID_Rest_firstgroup_taskorder_25dim.txt', 'map_summary_MID_Rest_secondgroup_taskorder_25dim.txt', ...
    'map_summary_Risk_Rest_firstgroup_taskorder_25dim.txt', 'map_summary_Risk_Rest_secondgroup_taskorder_25dim.txt'};

ind_all = [];
for i=1:numel(map_sum)
    lines = fopen(map_sum{i});
    fid = textscan(lines, '%s%s%s%s%s%s%s%s%s%s%s', 'headerlines', 1);
    fclose(lines);
    data = [fid{2} fid{3} fid{4} fid{5} fid{6} fid{7} fid{8} fid{9} fid{10} fid{11}];
    data_mat = str2double(data);
    for j=1:10
        [val ind] = max(data_mat(:,j));
        ind_all= [ind_all; ind];
    end
    rsn_nums(i,:)=ind_all((10*i-9):10*i); %results in matrix. each column contains the 6 groups' index of an (the same) RSN - will compare in heatmap
end

for z=1:10
    for n = 1:6 %for each network
        for n2 = 1:6
            status = 1; %keep doing it till you get it right, motherfucker.
            while status
                g_str = sprintf('%04d',n-1);
                g_str2 = sprintf('%04d',n2-1);
                g1 = fullfile(groupicadirs(n), ['IC_' g_str '.nii.gz']);
                g2 = fullfile(groupicadirs(n2), ['IC_' g_str2 '.nii.gz']);
                g1_mask = fullfile(groupicadirs(n), 'mask.nii.gz');
                g2_mask = fullfile(groupicadirs(n2), 'mask.nii.gz');
                sys_cmd = sprintf('sh compute_spatialcorr_combinedmask.sh %s %s %s %s',g1, g2, g1_mask, g2_mask);
                [status,spatial_corr] = system(sys_cmd);
                if status
                    fprintf('something got fucked up looking at RSN %d on IC %d\nrecalculating...\n\n',i,v);
                end
                spatial_corr_num = str2double(spatial_corr);
                if isnan(spatial_corr_num)
                    disp('still failed because of nans\nrevalculating..\n\n')
                    status = 1;
                end
            end
            delete('demeaned*');
            %corr_mat(n,z) = spatial_corr_num;
        end
    end
    fprintf('%3.3f%% completed...\n',100*(v/nvols));
end
fname = sprintf('map_summary_%s.txt',groupica);
fid = fopen(fname,'w');
fprintf(fid,'ICNUM \tRSN01 \tRSN02 \tRSN03 \tRSN04 \tRSN05 \tRSN06 \tRSN07 \tRSN08 \tRSN09 \tRSN10\n');
for v = 1:nvols
    fprintf(fid,'%02d \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f \t%3.3f\n', v, corr_mat(v,:));
end
fclose(fid);
