function [voted_images,aligned_images,H] = ...
    Generate_HDR_Reconstrution(ref_img_num,input_imgs, exposure_times)
num_images = size(input_imgs, 2);
params = cell(1, num_images);
for i = 1 : num_images
    if (i ~= ref_img_num)
        params{i - indImgs(1) + 1} = LDRtoLDR(input_imgs{ref_img_num}, exposure_times(ref_img_num), exposure_times(i));
    end
end
[voted_images,aligned_images,H] = hdr_match(params, exposure_times, ref_img_num, num_images);
end

function hdr2ldr = LDRtoLDR(ref_img, ref_img_exposure_time, img_exposure_time)
global gamma;
%---------------------
ref_img = max(min(ref_img,1),0);
ref_img = single(ref_img);
ldr2hdr = (ref_img).^gamma;
ldr2hdr = ldr2hdr/ref_img_exposure_time;

%----------------------
ldr2hdr = single(ldr2hdr)*img_exposure_time;
hdr2ldr = (ldr2hdr).^(1/gamma);
hdr2ldr = max(min(hdr2ldr,1),0);
end