%{
This script extracts a single ROI mask from the HCP mask file
Just look up the code for the ROI you are interested in in the mmp.csv
table, give the script the correct folder and run.
%}

function extract_HCP_mask(roicodes, HCP_path, output_path)

    %% FLAGS
    
    % create output folder if it does not exist
    if ~exist(output_path)
        mkdir(output_path)
    end

    % assuming you did not change the HCPO mmmaks filename, just leave this as
    % it is
    hcp_fname = 'HCP-MMP1_on_MNI152_ICBM2009a_nlin.nii,1';
    % same applies here, don't change unless you changed the filename of the
    % table file
    table_fname = 'mmp.csv';
    for r = roicodes
        %% Extract the ROI label
        % we automatically extract the ROI label from the table file
        fid = fopen (sprintf('%s%s',HCP_path, table_fname));
        out = textscan(fid,'%s%s%s%s%s%s','Delimiter',',','Headerlines',1);
        out_label = out{6}{r}(2:end-1); % this is the label we will use to name the output mask file
        % clean up the label string: remove all spaces
        out_label= out_label(find(~isspace(out_label)));
        % remove dots . and plusses +, this will mess up saving the file
        out_label = regexprep(out_label,'[.+]','');

        %% Generate binary mask file
        clear matlabbatch
        matlabbatch{1}.spm.util.imcalc.input = {sprintf('%s%s',HCP_path, hcp_fname)};
        matlabbatch{1}.spm.util.imcalc.output = sprintf('%s.nii',out_label);
        matlabbatch{1}.spm.util.imcalc.outdir = {output_path};
        matlabbatch{1}.spm.util.imcalc.expression = sprintf('(i1<%d)&(i1>%d)',r+.1,r-.1); % we just select the chosen ROI here
        matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        spm_jobman('run',matlabbatch);
        clear matlabbatch;
        fprintf(['------ ' sprintf('%s.nii',out_label) ' written to folder------\n'])
    end
end

