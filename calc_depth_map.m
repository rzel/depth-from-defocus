function [Idepth] = calc_depth_map(images)
HEIGHT = size(images, 1)
WIDTH  = size(images, 2)



Idepth = zeros(HEIGHT, WIDTH);
