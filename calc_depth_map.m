function [depthmap] = calc_depth_map(Ifocused, photos, N)

ROWS = size(Ifocused, 1);
COLS = size(Ifocused, 2);

dblursigma = 0.25;
rmax = 15;

blursigmas = 0:dblursigma:rmax;
Nblursigmas = length(blursigmas);

Iblurred = zeros(ROWS, COLS, Nblursigmas);

Iblurred(:,:,1) = Ifocused;

%figure; hold on;
for i=2:Nblursigmas
    
    Iblurred(:,:,i) = imgaussfilt(Ifocused, blursigmas(i));
    %imshow(Iblurred(:,:,i));
end

blursigmas = zeros(ROWS, COLS, N);
confidences = zeros(ROWS, COLS, N);

differences = zeros(ROWS, COLS, Nblursigmas);
SIGMA = 15;
ALPHA = 2;
figure; hold on;
for i=1:N
    I = photos(:,:,i);
    
    for j=1:Nblursigmas
        % Equation (7)
        diff = abs(I - Iblurred(:,:,j));
        differences(:,:,j) = imgaussfilt(diff, SIGMA);
    end
    
    % Equation (8), blur map
    [Ismallestdiff, blursigmas(:,:,i)] = min(differences, [], 3);
    
    % Equation (9), confidence map
    confidences(:,:,i) = (mean(differences, 3) - Ismallestdiff).^ALPHA;
    
    imshow(blursigmas(:,:,i), []); waitforbuttonpress;
end

depthmap = 0;