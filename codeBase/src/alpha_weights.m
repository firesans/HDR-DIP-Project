function alpha = alpha_weights(x, status, Max, Min)

global v_max;
global v_min;

if (~exist('status', 'var'))
    status = 'both';
end

if(~exist('Max', 'var'))
    Max = v_max;
end
if(~exist('Min', 'var'))
    Min = v_min;
end

alpha = ones(size(x));

if (strcmp(status, 'low') || strcmp(status, 'both'))
    Ind = x > Max;
    alpha(Ind) = 1 - (x(Ind) - Max) / (1 - Max);
end

if (strcmp(status, 'high') || strcmp(status, 'both'))
    Ind = x < Min;
    alpha(Ind) =  x(Ind) / Min;
end
