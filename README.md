# Content-Aware Image Compression System

### DCT-Based Frequency Analysis and Edge-Preserving Adaptive Quantization

This project implements an intelligent image compression system that uses Discrete Cosine Transform (DCT) and edge detection to reduce image size while preserving important visual details.

Unlike conventional compression techniques that apply uniform compression across an entire image, this system uses adaptive quantization to analyze different image regions and adjust compression levels according to their edge density and visual complexity.

### Key Features
- DCT-based image frequency transformation.
- Sobel edge detection for identifying important image details.
- Adaptive quantization based on image complexity.
- Comparison between Standard DCT and Adaptive DCT compression.
- Image reconstruction using Inverse DCT.
- Image quality evaluation using MSE, PSNR, and SSIM.
- Interactive Streamlit dashboard for image upload and compression analysis.
- MATLAB-based compression and performance visualization.

### Technologies Used
- Python
- MATLAB
- NumPy
- Streamlit
- Pillow
- Matplotlib

### Objective
To develop an efficient image compression approach that balances storage reduction and image quality by preserving important edges and details while reducing unnecessary frequency information.
