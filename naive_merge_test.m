clear all;
close all;

load('photostacks/tnm087/filenames.mat');
filenames = cellstr(filenames);

N = length(filenames);

files = im2double(imread(filenames{1}));
for i=2:N
    files(:,:,i) = im2double(imread(filenames{i}));
end

%%

% assume image 1 is fixed
fixed = files(:,:,1);

figure;
imshow(fixed);
hold on;
for i=2:N
    moving = files(:,:,i);
    files(:,:,i) = image_registration(fixed, moving, 'intensity');
    %imshow(files(:,:,i));
    %drawnow;
end

%%

%I = naive_focus_merge(files, [16 16]);

imshowpair(fixed, I, 'montage');