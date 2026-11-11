# Content-Aware Image Compression System

### DCT-Based Frequency Analysis and Edge-Preserving Adaptive Quantization

## Overview

Content-Aware Image Compression System is an image processing project designed to reduce image storage requirements while preserving important visual information and image quality.

The project implements Discrete Cosine Transform (DCT), Sobel Edge Detection, and Adaptive Quantization to analyze image frequency components and identify regions containing important visual details.

Unlike conventional image compression techniques that apply uniform compression across all image regions, this system uses an adaptive approach that adjusts compression strength according to the local complexity and edge density of different image blocks.

The system divides images into 8×8 pixel blocks, performs frequency-domain transformation, and classifies image regions into high-detail, medium-detail, and low-detail categories. More frequency coefficients are retained in detailed regions, while fewer coefficients are retained in smoother regions.

The project includes a Python-based interactive Streamlit dashboard and a MATLAB-based image compression and analysis implementation.

The primary goal is to demonstrate how frequency-domain image processing and adaptive quantization can improve the balance between compression efficiency and reconstructed image quality.

## Features

- **DCT-Based Compression:** Converts image information into frequency-domain coefficients using Discrete Cosine Transform.
- **8×8 Block Processing:** Divides images into smaller blocks for localized frequency analysis.
- **Sobel Edge Detection:** Identifies important edges and structural details within images.
- **Adaptive Quantization:** Dynamically adjusts the number of retained frequency coefficients according to image complexity.
- **Detail Classification:** Categorizes image blocks into high-detail, medium-detail, and low-detail regions.
- **Standard DCT Compression:** Implements conventional uniform frequency coefficient retention for comparison.
- **Adaptive DCT Compression:** Preserves more frequency information in visually important regions.
- **Inverse DCT Reconstruction:** Reconstructs compressed images from their retained frequency coefficients.
- **Compression Quality Control:** Allows users to adjust compression quality through interactive controls.
- **Performance Evaluation:** Measures image quality using MSE, PSNR, and SSIM.
- **Compression Comparison:** Compares Standard DCT and Adaptive DCT results.
- **Interactive Dashboard:** Provides image upload, visualization, compression analysis, and performance statistics.
- **MATLAB Visualization:** Provides a dedicated dashboard for frequency analysis, edge detection, image reconstruction, and performance comparison.

## System Architecture

The project follows a structured image processing and compression pipeline:

```text
             INPUT IMAGE
                  |
                  v
          IMAGE PREPROCESSING
                  |
                  v
          DIVIDE INTO 8x8 BLOCKS
                  |
                  v
          DISCRETE COSINE
             TRANSFORM
                  |
                  v
          FREQUENCY ANALYSIS
                  |
                  v
           SOBEL EDGE DETECTION
                  |
                  v
          EDGE DENSITY ANALYSIS
                  |
                  v
          ADAPTIVE CLASSIFICATION
                  |
          +-------+-------+
          |       |       |
          v       v       v
         HIGH   MEDIUM   LOW
        DETAIL  DETAIL  DETAIL
          |       |       |
          v       v       v
       MORE    MODERATE  FEWER
     COEFFICIENTS         COEFFICIENTS
          |       |       |
          +-------+-------+
                  |
                  v
          ADAPTIVE QUANTIZATION
                  |
                  v
             DEQUANTIZATION
                  |
                  v
              INVERSE DCT
                  |
                  v
          RECONSTRUCTED IMAGE
                  |
                  v
          QUALITY EVALUATION
                  |
                  v
          MSE | PSNR | SSIM
                  |
                  v
          PERFORMANCE DASHBOARD
```

## System Modules

### 1. Image Input and Preprocessing

The system accepts RGB images in common image formats, including:

- PNG
- JPG
- JPEG
- BMP
- TIFF

The uploaded image is converted into RGB format and prepared for block-based processing.

The image dimensions are adjusted to ensure compatibility with 8×8 block processing.

### 2. Discrete Cosine Transform (DCT)

DCT converts spatial image information into frequency-domain coefficients.

Each 8×8 image block is transformed into frequency components.

