# fmri-extract-HCP-mask
This script lets you easily extract a specific binary mask file from the HCP-MMP1.0 parcellation atlas. 

## How to use
This is a simple script that takes the volumetric map of the Human Connectome Project MMP1.0 parcellation (included here), extracts a desired ROI, and saves it as a binary mask file. The volumetric map is in MNI space, and so will the resulting mask files. 
1) Go to mmn.csv file. Look up which ROI you are interested in, and write down the ROI code (num.roi column)
2) Open the create_HCP_mask.m file
3) Change the folder name to where you downloaded and saved the HCP .nii file
4) Enter the ROI code
5) Run 

## Sources
The files used here are not mine, all credits to the creators:
- volumetric HCP-MMN1.0 map: https://figshare.com/articles/dataset/HCP-MMP1_0_projected_on_MNI2009a_GM_volumetric_in_NIfTI_format/3501911
- ROI table: https://github.com/mcfreund/stroop-rsa/blob/master/out/atlases/mmp.csv

## Requirements
- Matlab + SPM12 installed

## Bugs / Improvements
If you find bugs in this script or have suggestions for improvement, please report both here https://github.com/davidwisniewski/fmri-extract-HCP-mask/issues

## Contact
david.wisniewski@ugent.be

