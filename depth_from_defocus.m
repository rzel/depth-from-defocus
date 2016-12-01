function depth_from_defocus(directory, imagetype, ifixed)

MAX_SIZE = 1000;

% get all files in the directory of that type
tmp = dir([directory '/*.' imagetype]);
tmp = {tmp.name}

N = length(tmp);
if (ischar(ifixed))
    ifixed = N;
end

% get image info
info = imfinfo(tmp{1});
isrgb = strcmp('truecolor', info.ColorType);

%% Align all images to the desired fixed image
for i=1:N
    image = im2double(imread(tmp{i}));
    
    if (info.Width > info.Height && info.Width > MAX_SIZE)
        image = imresize(image, [MAX_SIZE NaN]);
    elseif (info.Height > info.Width && info.Height > MAX_SIZE)
        image = imresize(image, [NaN MAX_SIZE]);
    end
    
    if (~isrgb) % Grayscale
        filesgray(:,:,i) = image;
    else
        filesrgb(:,:,:,i) = image;
        filesgray(:,:,i) = rgb2gray(image);
    end
end

transforms = calc_align_transforms(filesgray, ifixed, 250);

alignedgray = align_images(filesgray, transforms, [ifixed]);
if (isrgb)
    alignedrgb = align_images(filesrgb, transforms, [ifixed]);
end

save alignedgray;

%% Show aligned images
figure;
for i=1:N
    if (isrgb)
        imshow(alignedrgb(:,:,:,i));
    else
        imshow(alignedgray(:,:,i));
    end
    waitforbuttonpress;
end


%% Calculate depth-map from aligned focus stack

depth = calc_depth_map(alignedgray);

figure; imshow(depth);
