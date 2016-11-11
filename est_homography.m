function H = est_homography(xDest, yDest, xSrc, ySrc)
% H = est_homography(xDest, yDest, xSrc, ySrc)
% Compute the homography matrix from source (x, y) to destination (x, y)
%
% xDest, yDest are coordinates of destination points
% xSrc, ySrc are coordinates of source points
% Each input variable is a vector of n x 1 (n >= 4)
%
% H is the homography output 3x3
% (xDest, yDest, 1)^T ~ H(xSrc, ySrc, 1)^T

A = zeros(length(xSrc(:))*2,9);

for i = 1 : length(xSrc(:)),
 a = [xSrc(i), ySrc(i), 1];
 b = [0, 0, 0];
 c = [xDest(i); yDest(i)];
 d = -c * a;
 A((i - 1) * 2 + 1 : (i - 1) * 2 + 2, 1 : 9) = [[a, b;b, a], d];
end

[U, S, V] = svd(A);
h = V(:, 9);
H = reshape(h, 3, 3)';
end
