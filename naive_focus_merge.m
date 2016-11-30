function [ result ] = naive_focus_merge(photos, sz)
    ROWS = size(photos, 1);
    COLS = size(photos, 2);
    N = size(photos, 3);

    winrows = sz(1);
    wincols = sz(2);
    
    subwindows = zeros(winrows, wincols, N);
    
    % generate rings to measure frequency components in Fourier domain
    N_RINGS = 4;
    
    [X, Y] = meshgrid(1:wincols, 1:winrows);
    centerX = wincols / 2;
    centerY = winrows / 2;
    [~, R] = cart2pol(X - centerX, Y - centerY);
    
    max_ring_outer = 0.5 * min(winrows, wincols);
    ring_thickness = max_ring_outer / N_RINGS;
    
    % RQ is the quantized ring mask, where the value is the index
    % of the ring
    RQ = ceil(R / ring_thickness);
    RQ(RQ > N_RINGS) = 0;
    
    % calc pixels in every ring
    for ringno = 1:N_RINGS
        pixsperring(ringno) = size(find(RQ == ringno), 1)^2;
    end

    N_ROWFRAMES = ceil(ROWS/winrows);
    N_COLFRAMES = ceil(COLS/wincols);
    NNN = N_ROWFRAMES * N_COLFRAMES;
    
    sharpest = zeros(N_ROWFRAMES, N_COLFRAMES);
    
    result = zeros(ROWS, COLS);
    
    for irow=1:N_ROWFRAMES
        for icol=1:N_COLFRAMES
            disp(['Progress: ' num2str(100 * (icol + irow * N_COLFRAMES) / NNN) '%']);
            
            rows = (1+winrows*(irow-1)):min(ROWS, winrows*(irow));
            cols = (1+wincols*(icol-1)):min(COLS, wincols*(icol));
            
            padded_rows = floor(winrows/2) + rows;
            padded_cols = floor(wincols/2) + cols;
            
            maxsharpness = 0;
            
            for i=1:N
                sub = zeros(2*winrows, 2*wincols);
                sub(padded_rows, padded_cols) = photos(rows, cols, i);
                subF = fftshift(fft2(sub));
                
                sharpness = 0;
                for ringno = 1:N_RINGS
                    ringmask = RQ == ringno;
                    
                    tmp = subF(padded_rows, padded_cols);
                    
                    sharpness = sharpness + ...
                        (sum(sum(abs(subF(padded_rows, padded_cols) .* double(ringmask))))) / pixsperring(ringno);
                    
                end
                
                if (sharpness > maxsharpness)
                    maxsharpness = sharpness;
                    sharpest(irow, icol) = i;
                end
            end
            
            % fill the resulting image with the sharpest subframe
            result(rows, cols) = photos(rows, cols, sharpest(irow, icol));
        end
    end

end

