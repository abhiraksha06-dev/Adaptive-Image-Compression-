function [reconstructedImage, metrics] = decompressAdaptiveImage(compressedPath)

    % ============================================================
    % ADAPTIVE DCT DECOMPRESSION + QUALITY EVALUATION
    %
    % Reads the variable-length adaptive DCT representation,
    % reconstructs every 8x8 block, and evaluates quality.
    % ============================================================

    % ------------------------------------------------------------
    % LOAD COMPRESSED DATA
    % ------------------------------------------------------------

    data = load(compressedPath);

    retainedCoefficients = data.retainedCoefficients;
    blockSizes = data.blockSizes;
    blockTypes = data.blockTypes;

    compressedRows = data.compressedRows;
    compressedCols = data.compressedCols;
    channels = data.channels;
    quantMatrix = data.quantMatrix;

    % ------------------------------------------------------------
    % CREATE 8x8 DCT MATRIX
    % ------------------------------------------------------------

    N = 8;

    D = zeros(N,N);

    for k = 0:N-1
        for n = 0:N-1

            if k == 0
                alpha = sqrt(1/N);
            else
                alpha = sqrt(2/N);
            end

            D(k+1,n+1) = ...
                alpha * cos( ...
                (pi * (2*n + 1) * k) / (2*N));

        end
    end

    % ------------------------------------------------------------
    % INITIALIZE RECONSTRUCTED IMAGE
    % ------------------------------------------------------------

    reconstructedImage = zeros( ...
        compressedRows, ...
        compressedCols, ...
        channels);

    % Position inside the sequential coefficient array
    currentPosition = 1;

    % Number of 8x8 blocks
    numRowsBlocks = compressedRows / 8;
    numColsBlocks = compressedCols / 8;

    % ------------------------------------------------------------
    % DECODE EVERY BLOCK
    % ------------------------------------------------------------

    for channel = 1:channels

        for blockRow = 1:numRowsBlocks

            for blockCol = 1:numColsBlocks

                % Get adaptive block size
                blockSize = double( ...
                    blockSizes(blockRow, blockCol));

                % Number of stored coefficients
                numberCoefficients = blockSize^2;

                % ------------------------------------------------
                % CREATE EMPTY 8x8 QUANTIZED DCT BLOCK
                % ------------------------------------------------

                quantizedBlock = zeros(8,8);

                % Find coefficient range
                endPosition = ...
                    currentPosition + ...
                    numberCoefficients - 1;

                % Extract stored coefficients
                selectedCoefficients = ...
                    double(retainedCoefficients( ...
                    currentPosition:endPosition));

                % Put coefficients back into their
                % top-left frequency region
                quantizedBlock( ...
                    1:blockSize, ...
                    1:blockSize) = ...
                    reshape( ...
                    selectedCoefficients, ...
                    blockSize, ...
                    blockSize);

                % Move to next coefficient
                currentPosition = ...
                    endPosition + 1;

                % ------------------------------------------------
                % DEQUANTIZATION
                % ------------------------------------------------

                dctBlock = ...
                    quantizedBlock .* quantMatrix;

                % ------------------------------------------------
                % INVERSE DCT
                % ------------------------------------------------

                reconstructedBlock = ...
                    D' * dctBlock * D;

                % Undo level shift used during compression
                reconstructedBlock = ...
                    reconstructedBlock + 128;

                % ------------------------------------------------
                % PLACE BLOCK INTO IMAGE
                % ------------------------------------------------

                rowStart = ...
                    (blockRow - 1) * 8 + 1;

                colStart = ...
                    (blockCol - 1) * 8 + 1;

                reconstructedImage( ...
                    rowStart:rowStart+7, ...
                    colStart:colStart+7, ...
                    channel) = ...
                    reconstructedBlock;

            end
        end
    end

    % ------------------------------------------------------------
    % CLAMP IMAGE VALUES
    % ------------------------------------------------------------

    reconstructedImage = uint8( ...
        max(0, min(255, reconstructedImage)));

    % ------------------------------------------------------------
    % LOAD ORIGINAL IMAGE FOR QUALITY COMPARISON
    % ------------------------------------------------------------

    projectRoot = pwd;

    originalPath = fullfile( ...
        projectRoot, ...
        'test_images', ...
        'peppers.png');

    if isfile(originalPath)

        originalImage = imread(originalPath);

    else

        originalImage = [];

    end

    % ------------------------------------------------------------
    % QUALITY METRICS
    % ------------------------------------------------------------

    if ~isempty(originalImage)

        % Make original image the same size
        originalImage = ...
            originalImage( ...
            1:compressedRows, ...
            1:compressedCols, :);

        originalDouble = double(originalImage);

        reconstructedDouble = ...
            double(reconstructedImage);

        % --------------------------------------------------------
        % MSE
        % --------------------------------------------------------

        difference = ...
            reconstructedDouble - originalDouble;

        metrics.MSE = ...
            mean(difference(:).^2);

        % --------------------------------------------------------
        % PSNR
        % --------------------------------------------------------

        if metrics.MSE == 0

            metrics.PSNR = Inf;

        else

            metrics.PSNR = ...
                10 * log10( ...
                (255^2) / metrics.MSE);

        end

        % --------------------------------------------------------
        % SIMILARITY
        %
        % Correlation-based similarity measure.
        % This is NOT formal SSIM.
        % --------------------------------------------------------

        originalVector = ...
            originalDouble(:);

        reconstructedVector = ...
            reconstructedDouble(:);

        correlationMatrix = ...
            corrcoef( ...
            originalVector, ...
            reconstructedVector);

        if size(correlationMatrix,1) == 2

            metrics.Similarity = ...
                correlationMatrix(1,2);

        else

            metrics.Similarity = 1;

        end

    else

        metrics.MSE = NaN;
        metrics.PSNR = NaN;
        metrics.Similarity = NaN;

    end

    % ------------------------------------------------------------
    % COMPRESSED FILE SIZE
    % ------------------------------------------------------------

    compressedInfo = dir(compressedPath);

    if ~isempty(compressedInfo)

        metrics.CompressedFileSizeKB = ...
            compressedInfo.bytes / 1024;

    else

        metrics.CompressedFileSizeKB = NaN;

    end

    % ------------------------------------------------------------
    % GENERAL INFORMATION
    % ------------------------------------------------------------

    metrics.ImageHeight = compressedRows;

    metrics.ImageWidth = compressedCols;

    metrics.ColorChannels = channels;

    metrics.BlockSize = 8;

    metrics.Quality = data.quality;

    % ------------------------------------------------------------
    % ADAPTIVE BLOCK STATISTICS
    %
    % IMPORTANT:
    % Use blockTypes instead of blockSizes.
    %
    % blockTypes:
    % 1 = Low Detail
    % 2 = Medium Detail
    % 3 = High Detail
    % ------------------------------------------------------------

    metrics.HighDetailBlocks = ...
        sum(blockTypes(:) == 3);

    metrics.MediumDetailBlocks = ...
        sum(blockTypes(:) == 2);

    metrics.LowDetailBlocks = ...
        sum(blockTypes(:) == 1);

    metrics.TotalBlocks = ...
        numRowsBlocks * numColsBlocks;

    % ------------------------------------------------------------
    % DISPLAY RESULTS
    % ------------------------------------------------------------

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('       ADAPTIVE DCT DECOMPRESSION RESULTS\n');
    fprintf('============================================================\n');

    fprintf('Image Height            : %d pixels\n', ...
        compressedRows);

    fprintf('Image Width             : %d pixels\n', ...
        compressedCols);

    fprintf('Color Channels          : %d\n', ...
        channels);

    fprintf('Compressed File Size    : %.2f KB\n', ...
        metrics.CompressedFileSizeKB);

    fprintf('\n');

    fprintf('MSE                     : %.4f\n', ...
        metrics.MSE);

    fprintf('PSNR                    : %.2f dB\n', ...
        metrics.PSNR);

    fprintf('Similarity              : %.4f\n', ...
        metrics.Similarity);

    fprintf('\n');

    fprintf('High Detail Blocks      : %d\n', ...
        metrics.HighDetailBlocks);

    fprintf('Medium Detail Blocks    : %d\n', ...
        metrics.MediumDetailBlocks);

    fprintf('Low Detail Blocks       : %d\n', ...
        metrics.LowDetailBlocks);

    fprintf('Total Blocks            : %d\n', ...
        metrics.TotalBlocks);

    fprintf('============================================================\n');

end