function [imgMosaic] = mymosaic(imgInput)
% img_input is a cell array of color images (H x W x 3 uint8 values [0, 255])
% img_mosaic is the output mosaic

% VARIABLES
DEBUG = true;
TRIM = true;
RANSAC_THRES = 4.5;
NUM_PTS = 350;
WT_Y = 0.60;
WT_CB = 0.20;
WT_CR = 0.20;

% Stitch from center out
numImages = length(imgInput);
centerImageIdx = round(numImages / 2);
imgOrderL = centerImageIdx - 1 : -1 : 1;
imgOrderR = centerImageIdx + 1 : numImages;
if mod(numImages, 2) == 0, imgOrderL = [imgOrderL, 0]; end
imgOrder = [imgOrderL; imgOrderR];
imgOrder = imgOrder(:)';
imgOrder(imgOrder == 0) = [];
imgMosaic = imgInput{centerImageIdx};

if (DEBUG)
  figure(1)
  imagesc(imgMosaic)
  drawnow
end

% Cut cylindrical distortion every frame with these boundaries
topTrimBound = 0;
bottomTrimBound = size(imgMosaic, 1);

if (~DEBUG), disp('Stitching images...'); end

for id = imgOrder
  imgInputI = imgInput{id};

  if (DEBUG), disp(id); end
  imgMosaicYCbCr = rgb2ycbcr(imgMosaic);
  imgMosaicCornersY = corner_detector(imgMosaicYCbCr(:, :, 1));
  imgMosaicCornersCb = corner_detector(imgMosaicYCbCr(:, :, 2));
  imgMosaicCornersCr = corner_detector(imgMosaicYCbCr(:, :, 3));
  imgMosaicCorners = WT_Y * imgMosaicCornersY + WT_CB * imgMosaicCornersCb + WT_CR * imgMosaicCornersCr;
  % imgMosaicCorners = corner_detector(imgMosaicGray);
  imgMosaicGray = rgb2gray(imgMosaic);
  [cornerXMosaic, cornerYMosaic, cornerRMaxMosaic] = anms(imgMosaicCorners, NUM_PTS);
  cornerPatchesMosaic = feat_desc(imgMosaicGray, cornerXMosaic, cornerYMosaic);

  imgYCbCr = rgb2ycbcr(imgInputI);
  imgCornersY = corner_detector(imgYCbCr(:, :, 1));
  imgCornersCb = corner_detector(imgYCbCr(:, :, 2));
  imgCornersCr = corner_detector(imgYCbCr(:, :, 3));
  imgCorners = WT_Y * imgCornersY + WT_CB * imgCornersCb + WT_CR * imgCornersCr;
  % imgCorners = corner_detector(imgInputGray);
  imgInputGray = rgb2gray(imgInputI);
  [cornerX, cornerY, cornerRMax] = anms(imgCorners, NUM_PTS);
  cornerPatches = feat_desc(imgInputGray, cornerX, cornerY);

  if (DEBUG)
    disp(sum([sum(cornerPatchesMosaic) sum(cornerPatches)]))
    disp(size(cornerPatchesMosaic))
    disp(size(cornerPatches))
  end

  % visual_feat(imgMosaic, imgMosaicCorners, cornerYMosaic, cornerXMosaic);
  % visual_feat(imgInputI, imgCorners, cornerY, cornerX);

  % Link new image corner features to existing panorama corner features
  matches = feat_match(cornerPatchesMosaic, cornerPatches);
  matchIdx = (matches ~= -1);
  cornerXMosaicMatches = cornerXMosaic(matchIdx);
  cornerYMosaicMatches = cornerYMosaic(matchIdx);
  cornerXMatches = cornerX(matches(matchIdx));
  cornerYMatches = cornerY(matches(matchIdx));
  if (DEBUG > 1)
    P = [cornerXMosaicMatches cornerYMosaicMatches cornerXMatches cornerYMatches];
    assignin('base','P',P);
  end

  % disp([cornerXMosaicMatches, cornerYMosaicMatches, cornerXMatches, cornerYMatches])

  % Find the transformation matrix for the new picture
  [H, inliers] = ransac_est_homography(cornerXMosaicMatches, ...
                                       cornerYMosaicMatches, ...
                                       cornerXMatches, ...
                                       cornerYMatches, ...
                                       RANSAC_THRES);

  % Determine how the new frame will fit in the existing panorama coordinates
  coordUL = [1, 1];
  coordLL = [size(imgInputI, 1), 1];
  coordUR = [1, size(imgInputI, 2)];
  coordLR = [size(imgInputI, 1), size(imgInputI, 2)];

  coordCorners = [coordUL; coordLL; coordUR; coordLR];

  [xNewCorners, yNewCorners] = apply_homography(H, coordCorners(:, 2), coordCorners(:, 1));

  lowCornerIdx = ceil(min([xNewCorners, yNewCorners]));
  lowAdd = -min([lowCornerIdx; 1, 1]);

  highCornerIdx = floor(max([xNewCorners, yNewCorners]));
  highAdd = max([highCornerIdx; flip(size(imgMosaicGray))]);

  xx = ndgrid(lowCornerIdx(1) : highCornerIdx(1), lowCornerIdx(2) : highCornerIdx(2))';
  yy = ndgrid(lowCornerIdx(2) : highCornerIdx(2), lowCornerIdx(1) : highCornerIdx(1));
  xxVect = xx(:);
  yyVect = yy(:);

  [xFr, yFr] = apply_homography(pinv(H), xxVect, yyVect);
  xFr = round(xFr);
  yFr = round(yFr);

  validFr = yFr > 0 & xFr > 0 & yFr <= size(imgInputI, 1) & xFr <= size(imgInputI, 2);

  xxVectFr = xxVect(validFr);
  yyVectFr = yyVect(validFr);
  xFr = xFr(validFr);
  yFr = yFr(validFr);

  if (DEBUG), disp('s'); disp([min(xFr), max(xFr)]); end

  panSize = highAdd + lowAdd;
  panAdd = zeros(panSize(2) + 2, panSize(1) + 2, 3, 'uint8');
  % Drop the existing panorama into a temporary variable
  panAdd(lowAdd(2) + 2 : lowAdd(2) + size(imgMosaicGray, 1) + 1, ...
         lowAdd(1) + 2 : lowAdd(1) + size(imgMosaicGray, 2) + 1, :) = uint8(imgMosaic);

  % Check for black values around edges
  isFilled = sum(panAdd, 3);

  for j = 1 : length(xFr)
    if isFilled(yyVectFr(j) + lowAdd(2) + 1, xxVectFr(j) + lowAdd(1) + 1),
      % Blend if not black value pixels
      panAdd(yyVectFr(j) + lowAdd(2) + 1, xxVectFr(j) + lowAdd(1) + 1, :) = ...
      0.5 * panAdd(yyVectFr(j) + lowAdd(2) + 1, xxVectFr(j) + lowAdd(1) + 1, :) + ...
      0.5 * imgInputI(yFr(j), xFr(j), :);
    else
      if (DEBUG > 1), disp([yyVectFr(j)+lowAdd(2), xxVectFr(j)+lowAdd(1), yFr(j), xFr(j)]); end
      panAdd(yyVectFr(j) + lowAdd(2) + 1, xxVectFr(j) + lowAdd(1) + 1, :) = imgInputI(yFr(j), xFr(j), :);
    end
  end

  if (DEBUG), disp(lowAdd(2)); end
  if (TRIM)
    imgMosaic = panAdd(lowAdd(2) + 2: lowAdd(2) + bottomTrimBound + 2, :, :);
  else
    imgMosaic = panAdd;
  end

  if (DEBUG)
    figure(1)
    imagesc(imgMosaic)
    drawnow
  end

end

end
