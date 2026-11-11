function compressionDashboard()

    %% ================================================================
    %  CONTENT-AWARE IMAGE COMPRESSION DASHBOARD
    %  DCT + EDGE-PRESERVING ADAPTIVE QUANTIZATION
    %  ================================================================

    clc;

    %% PROJECT PATH
    currentFile = mfilename('fullpath');
    currentFolder = fileparts(currentFile);

    if contains(currentFolder, 'experiments')
        projectRoot = fileparts(currentFolder);
    else
        projectRoot = currentFolder;
    end

    addpath(fullfile(projectRoot, 'src'));

    %% IMAGE
    originalPath = fullfile( ...
        projectRoot, 'test_images', 'peppers.png');

    if ~isfile(originalPath)
        error('Image not found: %s', originalPath);
    end

    originalImage = imread(originalPath);

    %% SETTINGS
    quality = 50;

    resultsFolder = fullfile(projectRoot, 'results');

    if ~isfolder(resultsFolder)
        mkdir(resultsFolder);
    end

    standardFile = fullfile( ...
        resultsFolder, 'dashboard_standard.mat');

    adaptiveFile = fullfile( ...
        resultsFolder, 'dashboard_adaptive.mat');

    %% ================================================================
    %  RUN COMPRESSION
    %  ================================================================

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('        CONTENT-AWARE IMAGE COMPRESSION DASHBOARD\n');
    fprintf('============================================================\n');
    fprintf('\nRunning compression...\n');

    evalc(['actualCompression(originalPath, quality, standardFile);']);

    [standardImage, standardMetrics] = ...
        decompressImage(standardFile);

    evalc(['actualAdaptiveCompression(originalPath, quality, adaptiveFile);']);

    [adaptiveImage, adaptiveMetrics] = ...
        decompressAdaptiveImage(adaptiveFile);

    %% ================================================================
    %  TRUE SSIM
    %  ================================================================

    standardSSIM = calculateTrueSSIM( ...
        originalImage, standardImage);

    adaptiveSSIM = calculateTrueSSIM( ...
        originalImage, adaptiveImage);

    %% ================================================================
    %  ORIGINAL IMAGE INFORMATION
    %  ================================================================

    imageInfo = dir(originalPath);

    originalFileSizeKB = ...
        imageInfo.bytes / 1024;

    rawImageSizeKB = ...
        numel(originalImage) / 1024;

    imageHeight = size(originalImage,1);
    imageWidth = size(originalImage,2);
    channels = size(originalImage,3);

    totalPixels = ...
        imageHeight * imageWidth;

    %% ================================================================
    %  COMPRESSION VALUES
    %  ================================================================

    standardSize = ...
        standardMetrics.CompressedFileSizeKB;

    adaptiveSize = ...
        adaptiveMetrics.CompressedFileSizeKB;

    standardRatio = ...
        originalFileSizeKB / standardSize;

    adaptiveRatio = ...
        originalFileSizeKB / adaptiveSize;

    standardSaving = ...
        100 * (1 - standardSize / originalFileSizeKB);

    adaptiveSaving = ...
        100 * (1 - adaptiveSize / originalFileSizeKB);

    fileReduction = ...
        standardSize - adaptiveSize;

    psnrGain = ...
        adaptiveMetrics.PSNR - standardMetrics.PSNR;

    mseReduction = ...
        standardMetrics.MSE - adaptiveMetrics.MSE;

    ssimGain = ...
        adaptiveSSIM - standardSSIM;

    %% ================================================================
    %  COMMAND WINDOW SUMMARY
    %  ================================================================

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('             ORIGINAL IMAGE INFORMATION\n');
    fprintf('============================================================\n');
    fprintf('\n');
    fprintf('File Name          : peppers.png\n');
    fprintf('Original File Size : %.2f KB\n', ...
        originalFileSizeKB);
    fprintf('Raw Image Size     : %.2f KB\n', ...
        rawImageSizeKB);
    fprintf('Dimensions         : %d x %d pixels\n', ...
        imageWidth, imageHeight);
    fprintf('Color Channels     : %d (RGB)\n', ...
        channels);
    fprintf('Total Pixels       : %d\n', ...
        totalPixels);
    fprintf('\n');
    fprintf('============================================================\n');

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('             COMPRESSION COMPARISON\n');
    fprintf('============================================================\n');

    fprintf('\nSTANDARD DCT\n');
    fprintf('File Size          : %.2f KB\n', standardSize);
    fprintf('Compression Ratio  : %.2f : 1\n', standardRatio);
    fprintf('Space Saving       : %.2f %%\n', standardSaving);
    fprintf('MSE                : %.4f\n', standardMetrics.MSE);
    fprintf('PSNR               : %.2f dB\n', standardMetrics.PSNR);
    fprintf('SSIM               : %.4f\n', standardSSIM);

    fprintf('\nADAPTIVE DCT\n');
    fprintf('File Size          : %.2f KB\n', adaptiveSize);
    fprintf('Compression Ratio  : %.2f : 1\n', adaptiveRatio);
    fprintf('Space Saving       : %.2f %%\n', adaptiveSaving);
    fprintf('MSE                : %.4f\n', adaptiveMetrics.MSE);
    fprintf('PSNR               : %.2f dB\n', adaptiveMetrics.PSNR);
    fprintf('SSIM               : %.4f\n', adaptiveSSIM);

    fprintf('\nADAPTIVE ADVANTAGE\n');
    fprintf('File Reduction     : %.2f KB\n', fileReduction);
    fprintf('PSNR Improvement   : %.4f dB\n', psnrGain);
    fprintf('MSE Reduction      : %.4f\n', mseReduction);
    fprintf('SSIM Improvement   : %.5f\n', ssimGain);

    fprintf('\n');
    fprintf('============================================================\n');

    %% ================================================================
    %  DASHBOARD WINDOW
    %  ================================================================

    fig = uifigure( ...
        'Name', ...
        'Content-Aware Image Compression Dashboard', ...
        'Position', [40 25 1540 850], ...
        'Color', [0.96 0.97 0.98]);

    %% MAIN GRID

    mainGrid = uigridlayout(fig, [6 1]);

    mainGrid.RowHeight = ...
        {68, 55, 235, 220, 135, 35};

    mainGrid.ColumnWidth = {'1x'};

    mainGrid.Padding = ...
        [12 10 12 10];

    mainGrid.RowSpacing = 7;

    %% ================================================================
    %  HEADER
    %  ================================================================

    header = uipanel(mainGrid);

    header.Layout.Row = 1;

    header.BorderType = 'none';

    header.BackgroundColor = ...
        [0.12 0.18 0.28];

    titleLabel = uilabel(header);

    titleLabel.Text = ...
        'CONTENT-AWARE IMAGE COMPRESSION';

    titleLabel.FontSize = 21;

    titleLabel.FontWeight = 'bold';

    titleLabel.FontColor = ...
        [1 1 1];

    titleLabel.HorizontalAlignment = ...
        'center';

    titleLabel.Position = ...
        [20 32 1500 28];

    subtitleLabel = uilabel(header);

    subtitleLabel.Text = ...
        'DCT Frequency Analysis  |  Edge Detection  |  Adaptive Quantization';

    subtitleLabel.FontSize = 11;

    subtitleLabel.FontColor = ...
        [0.85 0.90 0.96];

    subtitleLabel.HorizontalAlignment = ...
        'center';

    subtitleLabel.Position = ...
        [20 8 1500 20];

    %% ================================================================
    %  IMAGE INFORMATION
    %  ================================================================

    infoPanel = uipanel(mainGrid);

    infoPanel.Layout.Row = 2;

    infoPanel.BorderType = 'line';

    infoPanel.Title = ...
        ' IMAGE & EXPERIMENT INFORMATION ';

    infoPanel.FontWeight = 'bold';

    infoGrid = ...
        uigridlayout(infoPanel, [1 5]);

    infoGrid.ColumnWidth = ...
        {'1.5x','1x','1x','1x','1x'};

    infoGrid.Padding = ...
        [10 5 10 5];

    infoGrid.ColumnSpacing = 6;

    createInfoCard(infoGrid, ...
        'IMAGE', 'peppers.png');

    createInfoCard(infoGrid, ...
        'RESOLUTION', ...
        sprintf('%d × %d', ...
        imageWidth, imageHeight));

    createInfoCard(infoGrid, ...
        'FORMAT', ...
        'RGB');

    createInfoCard(infoGrid, ...
        'ORIGINAL SIZE', ...
        sprintf('%.2f KB', ...
        originalFileSizeKB));

    createInfoCard(infoGrid, ...
        'QUALITY', ...
        sprintf('%d / 100', quality));

    %% ================================================================
    %  ANALYSIS SECTION
    %  ================================================================

    analysisGrid = ...
        uigridlayout(mainGrid, [1 3]);

    analysisGrid.Layout.Row = 3;

    analysisGrid.ColumnWidth = ...
        {'1x','1x','1x'};

    analysisGrid.ColumnSpacing = 7;

    analysisGrid.Padding = ...
        [0 0 0 0];

    %% ================================================================
    %  ORIGINAL IMAGE
    %  ================================================================

    originalPanel = uipanel(analysisGrid);

    originalPanel.Title = ...
        ' 1. ORIGINAL IMAGE ';

    originalPanel.FontWeight = 'bold';

    originalGrid = ...
        uigridlayout(originalPanel, [2 1]);

    originalGrid.RowHeight = ...
        {'1x', 30};

    originalGrid.Padding = ...
        [6 5 6 5];

    ax1 = uiaxes(originalGrid);

    ax1.Layout.Row = 1;

    imshow(originalImage, ...
        'Parent', ax1);

    title(ax1, ...
        'Input Image', ...
        'FontSize', 12);

    ax1.XTick = [];
    ax1.YTick = [];

    label1 = uilabel(originalGrid);

    label1.Layout.Row = 2;

    label1.Text = sprintf( ...
        '%d × %d pixels  |  RGB  |  %.2f KB', ...
        imageWidth, ...
        imageHeight, ...
        originalFileSizeKB);

    label1.HorizontalAlignment = ...
        'center';

    label1.FontSize = 9;

    %% ================================================================
    %  FREQUENCY ANALYSIS
    %  ================================================================

    frequencyPanel = uipanel(analysisGrid);

    frequencyPanel.Title = ...
        ' 2. FREQUENCY ANALYSIS ';

    frequencyPanel.FontWeight = 'bold';

    frequencyGrid = ...
        uigridlayout(frequencyPanel, [2 1]);

    frequencyGrid.RowHeight = ...
        {'1x', 30};

    frequencyGrid.Padding = ...
        [6 5 6 5];

    grayImage = ...
        rgb2gray(originalImage);

    frequencyDomain = ...
        fft2(double(grayImage));

    shiftedSpectrum = ...
        fftshift(frequencyDomain);

    magnitudeSpectrum = ...
        log(1 + abs(shiftedSpectrum));

    ax2 = uiaxes(frequencyGrid);

    ax2.Layout.Row = 1;

    imshow(magnitudeSpectrum, [], ...
        'Parent', ax2);

    title(ax2, ...
        'Frequency Spectrum', ...
        'FontSize', 12);

    ax2.XTick = [];
    ax2.YTick = [];

    label2 = uilabel(frequencyGrid);

    label2.Layout.Row = 2;

    label2.Text = ...
        'Center = low frequency  |  Outer regions = high frequency';

    label2.HorizontalAlignment = ...
        'center';

    label2.FontSize = 9;

    %% ================================================================
    %  EDGE ANALYSIS
    %  ================================================================

    edgePanel = uipanel(analysisGrid);

    edgePanel.Title = ...
        ' 3. EDGE / DETAIL ANALYSIS ';

    edgePanel.FontWeight = 'bold';

    edgeGrid = ...
        uigridlayout(edgePanel, [2 1]);

    edgeGrid.RowHeight = ...
        {'1x', 30};

    edgeGrid.Padding = ...
        [6 5 6 5];

    %% MANUAL SOBEL

    grayDouble = ...
        double(grayImage);

    sobelX = ...
        [-1 0 1;
         -2 0 2;
         -1 0 1];

    sobelY = ...
        [-1 -2 -1;
          0  0  0;
          1  2  1];

    gx = ...
        conv2(grayDouble, sobelX, 'same');

    gy = ...
        conv2(grayDouble, sobelY, 'same');

    edgeStrength = ...
        sqrt(gx.^2 + gy.^2);

    if max(edgeStrength(:)) > 0

        edgeStrength = ...
            edgeStrength / max(edgeStrength(:));

    end

    ax3 = uiaxes(edgeGrid);

    ax3.Layout.Row = 1;

    imshow(edgeStrength, [], ...
        'Parent', ax3);

    title(ax3, ...
        'Edge Strength Map', ...
        'FontSize', 12);

    ax3.XTick = [];
    ax3.YTick = [];

    label3 = uilabel(edgeGrid);

    label3.Layout.Row = 2;

    label3.Text = ...
        'Strong edges → more coefficients retained';

    label3.HorizontalAlignment = ...
        'center';

    label3.FontSize = 9;

    %% ================================================================
    %  RECONSTRUCTION SECTION
    %  ================================================================

    reconstructionGrid = ...
        uigridlayout(mainGrid, [1 2]);

    reconstructionGrid.Layout.Row = 4;

    reconstructionGrid.ColumnWidth = ...
        {'1x','1x'};

    reconstructionGrid.ColumnSpacing = 7;

    reconstructionGrid.Padding = ...
        [0 0 0 0];

    %% ================================================================
    %  STANDARD DCT
    %  ================================================================

    standardPanel = ...
        uipanel(reconstructionGrid);

    standardPanel.Title = ...
        ' 4. STANDARD DCT — UNIFORM COMPRESSION ';

    standardPanel.FontWeight = 'bold';

    standardGrid = ...
        uigridlayout(standardPanel, [1 2]);

    standardGrid.ColumnWidth = ...
        {'1.25x','1x'};

    standardGrid.Padding = ...
        [7 5 7 5];

    standardGrid.ColumnSpacing = 8;

    ax4 = uiaxes(standardGrid);

    ax4.Layout.Column = 1;

    imshow(standardImage, ...
        'Parent', ax4);

    title(ax4, ...
        'Reconstructed Image', ...
        'FontSize', 11);

    ax4.XTick = [];
    ax4.YTick = [];

    standardText = ...
        uilabel(standardGrid);

    standardText.Layout.Column = 2;

    standardText.Text = sprintf([ ...
        'STANDARD DCT\n' ...
        'Same compression strength\n' ...
        'for every image block.\n\n' ...
        'Size       : %.2f KB\n' ...
        'Ratio      : %.2f : 1\n' ...
        'Saving     : %.2f %%\n' ...
        'MSE        : %.4f\n' ...
        'PSNR       : %.2f dB\n' ...
        'SSIM       : %.4f'], ...
        standardSize, ...
        standardRatio, ...
        standardSaving, ...
        standardMetrics.MSE, ...
        standardMetrics.PSNR, ...
        standardSSIM);

    standardText.FontSize = 10;

    standardText.HorizontalAlignment = ...
        'left';

    standardText.VerticalAlignment = ...
        'center';

    %% ================================================================
    %  ADAPTIVE DCT
    %  ================================================================

    adaptivePanel = ...
        uipanel(reconstructionGrid);

    adaptivePanel.Title = ...
        ' 5. ADAPTIVE DCT — CONTENT-AWARE COMPRESSION ';

    adaptivePanel.FontWeight = 'bold';

    adaptiveGrid = ...
        uigridlayout(adaptivePanel, [1 2]);

    adaptiveGrid.ColumnWidth = ...
        {'1.25x','1x'};

    adaptiveGrid.Padding = ...
        [7 5 7 5];

    adaptiveGrid.ColumnSpacing = 8;

    ax5 = uiaxes(adaptiveGrid);

    ax5.Layout.Column = 1;

    imshow(adaptiveImage, ...
        'Parent', ax5);

    title(ax5, ...
        'Reconstructed Image', ...
        'FontSize', 11);

    ax5.XTick = [];
    ax5.YTick = [];

    adaptiveText = ...
        uilabel(adaptiveGrid);

    adaptiveText.Layout.Column = 2;

    adaptiveText.Text = sprintf([ ...
        'ADAPTIVE DCT\n' ...
        'Compression strength changes\n' ...
        'according to image detail.\n\n' ...
        'Size       : %.2f KB\n' ...
        'Ratio      : %.2f : 1\n' ...
        'Saving     : %.2f %%\n' ...
        'MSE        : %.4f\n' ...
        'PSNR       : %.2f dB\n' ...
        'SSIM       : %.4f'], ...
        adaptiveSize, ...
        adaptiveRatio, ...
        adaptiveSaving, ...
        adaptiveMetrics.MSE, ...
        adaptiveMetrics.PSNR, ...
        adaptiveSSIM);

    adaptiveText.FontSize = 10;

    adaptiveText.HorizontalAlignment = ...
        'left';

    adaptiveText.VerticalAlignment = ...
        'center';

    %% ================================================================
    %  PERFORMANCE SECTION
    %  ================================================================

    performanceGrid = ...
        uigridlayout(mainGrid, [1 2]);

    performanceGrid.Layout.Row = 5;

    performanceGrid.ColumnWidth = ...
        {'2x','1x'};

    performanceGrid.ColumnSpacing = 7;

    performanceGrid.Padding = ...
        [0 0 0 0];

    %% ================================================================
    %  PERFORMANCE TABLE
    %  ================================================================

    performancePanel = ...
        uipanel(performanceGrid);

    performancePanel.Title = ...
        ' 6. PERFORMANCE COMPARISON ';

    performancePanel.FontWeight = 'bold';

    tableGrid = ...
        uigridlayout(performancePanel, [1 1]);

    tableGrid.Padding = ...
        [5 3 5 3];

    comparisonData = {

        'Compressed Size (KB)', ...
        sprintf('%.2f', standardSize), ...
        sprintf('%.2f', adaptiveSize);

        'Compression Ratio', ...
        sprintf('%.2f : 1', standardRatio), ...
        sprintf('%.2f : 1', adaptiveRatio);

        'Space Saving', ...
        sprintf('%.2f %%', standardSaving), ...
        sprintf('%.2f %%', adaptiveSaving);

        'MSE', ...
        sprintf('%.4f', standardMetrics.MSE), ...
        sprintf('%.4f', adaptiveMetrics.MSE);

        'PSNR (dB)', ...
        sprintf('%.2f', standardMetrics.PSNR), ...
        sprintf('%.2f', adaptiveMetrics.PSNR);

        'SSIM', ...
        sprintf('%.4f', standardSSIM), ...
        sprintf('%.4f', adaptiveSSIM)
        };

    tableUI = ...
        uitable(tableGrid);

    tableUI.Data = ...
        comparisonData;

    tableUI.ColumnName = ...
        {'Metric','Standard DCT','Adaptive DCT'};

    tableUI.RowName = {};

    tableUI.ColumnWidth = ...
        {190, 115, 115};

    tableUI.RowStriping = 'on';

    tableUI.FontSize = 9;

    %% ================================================================
    %  ADAPTIVE ADVANTAGE
    %  ================================================================

    advantagePanel = ...
        uipanel(performanceGrid);

    advantagePanel.Title = ...
        ' 7. ADAPTIVE ADVANTAGE ';

    advantagePanel.FontWeight = 'bold';

    advantageGrid = ...
        uigridlayout(advantagePanel, [2 2]);

    advantageGrid.RowHeight = ...
        {'1x','1x'};

    advantageGrid.ColumnWidth = ...
        {'1x','1x'};

    advantageGrid.Padding = ...
        [8 5 8 5];

    advantageGrid.RowSpacing = 4;

    advantageGrid.ColumnSpacing = 5;

    createAdvantageCard( ...
        advantageGrid, ...
        'FILE SIZE', ...
        sprintf('%.2f KB smaller', fileReduction), ...
        1, 1);

    createAdvantageCard( ...
        advantageGrid, ...
        'PSNR', ...
        sprintf('+%.2f dB', psnrGain), ...
        1, 2);

    createAdvantageCard( ...
        advantageGrid, ...
        'MSE', ...
        sprintf('%.4f lower', mseReduction), ...
        2, 1);

    createAdvantageCard( ...
        advantageGrid, ...
        'SSIM', ...
        sprintf('+%.4f', ssimGain), ...
        2, 2);

    %% ================================================================
    %  ADAPTIVE BLOCK DISTRIBUTION
    %  ================================================================

    footerPanel = uipanel(mainGrid);

    footerPanel.Layout.Row = 6;

    footerPanel.BorderType = 'line';

    footerGrid = ...
        uigridlayout(footerPanel, [1 4]);

    footerGrid.ColumnWidth = ...
        {'1x','1x','1x','1x'};

    footerGrid.Padding = ...
        [8 3 8 3];

    footerGrid.ColumnSpacing = 5;

    createBlockCard( ...
        footerGrid, ...
        'HIGH DETAIL', ...
        adaptiveMetrics.HighDetailBlocks);

    createBlockCard( ...
        footerGrid, ...
        'MEDIUM DETAIL', ...
        adaptiveMetrics.MediumDetailBlocks);

    createBlockCard( ...
        footerGrid, ...
        'LOW DETAIL', ...
        adaptiveMetrics.LowDetailBlocks);

    createBlockCard( ...
        footerGrid, ...
        'TOTAL BLOCKS', ...
        adaptiveMetrics.TotalBlocks);

    %% ================================================================
    %  LOCAL FUNCTION: INFORMATION CARD
    %  ================================================================

    function createInfoCard(parent, heading, value)

        card = uipanel(parent);

        card.BorderType = 'none';

        card.BackgroundColor = ...
            [0.94 0.95 0.97];

        grid = ...
            uigridlayout(card, [2 1]);

        grid.RowHeight = ...
            {15, '1x'};

        grid.Padding = ...
            [3 2 3 2];

        h = uilabel(grid);

        h.Text = heading;

        h.FontSize = 8;

        h.FontWeight = 'bold';

        h.HorizontalAlignment = ...
            'center';

        v = uilabel(grid);

        v.Text = value;

        v.FontSize = 10;

        v.FontWeight = 'bold';

        v.HorizontalAlignment = ...
            'center';

        v.VerticalAlignment = ...
            'center';

    end

    %% ================================================================
    %  LOCAL FUNCTION: ADVANTAGE CARD
    %  ================================================================

    function createAdvantageCard(parent, heading, value, row, column)

        card = uipanel(parent);

        card.Layout.Row = row;

        card.Layout.Column = column;

        card.BorderType = 'none';

        card.BackgroundColor = ...
            [0.94 0.95 0.97];

        grid = ...
            uigridlayout(card, [2 1]);

        grid.RowHeight = ...
            {15, '1x'};

        grid.Padding = ...
            [3 2 3 2];

        h = uilabel(grid);

        h.Text = heading;

        h.FontSize = 8;

        h.FontWeight = 'bold';

        h.HorizontalAlignment = ...
            'center';

        v = uilabel(grid);

        v.Text = value;

        v.FontSize = 10;

        v.FontWeight = 'bold';

        v.HorizontalAlignment = ...
            'center';

        v.VerticalAlignment = ...
            'center';

    end

    %% ================================================================
    %  LOCAL FUNCTION: BLOCK CARD
    %  ================================================================

    function createBlockCard(parent, heading, value)

        card = uipanel(parent);

        card.BorderType = 'none';

        card.BackgroundColor = ...
            [0.94 0.95 0.97];

        grid = ...
            uigridlayout(card, [1 2]);

        grid.ColumnWidth = ...
            {'1.5x','1x'};

        grid.Padding = ...
            [4 2 4 2];

        h = uilabel(grid);

        h.Text = heading;

        h.FontSize = 8;

        h.FontWeight = 'bold';

        h.HorizontalAlignment = ...
            'right';

        v = uilabel(grid);

        v.Text = sprintf('%d', value);

        v.FontSize = 11;

        v.FontWeight = 'bold';

        v.HorizontalAlignment = ...
            'left';

    end

    %% ================================================================
    %  TRUE SSIM
    %  ================================================================

    function ssimValue = ...
            calculateTrueSSIM(referenceImage, testImage)

        ref = double(referenceImage);
        test = double(testImage);

        if size(ref,3) == 3

            ref = rgb2gray(uint8(ref));

            test = rgb2gray(uint8(test));

        end

        ref = double(ref);
        test = double(test);

        windowSize = 8;

        C1 = ...
            (0.01 * 255)^2;

        C2 = ...
            (0.03 * 255)^2;

        rows = size(ref,1);
        cols = size(ref,2);

        ssimSum = 0;

        count = 0;

        for r = 1:windowSize: ...
                rows-windowSize+1

            for c = 1:windowSize: ...
                    cols-windowSize+1

                refBlock = ...
                    ref(r:r+windowSize-1, ...
                        c:c+windowSize-1);

                testBlock = ...
                    test(r:r+windowSize-1, ...
                         c:c+windowSize-1);

                muRef = ...
                    mean(refBlock(:));

                muTest = ...
                    mean(testBlock(:));

                varianceRef = ...
                    var(refBlock(:),1);

                varianceTest = ...
                    var(testBlock(:),1);

                covariance = ...
                    mean((refBlock(:)-muRef) .* ...
                         (testBlock(:)-muTest));

                numerator = ...
                    (2*muRef*muTest + C1) * ...
                    (2*covariance + C2);

                denominator = ...
                    (muRef^2 + muTest^2 + C1) * ...
                    (varianceRef + varianceTest + C2);

                blockSSIM = ...
                    numerator / denominator;

                ssimSum = ...
                    ssimSum + blockSSIM;

                count = count + 1;

            end

        end

        ssimValue = ...
            ssimSum / count;

    end

end