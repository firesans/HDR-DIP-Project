function parameters()

global patch_size; global min_img_size; global maxIter;
global minIter; global num_scales; global DSMethod;
global saveIntermediateResults; global v_max;  global v_min;
global algo; global SE_dilate; global gamma;  global winIter;
global winFac; global cohFac; global isMask; global isMBDS;
global completeness_factor;  global isMinNNF;

patch_size = 7;
min_img_size = 35;
maxIter = 40;
minIter = 5;
num_scales = 2;
DSMethod = 'lanczos3';
v_max = 0.9;
v_min = 0.1;
SE_dilate = strel('square', patch_size);
algo = 'cputiled';

gamma = 2.2;    % Do not change this number for the datasets in this package
winIter = 0.15;
winFac = 0.1;
cohFac = 0.7;
saveIntermediateResults = false;
isMinNNF = false;
isMask = false;
isMBDS = true;
completeness_factor = 0.7;
end
