function [aligned_voted_images, aligned_images, H] = reference_match(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid,...
    alphaMinusPyramid, v_maxPyramid, v_minPyramid, iterStep, expoTimes, lowHoleMaskPyramid, highHoleMaskPyramid, curRefImgNum, indImgs)


global maxIter;
global num_scales;
global outFinalDir;
global DSMethod;
global saveIntermediateResults;
global completenessFac;
global isMask;
global v_min;
global v_max;
global winIter;
global winFac;

numImages = size(sourcePyramids, 2);
targets{curRefImgNum} = sourcePyramids{curRefImgNum}{num_scales}{1};
doCompleteness = true;

[h,w,~] = size(sourcePyramids{1}{num_scales}{1});
if (winIter * num_scales < 1)
    winSize = [];
else
    winSize = [round(winFac*sqrt(h*w)) round(winFac*sqrt(h*w))];
end

ann = cell(1, numImages);
bnn = cell(1, numImages);
for i = 1 : numImages
    if (i ~= curRefImgNum)
        ann{i} = cell(1, size(sourcePyramids{i}{num_scales},2));
        bnn{i} = cell(1, size(sourcePyramids{i}{num_scales},2));
    end
end


for k = 1 : num_scales
    if (k > completenessFac * num_scales)
        doCompleteness = false;
    end

    NumIterThisScale = maxIter - (k - 1) * iterStep;
    startTime = clock;

    for j = 1 : NumIterThisScale
        rs_max = [];

        for i = 1 : numImages
            if (i ~= curRefImgNum)
                if (i > curRefImgNum)
                    [ann{i},bnn{i}, targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{num_scales-k+1}, sourceMaskPyramids{i}{num_scales-k+1},...
                        ann{i}, bnn{i}, rs_max, doCompleteness, highHoleMaskPyramid{num_scales-k+1}, winSize);
                else
                    [ann{i}, bnn{i}, targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{num_scales-k+1}, sourceMaskPyramids{i}{num_scales-k+1},...
                        ann{i}, bnn{i}, rs_max, doCompleteness, lowHoleMaskPyramid{num_scales-k+1}, winSize);
                end
                if (saveIntermediateResults)
                    outPath = sprintf('%s/Intermediate/%d/Img-%04d-Iter-%04d.png', outFinalDir, indImgs(i), k, j);
                    imwrite(targets{i}, outPath);
                end
            end
        end

        if (j ~= NumIterThisScale)
            [Htilde, Hplus, Hminus] = HDRmerge(targets, alphaPlusPyramid{num_scales-k+1}, alphaMinusPyramid{num_scales-k+1}, expoTimes, curRefImgNum);
            Href = convert_hdr(targets{curRefImgNum}, expoTimes(curRefImgNum));
            H = (1 - alphaPyramid{num_scales-k+1}) .* Htilde + alphaPyramid{num_scales-k+1} .* Href;
            H = ConsistencyCheck(Href, H, Hplus, Hminus, v_maxPyramid{num_scales-k+1}, v_minPyramid{num_scales-k+1}, expoTimes(curRefImgNum));
            targets = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, false);
        end

    end

    if (k ~= num_scales)

        [h,w, ~] = size(sourcePyramids{curRefImgNum}{num_scales - k}{1}(:, :, 1));

        if (k+1 > winIter * num_scales)
            winSize = [];
        else
            winSize = [round(winFac*sqrt(h*w)) round(winFac*sqrt(h*w))];
        end

        for i = 1 : numImages
            if (i == curRefImgNum)
                targets{i} = sourcePyramids{curRefImgNum}{num_scales - k}{1};
            else
                targets{i} = max(0,min(1, imresize(targets{i}, [h w], DSMethod)));
            end
        end

        [Htilde, Hplus, Hminus] = HDRmerge(targets, alphaPlusPyramid{num_scales-k}, alphaMinusPyramid{num_scales-k}, expoTimes, curRefImgNum);
        Href = convert_hdr(targets{curRefImgNum}, expoTimes(curRefImgNum));
        H = (1 - alphaPyramid{num_scales-k}) .* Htilde + alphaPyramid{num_scales-k} .* Href;
        H = ConsistencyCheck(Href, H, Hplus, Hminus, v_maxPyramid{num_scales-k}, v_minPyramid{num_scales-k}, expoTimes(curRefImgNum));
        targets = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, false);

        ann = UpScaleNNF(ann, h, w, curRefImgNum);
        if (doCompleteness)
            bnn = UpScaleNNF(bnn, h, w, curRefImgNum);
        end

        rs_max = 0;
        for i = 1 : numImages
            if (i ~= curRefImgNum)
                if (i > curRefImgNum)
                    [ann{i}, bnn{i}, targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{num_scales-k}, sourceMaskPyramids{i}{num_scales-k},...
                        ann{i}, bnn{i}, rs_max, doCompleteness, highHoleMaskPyramid{num_scales-k}, winSize);
                else
                    [ann{i}, bnn{i}, targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{num_scales-k}, sourceMaskPyramids{i}{num_scales-k},...
                        ann{i}, bnn{i}, rs_max, doCompleteness, lowHoleMaskPyramid{num_scales-k}, winSize);
                end
            end
        end

        [Htilde, Hplus, Hminus] = HDRmerge(targets, alphaPlusPyramid{num_scales-k}, alphaMinusPyramid{num_scales-k}, expoTimes, curRefImgNum);
        Href = convert_hdr(targets{curRefImgNum}, expoTimes(curRefImgNum));
        H = (1 - alphaPyramid{num_scales-k}) .* Htilde + alphaPyramid{num_scales-k} .* Href;
        H = ConsistencyCheck(Href, H, Hplus, Hminus, v_maxPyramid{num_scales-k}, v_minPyramid{num_scales-k}, expoTimes(curRefImgNum));
        targets = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, false);


    else

        Htilde = HDRmerge(targets, alphaPlusPyramid{1}, alphaMinusPyramid{1}, expoTimes, curRefImgNum);
        Href = convert_hdr(targets{curRefImgNum}, expoTimes(curRefImgNum));
        H = (1 - alphaPyramid{1}) .* Htilde + alphaPyramid{1} .* Href;
        aligned_images = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, true);
        aligned_voted_images = targets;

        if(isMask)
            refImg = sourcePyramids{curRefImgNum}{1}{1};
            for i = 1 : numImages
                if (i ~= curRefImgNum)
                    if (i > curRefImgNum)
                        indValids = (refImg > v_min);
                        aligned_voted_images{i}(indValids) = convert_ldr(refImg(indValids), expoTimes(curRefImgNum), expoTimes(i));
                    else
                        indValids = (refImg < v_max);
                        aligned_voted_images{i}(indValids) = convert_ldr(refImg(indValids), expoTimes(curRefImgNum), expoTimes(i));
                    end
                end
            end
        end
    end
end

end

function H = ConsistencyCheck(Href, H, Hplus, Hminus, vMaxImg, vMinImg, curRefExpoTime)

vMaxRadiance = convert_hdr(vMaxImg, curRefExpoTime);
vMinRadiance = convert_hdr(vMinImg, curRefExpoTime);

H(Href > vMaxRadiance & Hminus < vMaxRadiance) = Href(Href > vMaxRadiance & Hminus < vMaxRadiance);
H(Href < vMinRadiance & Hplus > vMinRadiance) = Href(Href < vMinRadiance & Hplus > vMinRadiance);
end

function target = ExtractTargets(Reference, H, expoTimes, curRefImgNum, isFinal)

numImages = size(expoTimes, 1);

target = cell(1, numImages);
for i = 1 : numImages
    if (i == curRefImgNum && ~isFinal)
        target{i} = Reference;
    else
        target{i} = hdr_ldr(H, expoTimes(i));
    end
end

end
