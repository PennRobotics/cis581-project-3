%% Automatic 2D Image Mosaic
% CIS581 Computer Vision, University of Pennsylvania
% Author: Brian Wright

clear all; clc
DEBUG = false;

%% Import images
imageFiles = dir('images');
for i = 3 : length(imageFiles)
  imagePath = ['images/' imageFiles(i).name];
  images{i - 2} = imread(imagePath);
  if (DEBUG) figure(i); imagesc(images{i - 2}); end
end

%% Stitch images
imageComposite = mymosaic(images);  % TODO(brwr): Ensure uint8, 3-ch cell array input

%% Output
figure(1)
imagesc(imageComposite)
% TODO(brwr): Save image
