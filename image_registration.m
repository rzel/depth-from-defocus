function [ corrected_moving ] = image_registration(fixed, moving, mode)
%     figure;
%     imshowpair(fixed, moving, 'diff');
%     title('Difference - original');
    
    if (strcmp('intensity', mode))
        [optimizer, metric] = imregconfig('Multimodal');
        
        % intensity registration
%         registered = imregister(moving, fixed, 'translation', optimizer, metric);
%         figure;
%         imshowpair(registered, fixed, 'diff');
%         title('Difference - Default registration');
  
        % similarity registration
        registered = imregister(moving, fixed, 'similarity', optimizer, metric);
%         figure;
%         imshowpair(registered, fixed, 'diff');
%         title('Difference - Final registration');
        
        corrected_moving = registered;
    elseif (strcmp('feature', mode))
        
        
    else
        error('The provided mode is invalid, must be intensity or feature');
    end
end
