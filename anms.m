function [x, y, rMax] = anms(cImg, maxPts)
% Adaptive Non-Maximal Suppression
% [x, y, rMax] = anms(cImg, maxPts)
%   cimg = corner strength map
%   max_pts = number of corners desired
%   [x, y] = coordinates of corners
%   rmax = suppression radius used to get max_pts corners

CORNER_THRES = 2e-8;
cImg(cImg < CORNER_THRES) = 0;

x = zeros(maxPts, 1);
y = zeros(maxPts, 1);

startRadius = ceil(sqrt(prod(size(cImg)) / maxPts));
foundAllResults = false;
while (~foundAllResults)
  tmpImg = cImg;
  [meshRow, meshCol] = meshgrid(-startRadius : startRadius);
  circleMask = sqrt(meshRow.^2 + meshCol.^2) > startRadius;
  for pt = 1 : maxPts
    [maxVal, maxRow] = max(max(tmpImg'));
    [maxVal, maxCol] = max(max(tmpImg));
    x(pt) = maxCol;
    y(pt) = maxRow;
    thisCircleMask = circleMask;
    rMaskFr = 1 - min(0, maxRow - startRadius - 1);
    rMaskTo = -1 - min(0, size(tmpImg, 1) - (maxRow + startRadius));
    cMaskFr = 1 - min(0, maxCol - startRadius - 1);
    cMaskTo = -1 - min(0, size(tmpImg, 2) - (maxCol + startRadius));
    thisCircleMask = ...
        thisCircleMask(rMaskFr : startRadius * 2 - rMaskTo, cMaskFr : startRadius * 2 - cMaskTo);
    rFr = max(1, maxRow - startRadius);
    rTo = min(size(tmpImg, 1), maxRow + startRadius);
    cFr = max(1, maxCol - startRadius);
    cTo = min(size(tmpImg, 2), maxCol + startRadius);
    tmpImg(rFr : rTo, cFr : cTo) = tmpImg(rFr : rTo, cFr : cTo) .* thisCircleMask;
  end
  if ~(x(maxPts) == 1 && y(maxPts) == 1), break; end;
  if (startRadius > 4)
    startRadius = ceil(0.75 * startRadius);
  else
    startRadius = startRadius - 1;
    if startRadius == 0, break; end;
  end
end
rMax = startRadius;
end
