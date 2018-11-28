function [aligned_voted_images,aligned_images,H] = HDRreconstruction(input_LDRs, inputLDRsPyramid, iterStep, resize_factor, exposure_times)

global ref_img_num;
numImages = size(input_LDRs, 2);

status = CheckStatus(numImages);
[alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, vMaxPyramid, vMinPyramid, lowHoleMaskPyramid, highHoleMaskPyramid, targets, ...
    sourcePyramids, sourceMaskPyramids] = Initialization(input_LDRs{ref_img_num}, inputLDRsPyramid, resize_factor, exposure_times,...
    ref_img_num, 1:numImages, status);


[aligned_voted_images,aligned_images,H] = reference_match(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid,...
    alphaMinusPyramid, vMaxPyramid, vMinPyramid, iterStep, exposure_times, lowHoleMaskPyramid, highHoleMaskPyramid, ref_img_num, 1:numImages);
end

function status = CheckStatus(numImages)

global ref_img_num;

if (ref_img_num == 1)
    status = 'high';
elseif (ref_img_num == numImages)
    status = 'low';
else
    status = 'both';
end

end
