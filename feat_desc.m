% TODO(brwr): feat_desc.m
function [descs] = feat_desc(img, x, y)
% img = double (height)x(width) array (grayscale image) with values in the
% range 0-255
% x = nx1 vector representing the column coordinates of corners
% y = nx1 vector representing the row coordinates of corners
% descs = 64xn matrix of double values with column i being the 64 dimensional
% descriptor computed at location (xi, yi) in im

descs = zeros(64, length(x));

% Allow 8 x 8 patch along image edges
[ySize, xSize, ~] = size(img);
x = min(xSize - 4, max(4, x));
y = min(ySize - 4, max(4, y));

for feat = 1 : length(x)
  descMatrix = img(y(feat) - 3 : y(feat) + 4, x(feat) - 3 : x(feat) + 4);
  descs(:, feat) = descMatrix(:);
end


end
