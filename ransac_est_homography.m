function [H, inlier_ind] = ransac_est_homography(x1, y1, x2, y2, thres)
% y1, x1, y2, x2 are the corresponding point coordinate vectors Nx1 such
% that (y1_i, x1_i) matches (x2_i, y2_i) after a preliminary matching

% thres is the threshold on distance used to determine if transformed
% points agree

% H is the 3 x 3 matrix computed in the final step of RANSAC

% inlier_ind is the nx1 vector with indices of points in the arrays x1, y1,
% x2, y2 that were found to be inliers

NUM_CONSEC_TRIALS = 1250;
N = length(x2);

bestTrialCount = 0;
bestTrialNumInliers = 0;
bestTrialInliers = 1;

rng(20435)
% rng('shuffle')

% Wait until a number of consecutive random trials without improvement
while (bestTrialCount < NUM_CONSEC_TRIALS)
  idxRand = randsample(N, 4, true);  % Get four sample point indices
  trialH = est_homography(x1(idxRand), y1(idxRand), x2(idxRand), y2(idxRand));

  % Get target point estimates using four randomly sampled corresponding points
  [trialX1, trialY1] = apply_homography(trialH, x2, y2);
  trialInliers = abs((trialX1 - x1) + i*(trialY1 - y1)) <= thres;
  trialNumInliers = sum(trialInliers);

  if trialNumInliers > bestTrialNumInliers
    bestH = trialH;
    bestTrialInliers = trialInliers;
    bestTrialNumInliers = trialNumInliers;
    bestTrialCount = 0;
  else
    bestTrialCount = bestTrialCount + 1;
  end
end

H = est_homography(x1(bestTrialInliers), ...
                   y1(bestTrialInliers), ...
                   x2(bestTrialInliers), ...
                   y2(bestTrialInliers));
inlier_ind = find(bestTrialInliers);
end
