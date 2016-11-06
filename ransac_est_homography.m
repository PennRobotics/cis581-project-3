% TODO(brwr): ransac_est_homography.m

% y1, x1, y2, x2 are the corresponding point coordinate vectors Nx1 such
% that (y1_i, x1_i) matches (x2_i, y2_i) after a preliminary matching

% thres is the threshold on distance used to determine if transformed
% points agree

% H is the 3 x 3 matrix computed in the final step of RANSAC

% inlier_ind is the nx1 vector with indices of points in the arrays x1, y1,
% x2, y2 that were found to be inliers

function [H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, thres)

end