These components represent:

- Low-frequency information: General image structure and smooth variations.
- High-frequency information: Fine details, edges, and rapid intensity changes.

The frequency coefficients are used to determine which image information should be retained during compression.

### 3. Sobel Edge Detection

The system implements Sobel edge detection to identify important visual structures.

Horizontal and vertical edge information is calculated using Sobel operators.

The resulting edge strength map helps determine the amount of detail present in each 8×8 image block.

### 4. Adaptive Block Classification

Based on the calculated edge density, each image block is classified into three categories:

| Classification | Edge Density | Compression Strategy |
|---|---|---|
| High Detail | > 0.08 | Retains more frequency coefficients |
| Medium Detail | 0.03–0.08 | Retains a moderate number of coefficients |
| Low Detail | ≤ 0.03 | Retains fewer frequency coefficients |

This classification allows the system to allocate frequency information according to local image complexity.

### 5. Quantization

Quantization reduces the precision of frequency coefficients using a JPEG-like quantization matrix.

The system adjusts the quantization matrix according to the selected compression quality.

Adaptive quantization further determines how many frequency coefficients should be retained in each image block.

### 6. Standard DCT Compression

Standard DCT applies uniform compression across all image blocks.

The same frequency-retention strategy is applied regardless of the local image detail.

This implementation serves as a baseline for evaluating the adaptive compression technique.

### 7. Adaptive DCT Compression

Adaptive DCT applies different compression strengths according to the edge density of individual image blocks.

- High-detail regions preserve more frequency information.
- Medium-detail regions retain a moderate amount of information.
- Low-detail regions retain fewer frequency coefficients.

This approach aims to preserve important visual structures while reducing unnecessary frequency information.

### 8. Image Reconstruction

The compressed frequency coefficients are dequantized and processed using Inverse Discrete Cosine Transform (IDCT).

The reconstructed blocks are combined to produce the final compressed image.

### 9. Image Quality Evaluation

The system evaluates reconstructed image quality using three performance metrics:

| Metric | Purpose |
|---|---|
| MSE (Mean Squared Error) | Measures the average pixel-level reconstruction error. |
| PSNR (Peak Signal-to-Noise Ratio) | Measures reconstruction quality in decibels. |
| SSIM (Structural Similarity Index) | Evaluates structural similarity between original and reconstructed images. |

These metrics help evaluate the effectiveness of Standard DCT and Adaptive DCT compression.

## Dashboard Modules

The Python Streamlit dashboard provides the following sections:

| Module | Functionality |
|---|---|
| Image Upload | Uploads images for compression analysis. |
| Experiment Controls | Adjusts compression quality. |
| Image Information | Displays image name, resolution, format, and size. |
| Frequency Analysis | Processes image frequency components. |
| Edge Detection | Displays edge information and detail classification. |
| Standard DCT | Displays the conventionally compressed image. |
| Adaptive DCT | Displays the content-aware reconstructed image. |
| Performance Comparison | Compares compression metrics. |
| Adaptive Advantage | Displays improvements in compression and reconstruction quality. |
| Block Distribution | Displays high-detail, medium-detail, and low-detail block statistics. |

The MATLAB dashboard additionally provides visualizations of the original image, frequency spectrum, edge strength map, reconstructed images, and compression performance.

## Technology Stack

**Programming Languages**
- Python
- MATLAB

**Image Processing and Numerical Computing**
- NumPy
- Pillow
- MATLAB Image Processing Functions

**Algorithms**
- Discrete Cosine Transform (DCT)
- Inverse Discrete Cosine Transform (IDCT)
- Sobel Edge Detection
- Adaptive Quantization
- Frequency Domain Analysis

**Frontend and Visualization**
- Streamlit
- Matplotlib
- MATLAB App Designer UI Components
- HTML and CSS (Streamlit Dashboard Styling)

**Performance Evaluation**
- Mean Squared Error (MSE)
- Peak Signal-to-Noise Ratio (PSNR)
- Structural Similarity Index (SSIM)

## Project Structure

```text
Content-Aware-Image-Compression/
│
├── app(2).py
