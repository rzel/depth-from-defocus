function [ aligned ] = align_images(images, ifixed, varargin)

N = size(images, 3);
aligned = zeros(size(images));

I_fixed = images(:,:,ifixed);
aligned(:,:,ifixed) = I_fixed;

metricThreshold = 250;
if (nargin == 1)
    metricThreshold = varargin(1);
end

% detect features of the "fixed" image
pts_fixed = detectSURFFeatures(I_fixed, 'MetricThreshold', metricThreshold);
[fts_fixed, validpts_fixed] = extractFeatures(I_fixed, pts_fixed);

% figure(1);
% movegui('west');
% figure(2);
% movegui('east');

for i=1:N
    if (i == ifixed)
        continue;
    end
    
    I_curr = images(:,:,i);
    
    % extract features from the image to transform
    pts_curr = detectSURFFeatures(I_curr, 'MetricThreshold', metricThreshold);
    [fts_curr, validpts_curr] = extractFeatures(I_curr, pts_curr);
    
    % match feature vectors
    indexPairs = matchFeatures(fts_fixed, fts_curr);
    matchedpts_fixed = validpts_fixed(indexPairs(:,1));
    matchedpts_curr  = validpts_curr(indexPairs(:,2));

%     figure(1); showMatchedFeatures(I_fixed, I_curr, matchedpts_fixed, matchedpts_curr);
    
    [tform, inlierpts_curr, inlierptr_fixed] = estimateGeometricTransform(...
        matchedpts_curr, matchedpts_fixed, 'similarity');
    
    outputView = imref2d(size(I_fixed));
    I_curraligned = imwarp(I_curr, tform, 'OutputView', outputView);
    aligned(:,:,i) = I_curraligned;
    
%     figure(2); imshow(I_curraligned);;
    disp(['Completed ' num2str(i) '/' num2str(N)]);
    
    %waitforbuttonpress;
end