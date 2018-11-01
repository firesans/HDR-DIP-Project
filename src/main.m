clear all;
close all;
clc;
%---------------------------------
path(path,MexFiles);
global ref_img_num;
global output_final_dir;
scene_name = 'BabyAtWindow'; % input folder name
output_folder = 'Results';
input_folder = 'Scenes';

global patch_size;
global minImgSize;              % lowest scale resolution size for min(w, h)
global maxIter;
global minIter;
global numScales;
global DSMethod;                % downsampling method
global vMax;                    % valid color values are between vMin and vMax
global vMin;                    %
global SEDilate;                % structure element used for dilating masks
global cores;                   % number of cores for multi-core processing (PatchMatch)
global algo;                    % PatchMatch algorithm type
global gamma;                   % gamma value used to tonemap the input images. We use gamma = 2.2.
global winIter;                 % a value between 0 to 1 which defines the percentage of scales where we do "limited search" (coarsest)
global winFac;                  % in case we use "limited search", winFac*sqrt(height*width) is the size of the search window
global cohFac;                  % weight of patches for the Coherency direction (in BDS). The weight for Completeness is 1-cohFac.
global isMask;                  % if true, search only in the invalid regions of reference (valid regions are not synthesized for more speed)
global isMBDS;                  % if true, MBDS with all images is performed, otherwise only one source is used at a time.
global completenessFac;         % a value between 0 to 1 which defines what percentage of scales do Completeness (coarsest)
global isMinNNF;

patch_size = 7;
minImgSize = 35;
maxIter = 50;
minIter = 5;
numScales = 10;
DSMethod = 'lanczos3';
vMax = 0.9;
vMin = 0.1;
SEDilate = strel('square', patch_size);
cores = 8;
gamma = 2.2;    % Do not change this number for the datasets in this package
winIter = 0.15;
winFac = 0.1;
cohFac = 0.7;
isMask = false;
isMBDS = true;
completenessFac = 0.5;
isMinNNF = false;
algo = 'cputiled';

ref_img_num = [];

fprintf('Loading input images ...\n');
output_final_dir = [output_folder, '/', scene_name];
input_dir = sprintf('%s/%s',input_folder,scene_name);
listOfFiles = dir([input_dir, '/*.tif']);     % Right now only gets tif as input
numImages = size(listOfFiles, 1);
expo_file_name = dir([input_dir, '/*.txt']);

mkdir(output_final_dir);
input_imgs = cell(1, numImages);

for i = 1 : numImages
    Path = sprintf('%s/%s', input_dir, listOfFiles(i).name);
    input_imgs{i} = imread(Path);
    input_imgs{i} = single(input_imgs{i})/255;
end

Path = sprintf('%s/%s', input_dir, expoFileName.name);
fid = fopen(Path);
 % convert exposure value to exposure time (2^exposureValue = exposureTime)
exposure_times = 2.^cell2mat(textscan(fid, '%f'));
fclose(fid);

ref_img_num = ceil((numImages+1)/2);

for i = 1 : numImages
    if (i ~= ref_img_num)
        outEachImgDir = sprintf('%s/Intermediate/%d', output_final_dir, i);
        mkdir(outEachImgDir);
    end
end

%-----------------------------------------------------------------
HDR_Reconstruction(input_imgs,exposure_times);
