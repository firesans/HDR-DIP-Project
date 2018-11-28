function [aligned_voted_images,aligned_images,H] = GenerateHDR(input_LDRs, exposure_times, scene_name)

global min_img_size;
global maxIter;
global minIter;
global num_scales;
global DSMethod;

tic;

[h,w,~] = size(input_LDRs{1});
minSizeDim = min(h, w);

if (num_scales ~= 1)
    resize_factor = (minSizeDim/min_img_size).^(1/(num_scales-1));
else
    resize_factor = 1;
end

iterStep = floor((maxIter - minIter) / (num_scales - 1));
if (isnan(iterStep) || iterStep == inf)
    iterStep = 0;
end

inputLDRsPyramid = cell(num_scales, 1);
for i = 1 : num_scales
    inputLDRsPyramid{i} = cellfun(@(x)max(0,min(1, imresize(x,1/resize_factor^(i-1),DSMethod))), input_LDRs, 'UniformOutput', false);
end

[aligned_voted_images,aligned_images,H] = HDRreconstruction(input_LDRs, inputLDRsPyramid, iterStep, resize_factor, exposure_times);
totalTime = toc;

output_write(aligned_voted_images, H, totalTime, scene_name);

end

function output_write(images, H, totalTime, sceneName)

global outFinalDir;
global maxImVal;
global type;

numImages = size(images, 2);

%save([outFinalDir,'/Timing'], 'totalTime');
hdrwrite(H, [outFinalDir,sprintf('/%s.hdr', sceneName)]);

for i = 1 : numImages
    if (strcmp(type, 'uint8'))
        imwrite(uint8(images{i}*(maxImVal)), [outFinalDir,sprintf('/%s-l%d.tif', sceneName, i)]);
    elseif (strcmp(type, 'uint16'))
        imwrite(uint16(images{i}*(maxImVal)), [outFinalDir,sprintf('/%s-l%d.tif', sceneName, i)]);
    end
end
end
