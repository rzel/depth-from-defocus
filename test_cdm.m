%% 
load alignedgray.mat;

%%
depth = calc_depth_map(alignedgray);

figure;
imshow(depth);