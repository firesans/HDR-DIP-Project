function [inputImgs,exposure_times,numImages] = read_dataset(input_scene_folder, sceneName, out_final_folder)

global outFinalDir;
global ref_img_num;
global maxImVal;
global type;
global saveIntermediateResults;

outFinalDir = [out_final_folder, '/', sceneName, '_', 'high'];
inputFolder = sprintf('%s/%s', input_scene_folder, sceneName);

expoFileName = dir([inputFolder, '/*.txt']);
listOfFiles = dir([inputFolder, '/*.tif']);     % Right now only gets tif as input

numImages = size(listOfFiles, 1);

if (numImages < 2)
    error('Number of input images should be greater than 1');
end

mkdir(outFinalDir);

inputImgs = cell(1, numImages);
for i = 1 : numImages
    Path = sprintf('%s/%s', inputFolder, listOfFiles(i).name);
    inputImgs{i} = imread(Path);

    type = class(inputImgs{i});
    if (strcmp(type, 'uint8'))
        maxImVal = 255;
    elseif (strcmp(type, 'uint16'))
        maxImVal = 2^16 - 1;
    end

    inputImgs{i} = single(inputImgs{i})/maxImVal;
end

Path = sprintf('%s/%s', inputFolder, expoFileName.name);

fid = fopen(Path);
exposure_times = 2.^cell2mat(textscan(fid, '%f'));   % convert exposure value to exposure time (2^exposureValue = exposureTime)
fclose(fid);

if (length(exposure_times) ~= numImages)
    error('Number of exposure times does not match the number of images');
end

if (isempty(ref_img_num))
    ref_img_num = ceil((numImages / 2) + 0.5);
end

if (saveIntermediateResults)
    for i = 1 : numImages
        if (i ~= ref_img_num)
            outEachImgDir = sprintf('%s/Intermediate/%d', outFinalDir, i);
            mkdir(outEachImgDir);
        end
    end
end

end
