function [Htilde, Hplus, Hminus] = HDRmerge(input, alphaPlus, alphaMinus, exposure_times, curRefImgNum)

triFunc = @(x) 2 * (0.5 - abs(0.5 - x));
numInputs = size(input, 2);
[h, w, c] = size(input{1});
H_LDRs = cell(1, numInputs);
lambda = cell(1, numInputs);


largeVal = 99999999;

for i = 1 : numInputs
    H_LDRs{i} = convert_hdr(input{i}, exposure_times(i));
    lambda{i} = triFunc(input{i});
end

if (curRefImgNum < numInputs)
    Hplus = 0;
    totWplus = 0;
    for i = curRefImgNum+1 : numInputs
        Hplus = Hplus + lambda{i} .* H_LDRs{i};
        totWplus = totWplus + lambda{i};
    end
    Hplus = Hplus ./ totWplus;
    Hplus(totWplus == 0) = H_LDRs{numInputs}(totWplus == 0);

    H_plus_value = 1;
else
    Hplus = -largeVal * ones(h, w, c);
    H_plus_value = 0;
end

if (curRefImgNum > 1)
    Hminus = 0;
    totWminus = 0;
    for i = 1 : curRefImgNum-1
        Hminus = Hminus + lambda{i} .* H_LDRs{i};
        totWminus = totWminus + lambda{i};
    end
    Hminus = Hminus ./ totWminus;
    Hminus(totWminus == 0) = H_LDRs{1}(totWminus == 0);
    HminusContribution = 1;
else
    Hminus = largeVal * ones(h, w, c);
    HminusContribution = 0;
end

Htilde = (alphaPlus.*Hplus*H_plus_value+alphaMinus.*Hminus*HminusContribution)./(alphaPlus*H_plus_value+alphaMinus*HminusContribution);
Htilde((alphaPlus*H_plus_value+alphaMinus*HminusContribution) == 0) = 0;

end
