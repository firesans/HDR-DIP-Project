function [sourcePyramid, sourceMaskPyramid] = GetSourcePyramid(inputLDRsPyramid, exposure_times, curRefImgNum, indCurImgs)

global num_scales;
global DSMethod;
global v_min;
global v_max;
global isMBDS;

numSourceImgs = size(exposure_times, 1); % Number of all the source images
numImgs = length(indCurImgs); % Number of output images
sourcePyramid = cell(1, numImgs);
% This mask is used for the completeness direction to mask out the regions that are not useful.
sourceMaskPyramid = cell(1, numImgs);

for i = indCurImgs
    if (i < curRefImgNum)
        if (isMBDS)
            % Only the images darker than the current image have valid information
            inds = i : -1: 1;
        else
            inds = i;
        end

        for j = inds
            sourceMaskAux = double(inputLDRsPyramid{1}{i} > max(convert_ldr(v_max, exposure_times(curRefImgNum), exposure_times(i)), v_min));
            sourceMaskPyramid{i-indCurImgs(1)+1}{1}{i-j+1} = GetSourceHoleMask(sourceMaskAux);
            for k = 1 : num_scales
                sourcePyramid{i-indCurImgs(1)+1}{k}{i-j+1} = convert_ldr(inputLDRsPyramid{k}{j}, exposure_times(j), exposure_times(i));
                if (k ~= 1)
                    sourceMaskPyramid{i-indCurImgs(1)+1}{k}{i-j+1} = GetSourceHoleMask(max(0,min(1, imresize(sourceMaskAux,...
                        size(sum(inputLDRsPyramid{k}{j},3)), DSMethod))));
                end
            end
        end
    elseif (i > curRefImgNum)
        if (isMBDS)
            % Only the images brighter than the current image have valid information
            inds = i : numSourceImgs;
        else
            inds = i;
        end

        for j = inds
            sourceMaskAux = double(inputLDRsPyramid{1}{i} < min(convert_ldr(v_min, exposure_times(curRefImgNum), exposure_times(i)), v_max));
            sourceMaskPyramid{i-indCurImgs(1)+1}{1}{j} = GetSourceHoleMask(sourceMaskAux);
            for k = 1 : num_scales
                sourcePyramid{i-indCurImgs(1)+1}{k}{j-i+1} = convert_ldr(inputLDRsPyramid{k}{j}, exposure_times(j), exposure_times(i));
                if (k ~= 1)
                    sourceMaskPyramid{i-indCurImgs(1)+1}{k}{j-i+1} = GetSourceHoleMask(max(0,min(1, imresize(sourceMaskAux,...
                        size(sum(inputLDRsPyramid{k}{j},3)), DSMethod))));
                end
            end
        end
    else
        for k = 1 : num_scales
            sourcePyramid{i-indCurImgs(1)+1}{k}{1} = inputLDRsPyramid{k}{curRefImgNum};
        end
    end
end
end

function holeMask = GetSourceHoleMask(input)

global patch_size;
holeMask = padarray(input, [floor(patch_size/2) floor(patch_size/2)], 0, 'post');
holeMask = holeMask(ceil(patch_size/2):end, ceil(patch_size/2):end, :);
holeMask = repmat(sum(holeMask,3),[1,1,3]);
holeMask = 1 - double(holeMask > 0);

end
