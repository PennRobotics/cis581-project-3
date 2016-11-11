function [descs] = feat_desc(img, x, y)
% img = double (height)x(width) array (grayscale image) with values in the range 0-255
% x = nx1 vector representing the column coordinates of corners
% y = nx1 vector representing the row coordinates of corners
% descs = 64xn matrix of double values with column i being the 64 dimensional
% descriptor computed at location (xi, yi) in img

descs = zeros(64, length(x));

% Pad image edges
img = padarray(img, [20, 20]);

for feat = 1 : length(x)
  featMatrix = img(y(feat) : y(feat) + 39, x(feat) : x(feat) + 39);
  featMatrix = imfilter(featMatrix, fspecial('gaussian', [10, 10], 20), 'same');
  descMatrix = featMatrix(3:5:38, 3:5:38);
  descVector = descMatrix(:);
  descVectorCentered = descVector - mean(descVector);
  descVectorNorm = descVectorCentered / std(double(descVectorCentered));
  % figure(5); imagesc(descVectorNorm); drawnow; pause(0.5);
  descs(:, feat) = descVectorNorm;
end


end
