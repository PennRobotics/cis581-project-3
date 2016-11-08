function [imgMosaic] = mymosaic(imgInput)
% img_input is a cell array of color images (H x W x 3 uint8 values [0, 255])
% img_mosaic is the output mosaic

NUM_PTS = 300;
WT_Y = 0.4;
WT_CB = 0.3;
WT_CR = 0.3;

numImages = length(imgInput);
for i = 1 : numImages
  imgYCbCr = rgb2ycbcr(imgInput{i});
  imgCornersY = corner_detector(imgYCbCr(:, :, 1));
  imgCornersCb = corner_detector(imgYCbCr(:, :, 2));
  imgCornersCr = corner_detector(imgYCbCr(:, :, 3));
  imgCorners = WT_Y * imgCornersY + WT_CB * imgCornersCb + WT_CR * imgCornersCr;
  [cornerX, cornerY, cornerRMax] = anms(imgCorners, NUM_PTS);
  visual_feat(imgInput{i}, imgCorners, cornerY, cornerX);
  cornerPatches{i} = feat_desc(imgInput{i}, cornerX, cornerY);
  for j = 1 : i - 1
    match(:, i, j) = feat_match(cornerPatches{i}, cornerPatches{j});
  end
end

imgMosaic = imgCorners;
