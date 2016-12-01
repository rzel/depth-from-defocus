function depth_from_defocus(directory, imagetype, ifixed)

% get all files in the directory of that type
tmp = dir([directory '/*.' imagetype]);
tmp = {tmp.name}

N = length(tmp);
if (ischar(ifixed))
    ifixed = N;
end

for i=1:N
    files(:,:,i) = rgb2gray(im2double(imread(tmp{i})));
end

aligned = align_images(files, ifixed, 250);

figure;
hold on;
for i=1:N
    imshowpair(files(:,:,i), aligned(:,:,i), 'montage');
    waitforbuttonpress;
end
