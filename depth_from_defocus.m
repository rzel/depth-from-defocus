function Isharpgray = depth_from_defocus(directory, imagetype, ifixed)

MAX_SIZE = 1000;

% get all files in the directory of that type
tmp = dir([directory '/*.' imagetype]);
tmp = {tmp.name};

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

ROWS = size(image, 1);
COLS = size(image, 2);

transforms = calc_align_transforms(filesgray, ifixed, 250);

alignedgray = align_images(filesgray, transforms, [ifixed], N);
if (isrgb)
    alignedrgb = align_images(filesrgb, transforms, [ifixed], N);
end

%save alignedgray;

%% Show aligned images
% figure;
% for i=1:N
%     if (0)%isrgb)
%         imshow(alignedrgb(:,:,:,i));
%     else
%         imshow(alignedgray(:,:,i));
%     end
%     waitforbuttonpress;
% end


%% Calculate sharpness map from aligned focus stack

sharpnessmap = calc_sharpness_map(alignedgray, N);
figure; imshow(sharpnessmap / max(sharpnessmap(:)));

%% Create all-in-focus image from focus stack and sharpness map

Isharpgray = zeros(ROWS, COLS);
if (isrgb)
    Isharprgb = zeros(ROWS, COLS, 3);
end

for row=1:ROWS
    for col=1:COLS
        isharpest = sharpnessmap(row, col);
        
        Isharpgray(row, col) = alignedgray(row, col, isharpest);
        if (isrgb)
            Isharprgb(row, col, :) = alignedrgb(row, col, :, isharpest);
        end
    end
end

figure; imshow(Isharpgray);

%% Calculate depth map from all-in-focus image and aligned stack

calc_depth_map(Isharpgray, alignedgray, N);