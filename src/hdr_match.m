function [voted_images, aligned_images, H] = hdr_match(params, exposure_times, ref_img_num, num_images)

    for i = 1:num_images
        if (i ~= ref_img_num )
            if (i > curRefImgNum)
                [ann{i} bnn{i} targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{numScales-k+1}, sourceMaskPyramids{i}{numScales-k+1}, ann{i}, bnn{i}, rs_max, doCompleteness, highHoleMaskPyramid{numScales-k+1}, winSize);
            else
                [ann{i} bnn{i} targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{numScales-k+1}, sourceMaskPyramids{i}{numScales-k+1}, ann{i}, bnn{i}, rs_max, doCompleteness, lowHoleMaskPyramid{numScales-k+1}, winSize);
            end
            if (saveIntermediateResults)
                outPath = sprintf('%s/Intermediate/%d/Img-%04d-Iter-%04d.png', outFinalDir, indImgs(i), k, j);
                imwrite(targets{i}, outPath);
            end
        end
    end

end
