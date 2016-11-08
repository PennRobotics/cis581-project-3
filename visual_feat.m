function visual_feat(img, cImg, y, x)
    % visualize corner matrix
    figure(3);
    clf
    imagesc(cImg);

    % visualize feature detection
    figure(4);
    clf
    imshow(img);
    hold on;
    scatter(x, y, 'r.');
    hold off;
end
