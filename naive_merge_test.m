%% TNM087 stack

clear all;
close all;

load('photostacks/tnm087/filenames.mat');
filenames = cellstr(filenames);

N = length(filenames);

files = im2double(imread(filenames{1}));
for i=2:N
    files(:,:,i) = im2double(imread(filenames{i}));
end


%% wall_panels stack

clear all;
close all;

N = 10;

for i=1:N
    name = ['repos_wall_panels_' num2str(i) '.jpg'];
    files(:,:,i) = rgb2gray(im2double(imread(name)));
end

%% smiley_face stack

clc;
clear all;
close all;

N = 9;

for i=0:(N-1)
    if (i < 10)
        name = ['smiley_face_0' num2str(i) '.png'];
    else
        name = ['smiley_face_' num2str(i) '.png'];
    end
    files(:,:,i+1) = rgb2gray(im2double(imread(name)));
end

%% weird_face stack

clc;
clear all;
close all;

N = 15;

for i=1:N
    name = ['weird_face_' num2str(i) '.png'];
    files(:,:,i) = rgb2gray(im2double(imread(name)));
end

figure;
for i=1:N
    imshow(files(:,:,i));
    %drawnow;
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

I = naive_focus_merge(files, [64 64]);

imshowpair(fixed, I, 'montage');