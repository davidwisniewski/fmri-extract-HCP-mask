%{
This function extracts single/multiple ROI masks from the HCP mask file
Just look up the code for the ROI you are interested in in the mmp.csv
table, call the function with the correct folder and run. 

Operation:
-'single' = extract one ROI per each roi code
-'sum' = combined all roi codes into one big roi

Laterality
Choose whether you want left, right, or bilateral ROIs to be extracted
-'l' = left
-'r' = right
-'b' = bilateral

Example calls:
1) extract single ROI (roi number 2) into default path
extract_HCP_mask(2, 'C:\root\fmri-extract-HCP-mask\', 'D:\root\fmri-extract-HCP-mask\','single','b')
2) extract multiple ROIs (roi numbers 2, 4, 8) into new folder (don't
forget the '\' at the end of the path!
extract_HCP_mask([2 4 8], 'C:\root\fmri-extract-HCP-mask\', 'D:\root\fmri-extract-HCP-mask\NEWFOLDER\','single','b')
3) combine multiples ROIs (roi numbers 2, 4, 8) into one single ROI, and
save it in a new folder (don't forget the '\' at the end!)
extract_HCP_mask([4 21 45], 'D:\GitHub\fmri-extract-HCP-mask\', 'D:\GitHub\fmri-extract-HCP-mask\NEWFOLDER\','sum','b')

%}

function extract_HCP_mask(roicodes, HCP_path, output_path, operation, laterality)

    %% PREPARATION

    % create output folder if it does not exist
    if ~exist(output_path)
        mkdir(output_path)
    end

    % assuming you did not change any filenammes, just leave this as
    % this just points to the lookup table
    table_fname = 'mmp.csv';

    for r = 1:length(roicodes)
        %% Extract the ROI label
        % we automatically extract the ROI label from the table file
        fid = fopen (sprintf('%s%s',HCP_path, table_fname));
        out = textscan(fid,'%s%s%s%s%s%s','Delimiter',',','Headerlines',1);
        out_label = out{6}{roicodes(r)}(2:end-1); % this is the label we will use to name the output mask file
        % clean up the label string: remove all spaces
        out_label= out_label(find(~isspace(out_label)));
        % remove dots . and plusses +, this will mess up saving the file
        out_label = regexprep(out_label,'[.+]','');

        %% Generate binary mask file
        clear matlabbatch
        % select either bilateral, left or right roi
        if laterality=='b'
            matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, 'HCP-MMP1_on_MNI152_ICBM2009a_nlin.nii,1')};
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_bilateral.nii',out_label);
        elseif laterality=='l'
            matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, 'HCP-MMP1_on_MNI152_ICBM2009a_nlin_left.nii,1')};
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_left.nii',out_label);
        elseif laterality=='r'
            matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, 'HCP-MMP1_on_MNI152_ICBM2009a_nlin_right.nii,1')};
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_right.nii',out_label);
        end
        matlabbatch{1}.spm.util.imcalc.outdir = {output_path};
        matlabbatch{1}.spm.util.imcalc.expression = sprintf('(i1<%d)&(i1>%d)',roicodes(r)+.1,roicodes(r)-.1); % we just select the chosen ROI here 
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch); 
        if strcmp(operation,'single')
            fprintf(['------ ' sprintf('%s.nii',out_label) ' written to folder------\n'])
        else
            sum_inputs(r) = {sprintf('%s%s',output_path, matlabbatch{1}.spm.util.imcalc.output)};
        end
        
    end
    
    
    if strcmp(operation,'sum')
        out_label = strrep(strcat(num2str(roicodes)),' ','');
        clear matlabbatch
        matlabbatch{1}.spm.util.imcalc.input = sum_inputs';
        if laterality=='b'
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_sum_bilateral.nii',out_label);
        elseif laterality=='l'
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_sum_left.nii',out_label);
        elseif laterality=='r'
            matlabbatch{1}.spm.util.imcalc.output = sprintf('%s_sum_right.nii',out_label);
        end
        matlabbatch{1}.spm.util.imcalc.outdir = {output_path};
        matlabbatch{1}.spm.util.imcalc.expression = 'sum(X)'; % we just select the chosen ROI here
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch);
    end

end

