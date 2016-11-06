% TODO(brwr): visual_feat.m

function visual_feat(img, cImg, y, x)
    % visualize corner matrix
    figure;
    imshow(cImg);

    % visualize feature detection
    figure;
    imshow(img);
    hold on;
    scatter(x,y, 'r.');
    hold off;
end

