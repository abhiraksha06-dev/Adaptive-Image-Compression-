clc;
clear;
close all;

% ============================================================
% ADAPTIVE IMAGE COMPRESSION PROJECT
% DCT-BASED FREQUENCY DOMAIN COMPRESSION
% ============================================================

% Add source folder to MATLAB path
addpath('src');

% ------------------------------------------------------------
% INPUT IMAGE
% ------------------------------------------------------------

imagePath = 'test_images/peppers.png';

% Compression quality (%)
quality = 50;

% ------------------------------------------------------------
% PERFORM DCT COMPRESSION
% ------------------------------------------------------------

[compressedImage, metrics] = ...
    frequencyCompression(imagePath, quality);

% ------------------------------------------------------------
% READ ORIGINAL IMAGE
% ------------------------------------------------------------

original = imread(imagePath);

% Convert original image to grayscale
if size(original, 3) == 3
    originalGray = rgb2gray(original);
else
    originalGray = original;
end

% ------------------------------------------------------------
% DISPLAY ORIGINAL AND COMPRESSED IMAGES
% ------------------------------------------------------------

figure('Name', 'DCT Image Compression', ...
       'NumberTitle', 'off');

subplot(1,2,1);

imshow(originalGray);

title('Original Image', ...
      'FontSize', 14, ...
      'FontWeight', 'bold');


subplot(1,2,2);

imshow(compressedImage);

title('DCT Compressed Image', ...
      'FontSize', 14, ...
      'FontWeight', 'bold');

% ------------------------------------------------------------
% DISPLAY RESULTS IN COMMAND WINDOW
% ------------------------------------------------------------

fprintf('\n');
fprintf('====================================================\n');
fprintf('          DCT IMAGE COMPRESSION RESULTS\n');
fprintf('====================================================\n');

fprintf('Input Image              : %s\n', imagePath);

fprintf('Compression Quality      : %d %%\n', quality);

fprintf('MSE                      : %.4f\n', ...
        metrics.MSE);

fprintf('PSNR                     : %.2f dB\n', ...
        metrics.PSNR);

fprintf('SSIM                     : %.4f\n', ...
        metrics.SSIM);

fprintf('Coefficient Retention    : %.2f %%\n', ...
        metrics.CoefficientRetention);

fprintf('====================================================\n');
fprintf('\n');