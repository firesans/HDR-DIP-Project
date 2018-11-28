function out = hdr_ldr(input, expo)

global gamma;
input = single(input)*expo;
out = (input).^(1/gamma);
out = max(min(out,1),0);

end
