function [alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, v_maxPyramid, v_minPyramid, lowHoleMaskPyramid, highHoleMaskPyramid, targets,...
    sourcePyramids, sourceMaskPyramids] = Initialization(curRefImg, inputLDRsPyramid, resize_factor, exposure_times, curRefImgNum, indImgs, status)

global num_scales;
global v_max;
global v_min;
global isMask;
global DSMethod;

if (~exist('status', 'var'))
    status = 'both';
end

numImages = length(indImgs);

targets = cell(1, numImages);
for i = indImgs
    if (i ~= curRefImgNum)
        targets{i-indImgs(1)+1} = convert_ldr(curRefImg, exposure_times(curRefImgNum), exposure_times(i));
        targets{i-indImgs(1)+1} = max(0,min(1, imresize(targets{i-indImgs(1)+1}, 1/resize_factor^(num_scales-1), DSMethod)));
    end
end

alphaPyramid = cell(num_scales, 1);
alphaPlusPyramid = cell(num_scales, 1);
alphaMinusPyramid = cell(num_scales, 1);
v_maxPyramid = cell(num_scales, 1);
v_minPyramid = cell(num_scales, 1);

% These are the masks on the reference image to speed up the search process.
% Only these regions are searched and voted
lowHoleMaskPyramid = cell(num_scales, 1);
highHoleMaskPyramid = cell(num_scales, 1);


alphaPyramid{1} = alpha_weights(curRefImg, status);
alphaPlusPyramid{1} = double(curRefImg < v_min);
alphaMinusPyramid{1} = double(curRefImg > v_max);

v_maxPyramid{1} = double(curRefImg > v_max);
v_minPyramid{1} = double(curRefImg < v_min);

% if(isMask)
%     lowHoleMaskPyramid{1} = GetHoleMask(v_maxPyramid{1});
%     highHoleMaskPyramid{1} = GetHoleMask(v_minPyramid{1});
% end

for i = 2 : num_scales
    alphaPyramid{i} = max(0,min(1, imresize(alphaPyramid{1}, 1/resize_factor^(i-1), DSMethod)));
    alphaPlusPyramid{i} = max(0,min(1, imresize(alphaPlusPyramid{1}, 1/resize_factor^(i-1), DSMethod)));
    alphaMinusPyramid{i} = max(0,min(1, imresize(alphaMinusPyramid{1}, 1/resize_factor^(i-1), DSMethod)));

    v_maxPyramid{i} = max(0,min(1, imresize(v_maxPyramid{1}, 1/resize_factor^(i-1), DSMethod)));
    v_minPyramid{i} = max(0,min(1, imresize(v_minPyramid{1}, 1/resize_factor^(i-1), DSMethod)));

%     if(isMask)
%         lowHoleMaskPyramid{i} = GetHoleMask(v_maxPyramid{i});
%         highHoleMaskPyramid{i} = GetHoleMask(v_minPyramid{i});
%     end

    v_maxPyramid{i} = v_max * v_maxPyramid{i};
    v_minPyramid{i} = 1 - (1 - v_min) * v_minPyramid{i};
end

v_maxPyramid{1} = v_max * v_maxPyramid{1};
v_minPyramid{1} = 1 - (1 - v_min) * v_minPyramid{1};

[sourcePyramids, sourceMaskPyramids] = GetSourcePyramid(inputLDRsPyramid, exposure_times, curRefImgNum, indImgs);

end
