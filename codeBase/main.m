clear;
clc;
close all;

path(path, 'MexFiles');
path(path, 'src');

global refImgNum;   % Reference image number

sceneName = 'OwnDataSet'
outFinalFolder = 'Results';
inputSceneFolder = 'Scenes';

parameters();
refImgNum = [];

[inputLDRs exposureTimes numImages] = read_dataset(inputSceneFolder, sceneName, outFinalFolder);


[alignedVotedImages alignedImages HDR] = GenerateHDR(inputLDRs, exposureTimes, sceneName);
warning on;
