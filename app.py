import numpy as np
import streamlit as st
from PIL import Image

try:
    import matplotlib.pyplot as plt  # type: ignore[reportMissingImports]
except ImportError:
    plt = None


# ================================================================
# CONTENT-AWARE IMAGE COMPRESSION
# DCT + EDGE-PRESERVING ADAPTIVE QUANTIZATION
# ================================================================

st.set_page_config(
    page_title="Content-Aware Image Compression",
    page_icon="🖼️",
    layout="wide",
    initial_sidebar_state="expanded"
)


# ================================================================
# PROFESSIONAL DASHBOARD STYLE
# ================================================================

st.markdown(
    """
    <style>

    /* Main page */
    .block-container {
        max-width: 1500px;
        padding-top: 1rem;
        padding-bottom: 2rem;
    }

    /* Header */
    .hero {
        background: linear-gradient(135deg, #1b2d49, #29456c);
        color: white;
        padding: 24px 30px;
        border-radius: 14px;
        text-align: center;
        margin-bottom: 18px;
        border: 1px solid #3a5578;
    }

    .hero h1 {
        margin: 0;
        font-size: 2.2rem;
        font-weight: 750;
        letter-spacing: 0.5px;
    }

    .hero p {
        margin: 8px 0 0 0;
        font-size: 1rem;
        color: #dce6f3;
    }

    /* Section titles */
    .section-title {
        font-size: 1.15rem;
        font-weight: 750;
        color: #dce6f3;
        margin-top: 18px;
        margin-bottom: 9px;
    }

    /* Information cards */
    .info-card {
        background: #202735;
        border: 1px solid #374151;
        border-radius: 10px;
        padding: 12px 8px;
        text-align: center;
        min-height: 72px;
    }

    .info-label {
        font-size: 0.72rem;
        font-weight: 700;
        color: #9aa7b8;
        text-transform: uppercase;
    }

    .info-value {
        font-size: 1.12rem;
        font-weight: 750;
        color: #f2f5f8;
        margin-top: 5px;
    }

    /* Explanation box */
    .explain {
        background: #202a39;
        border-left: 4px solid #5b86b5;
        border-radius: 6px;
        padding: 10px 13px;
        color: #dce5ef;
        font-size: 0.88rem;
        line-height: 1.45;
        margin: 5px 0 10px 0;
    }

    /* Advantage cards */
    .advantage-card {
        background: #203229;
        border: 1px solid #365641;
        border-radius: 10px;
        padding: 12px 8px;
        text-align: center;
        min-height: 75px;
    }

    .advantage-label {
        font-size: 0.72rem;
        font-weight: 700;
        color: #a9c2ae;
    }

    .advantage-value {
        font-size: 1.2rem;
        font-weight: 750;
        color: #d9f0dc;
        margin-top: 5px;
    }

    /* Upload area */
    [data-testid="stFileUploader"] {
        background: #20232d;
        border: 1px solid #3b4352;
        border-radius: 10px;
        padding: 8px;
    }

    /* Sidebar */
    [data-testid="stSidebar"] {
        background: #20232d;
    }

    /* Metric styling */
    [data-testid="stMetric"] {
        background: #202735;
        border: 1px solid #374151;
        border-radius: 9px;
        padding: 8px;
    }

    /* Table */
    [data-testid="stDataFrame"] {
        border-radius: 8px;
    }

    /* Horizontal line */
    hr {
        border-color: #394250;
    }

    </style>
    """,
    unsafe_allow_html=True
)


# ================================================================
# DCT MATRIX
# ================================================================

@st.cache_data
def create_dct_matrix():

    n = 8

    D = np.zeros((n, n), dtype=np.float64)

    for k in range(n):

        if k == 0:
            alpha = np.sqrt(1 / n)
        else:
            alpha = np.sqrt(2 / n)

        for x in range(n):

            D[k, x] = (
                alpha
                * np.cos(
                    (np.pi * (2 * x + 1) * k)
                    / (2 * n)
                )
            )

    return D


D = create_dct_matrix()


# ================================================================
# JPEG-LIKE QUANTIZATION MATRIX
# ================================================================

JPEG_Q = np.array(
    [
        [16, 11, 10, 16, 24, 40, 51, 61],
        [12, 12, 14, 19, 26, 58, 60, 55],
        [14, 13, 16, 24, 40, 57, 69, 56],
        [14, 17, 22, 29, 51, 87, 80, 62],
        [18, 22, 37, 56, 68, 109, 103, 77],
        [24, 35, 55, 64, 81, 104, 113, 92],
        [49, 64, 78, 87, 103, 121, 120, 101],
        [72, 92, 95, 98, 112, 100, 103, 99]
    ],
    dtype=np.float64
)


def make_quantization_matrix(quality):

    quality = int(np.clip(quality, 1, 100))

    if quality < 50:
        scale = 5000 / quality
    else:
        scale = 200 - (2 * quality)

    matrix = np.floor(
        (JPEG_Q * scale + 50) / 100
    )

    matrix[matrix < 1] = 1
    matrix[matrix > 255] = 255

    return matrix


# ================================================================
# IMAGE FUNCTIONS
# ================================================================

def crop_to_blocks(image):

    height = image.shape[0]
    width = image.shape[1]

    new_height = (height // 8) * 8
    new_width = (width // 8) * 8

    return image[
        :new_height,
        :new_width
    ]


def grayscale(image):

    return (
        0.299 * image[:, :, 0]
        + 0.587 * image[:, :, 1]
        + 0.114 * image[:, :, 2]
    )


# ================================================================
# SOBEL EDGE DETECTION
# ================================================================

def calculate_edges(gray):

    sobel_x = np.array(
        [
            [-1, 0, 1],
            [-2, 0, 2],
            [-1, 0, 1]
        ],
        dtype=np.float64
    )

    sobel_y = np.array(
        [
            [-1, -2, -1],
            [0, 0, 0],
            [1, 2, 1]
        ],
        dtype=np.float64
    )

    padded = np.pad(
        gray,
        1,
        mode="edge"
    )

    gx = np.zeros_like(gray)
    gy = np.zeros_like(gray)

    for i in range(3):

        for j in range(3):

            gx += (
                sobel_x[i, j]
                * padded[
                    i:i + gray.shape[0],
                    j:j + gray.shape[1]
                ]
            )

            gy += (
                sobel_y[i, j]
                * padded[
                    i:i + gray.shape[0],
                    j:j + gray.shape[1]
                ]
            )

    edge_strength = np.sqrt(
        gx ** 2 + gy ** 2
    )

    maximum = edge_strength.max()

    if maximum > 0:

        edge_strength /= maximum

    return edge_strength


# ================================================================
# RETAINED FREQUENCY SIZE
# ================================================================

def retained_frequency_size(
    quality,
    mode
):

    quality = int(
        np.clip(
            quality,
            1,
            100
        )
    )

    if mode == "high":

        value = min(
            100,
            quality + 30
        )

    elif mode == "medium":

        value = quality

    else:

        value = max(
            5,
            quality - 25
        )

    size = int(
        round(
            8 * np.sqrt(
                value / 100
            )
        )
    )

    return max(
        1,
        min(8, size)
    )


# ================================================================
# DCT BLOCK
# ================================================================

def dct_block(block):

    shifted = (
        block.astype(np.float64)
        - 128
    )

    return D @ shifted @ D.T


# ================================================================
# INVERSE DCT
# ================================================================

def inverse_dct_block(coefficients):

    return (
        D.T
        @ coefficients
        @ D
    ) + 128


# ================================================================
# TRUE SSIM
# ================================================================

def calculate_ssim(
    original,
    reconstructed
):

    ref = grayscale(
        original
    ).astype(np.float64)

    test = grayscale(
        reconstructed
    ).astype(np.float64)

    C1 = (
        0.01 * 255
    ) ** 2

    C2 = (
        0.03 * 255
    ) ** 2

    values = []

    for row in range(
        0,
        ref.shape[0] - 7,
        8
    ):

        for col in range(
            0,
            ref.shape[1] - 7,
            8
        ):

            a = ref[
                row:row + 8,
                col:col + 8
            ]

            b = test[
                row:row + 8,
                col:col + 8
            ]

            mean_a = np.mean(a)
            mean_b = np.mean(b)

            variance_a = np.var(a)
            variance_b = np.var(b)

            covariance = np.mean(
                (a - mean_a)
                * (b - mean_b)
            )

            numerator = (
                (2 * mean_a * mean_b + C1)
                * (2 * covariance + C2)
            )

            denominator = (
                (
                    mean_a ** 2
                    + mean_b ** 2
                    + C1
                )
                *
                (
                    variance_a
                    + variance_b
                    + C2
                )
            )

            values.append(
                numerator / denominator
            )

    return float(
        np.mean(values)
    )


# ================================================================
# METRICS
# ================================================================

def calculate_metrics(
    original,
    reconstructed
):

    difference = (
        reconstructed.astype(np.float64)
        - original.astype(np.float64)
    )

    mse = float(
        np.mean(
            difference ** 2
        )
    )

    if mse == 0:

        psnr = float("inf")

    else:

        psnr = float(
            10
            * np.log10(
                (255 ** 2) / mse
            )
        )

    ssim = calculate_ssim(
        original,
        reconstructed
    )

    return {
        "mse": mse,
        "psnr": psnr,
        "ssim": ssim
    }


# ================================================================
# STANDARD DCT COMPRESSION
# ================================================================

def standard_compression(
    image,
    quality
):

    image = crop_to_blocks(
        image
    )

    height = image.shape[0]
    width = image.shape[1]
    channels = image.shape[2]

    Q = make_quantization_matrix(
        quality
    )

    retained_size = (
        retained_frequency_size(
            quality,
            "medium"
        )
    )

    reconstructed = np.zeros_like(
        image,
        dtype=np.float64
    )

    for channel in range(channels):

        for row in range(
            0,
            height,
            8
        ):

            for col in range(
                0,
                width,
                8
            ):

                block = image[
                    row:row + 8,
                    col:col + 8,
                    channel
                ]

                coefficients = (
                    dct_block(block)
                )

                quantized = np.round(
                    coefficients / Q
                )

                selected = np.zeros(
                    (8, 8)
                )

                selected[
                    :retained_size,
                    :retained_size
                ] = quantized[
                    :retained_size,
                    :retained_size
                ]

                dequantized = (
                    selected * Q
                )

                reconstructed[
                    row:row + 8,
                    col:col + 8,
                    channel
                ] = inverse_dct_block(
                    dequantized
                )

    reconstructed = np.clip(
        np.round(reconstructed),
        0,
        255
    ).astype(np.uint8)

    metric = calculate_metrics(
        image,
        reconstructed
    )

    blocks = (
        height // 8
    ) * (
        width // 8
    )

    metric["retained_size"] = (
        retained_size
    )

    metric["retention"] = (
        100
        * retained_size ** 2
        / 64
    )

    metric["blocks"] = blocks

    return (
        image,
        reconstructed,
        metric
    )


# ================================================================
# ADAPTIVE DCT COMPRESSION
# ================================================================

def adaptive_compression(
    image,
    quality
):

    image = crop_to_blocks(
        image
    )

    height = image.shape[0]
    width = image.shape[1]
    channels = image.shape[2]

    gray = grayscale(
        image
    )

    edge_map = calculate_edges(
        gray
    )

    Q = make_quantization_matrix(
        quality
    )

    reconstructed = np.zeros_like(
        image,
        dtype=np.float64
    )

    high_blocks = 0
    medium_blocks = 0
    low_blocks = 0

    retained_coefficients = 0
    total_coefficients = 0

    for row in range(
        0,
        height,
        8
    ):

        for col in range(
            0,
            width,
            8
        ):

            density = float(
                np.mean(
                    edge_map[
                        row:row + 8,
                        col:col + 8
                    ]
                )
            )

            if density > 0.08:

                mode = "high"
                high_blocks += 1

            elif density > 0.03:

                mode = "medium"
                medium_blocks += 1

            else:

                mode = "low"
                low_blocks += 1

            retained_size = (
                retained_frequency_size(
                    quality,
                    mode
                )
            )

            retained_coefficients += (
                retained_size ** 2
            )

            total_coefficients += 64

            for channel in range(
                channels
            ):

                block = image[
                    row:row + 8,
                    col:col + 8,
                    channel
                ]

                coefficients = (
                    dct_block(block)
                )

                quantized = np.round(
                    coefficients / Q
                )

                selected = np.zeros(
                    (8, 8)
                )

                selected[
                    :retained_size,
                    :retained_size
                ] = quantized[
                    :retained_size,
                    :retained_size
                ]

                dequantized = (
                    selected * Q
                )

                reconstructed[
                    row:row + 8,
                    col:col + 8,
                    channel
                ] = inverse_dct_block(
                    dequantized
                )

    reconstructed = np.clip(
        np.round(reconstructed),
        0,
        255
    ).astype(np.uint8)

    metric = calculate_metrics(
        image,
        reconstructed
    )

    total_blocks = (
        high_blocks
        + medium_blocks
        + low_blocks
    )

    metric["retention"] = (
        100
        * retained_coefficients
        / total_coefficients
    )

    metric["high"] = high_blocks
    metric["medium"] = medium_blocks
    metric["low"] = low_blocks
    metric["total"] = total_blocks

    return (
        image,
        reconstructed,
        metric,
        edge_map
    )


# ================================================================
# ESTIMATED COEFFICIENT REPRESENTATION SIZE
# ================================================================

def estimated_size(
    image,
    quality,
    mode,
    metric
):

    channels = image.shape[2]

    if mode == "standard":

        coefficients = (
            metric["blocks"]
            * channels
            * metric["retained_size"] ** 2
        )

    else:

        high = (
            metric["high"]
            * channels
            * retained_frequency_size(
                quality,
                "high"
            ) ** 2
        )

        medium = (
            metric["medium"]
            * channels
            * retained_frequency_size(
                quality,
                "medium"
            ) ** 2
        )

        low = (
            metric["low"]
            * channels
            * retained_frequency_size(
                quality,
                "low"
            ) ** 2
        )

        coefficients = (
            high
            + medium
            + low
        )

    # 2 bytes per retained coefficient
    return (
        coefficients
        * 2
        / 1024
    )


# ================================================================
# SIDEBAR
# ================================================================

with st.sidebar:

    st.markdown("## ⚙️ Experiment Controls")

    quality = st.slider(
        "Compression Quality",
        min_value=10,
        max_value=90,
        value=50,
        step=10
    )

    st.markdown("---")

    st.markdown("### Adaptive Classification")

    st.markdown(
        "**High Detail**  \n"
        "Edge density > 0.08"
    )

    st.markdown(
        "**Medium Detail**  \n"
        "Edge density 0.03–0.08"
    )

    st.markdown(
        "**Low Detail**  \n"
        "Edge density ≤ 0.03"
    )

    st.markdown("---")

    st.markdown("### Project Idea")

    st.markdown(
        """
        <div class="explain">
        The system analyzes image frequency and local edge
        information before deciding how much frequency
        information should be retained in each 8×8 block.
        </div>
        """,
        unsafe_allow_html=True
    )


# ================================================================
# HEADER
# ================================================================

st.markdown(
    """
    <div class="hero">
        <h1>CONTENT-AWARE IMAGE COMPRESSION</h1>
        <p>
        DCT Frequency Analysis &nbsp;|&nbsp;
        Edge Detection &nbsp;|&nbsp;
        Adaptive Quantization
        </p>
    </div>
    """,
    unsafe_allow_html=True
)


# ================================================================
# IMAGE UPLOAD
# ================================================================

st.markdown(
    '<div class="section-title">INPUT IMAGE</div>',
    unsafe_allow_html=True
)

uploaded_file = st.file_uploader(
    "Upload an RGB image",
    type=[
        "png",
        "jpg",
        "jpeg",
        "bmp",
        "tif",
        "tiff"
    ]
)


# ================================================================
# NO IMAGE STATE
# ================================================================

if uploaded_file is None:

    st.info(
        "Upload an image above to start the compression analysis."
    )

    st.stop()


# ================================================================
# LOAD IMAGE
# ================================================================

try:

    original = np.array(
        Image.open(
            uploaded_file
        ).convert("RGB"),
        dtype=np.uint8
    )

except Exception as error:

    st.error(
        f"Unable to read image: {error}"
    )

    st.stop()


if min(
    original.shape[0],
    original.shape[1]
) < 8:

    st.error(
        "Image must be at least 8 × 8 pixels."
    )

    st.stop()


# ================================================================
# RUN COMPRESSION
# ================================================================

with st.spinner(
    "Analyzing image and running compression..."
):

    working, standard_image, standard = (
        standard_compression(
            original,
            quality
        )
    )

    (
        _,
        adaptive_image,
        adaptive,
        edge_map
    ) = adaptive_compression(
        original,
        quality
    )


# ================================================================
# IMAGE INFORMATION
# ================================================================

height = working.shape[0]
width = working.shape[1]
channels = working.shape[2]

uploaded_size_kb = (
    len(
        uploaded_file.getvalue()
    )
    / 1024
)

raw_size_kb = (
    working.size
    / 1024
)


st.markdown(
    '<div class="section-title">'
    'IMAGE & EXPERIMENT INFORMATION'
    '</div>',
    unsafe_allow_html=True
)


info_columns = st.columns(5)

information = [
    ("IMAGE", uploaded_file.name),
    ("RESOLUTION", f"{width} × {height}"),
    ("FORMAT", "RGB"),
    ("ORIGINAL SIZE", f"{uploaded_size_kb:.2f} KB"),
    ("QUALITY", f"{quality} / 100")
]


for column, (
    label,
    value
) in zip(
    info_columns,
    information
):

    with column:

        st.markdown(
            f"""
            <div class="info-card">
                <div class="info-label">
                    {label}
                </div>
                <div class="info-value">
                    {value}
                </div>
            </div>
            """,
            unsafe_allow_html=True
        )


# ================================================================
# IMAGE ANALYSIS
# ================================================================

st.markdown(
    '<div class="section-title">'
    '1–3. IMAGE ANALYSIS'
    '</div>',
    unsafe_allow_html=True
)


analysis_1, analysis_2, analysis_3 = (
    st.columns(3)
)


# ================================================================
# ORIGINAL IMAGE
# ================================================================

with analysis_1:

    st.subheader(
        "1. Original Image"
    )

    st.image(
        working,
        caption="Input RGB image",
        use_container_width=True
    )

    st.caption(
        f"{width} × {height} pixels | "
        f"{channels} color channels"
    )


# ================================================================
# FREQUENCY SPECTRUM
# ================================================================

with analysis_2:

    st.subheader(
        "2. Frequency Analysis"
    )

    gray = grayscale(
        working
    )

    spectrum = np.log1p(
        np.abs(
            np.fft.fftshift(
                np.fft.fft2(gray)
            )
        )
    )

    figure, axis = plt.subplots(
        figsize=(5, 4)
    )

    axis.imshow(
        spectrum,
        cmap="gray"
    )

    axis.set_title(
        "Frequency Spectrum"
    )

    axis.axis("off")

    st.pyplot(
        figure,
        use_container_width=True
    )

    plt.close(figure)

    st.caption(
        "Center = low frequency | "
        "Outer regions = high frequency"
    )


# ================================================================
# EDGE MAP
# ================================================================

with analysis_3:

    st.subheader(
        "3. Edge / Detail Analysis"
    )

    figure, axis = plt.subplots(
        figsize=(5, 4)
    )

    axis.imshow(
        edge_map,
        cmap="gray"
    )

    axis.set_title(
        "Edge Strength Map"
    )

    axis.axis("off")

    st.pyplot(
        figure,
        use_container_width=True
    )

    plt.close(figure)

    st.caption(
        "Strong edges receive more frequency information."
    )


# ================================================================
# RECONSTRUCTION
# ================================================================

st.markdown(
    '<div class="section-title">'
    '4–5. RECONSTRUCTION RESULTS'
    '</div>',
    unsafe_allow_html=True
)


reconstruction_1, reconstruction_2 = (
    st.columns(2)
)


# ================================================================
# STANDARD DCT
# ================================================================

with reconstruction_1:

    st.subheader(
        "4. Standard DCT — Uniform Compression"
    )

    image_column, result_column = (
        st.columns([1.3, 1])
    )

    with image_column:

        st.image(
            standard_image,
            caption="Standard DCT reconstruction",
            use_container_width=True
        )

    with result_column:

        st.markdown(
            """
            <div class="explain">
            <b>Method</b><br>
            The same compression strength is applied
            to every 8×8 image block.
            </div>
            """,
            unsafe_allow_html=True
        )

        st.metric(
            "PSNR",
            f"{standard['psnr']:.2f} dB"
        )

        st.metric(
            "SSIM",
            f"{standard['ssim']:.4f}"
        )

        st.metric(
            "MSE",
            f"{standard['mse']:.4f}"
        )


# ================================================================
# ADAPTIVE DCT
# ================================================================

with reconstruction_2:

    st.subheader(
        "5. Adaptive DCT — Content-Aware Compression"
    )

    image_column, result_column = (
        st.columns([1.3, 1])
    )

    with image_column:

        st.image(
            adaptive_image,
            caption="Adaptive DCT reconstruction",
            use_container_width=True
        )

    with result_column:

        st.markdown(
            """
            <div class="explain">
            <b>Method</b><br>
            Compression strength changes according to
            local image detail. Detailed regions retain
            more frequency coefficients.
            </div>
            """,
            unsafe_allow_html=True
        )

        st.metric(
            "PSNR",
            f"{adaptive['psnr']:.2f} dB"
        )

        st.metric(
            "SSIM",
            f"{adaptive['ssim']:.4f}"
        )

        st.metric(
            "MSE",
            f"{adaptive['mse']:.4f}"
        )


# ================================================================
# PERFORMANCE
# ================================================================

st.markdown(
    '<div class="section-title">'
    '6. PERFORMANCE COMPARISON'
    '</div>',
    unsafe_allow_html=True
)


standard_size = estimated_size(
    working,
    quality,
    "standard",
    standard
)

adaptive_size = estimated_size(
    working,
    quality,
    "adaptive",
    adaptive
)


standard_ratio = (
    raw_size_kb
    / standard_size
)

adaptive_ratio = (
    raw_size_kb
    / adaptive_size
)


standard_saving = (
    100
    * (
        1
        - standard_size
        / raw_size_kb
    )
)

adaptive_saving = (
    100
    * (
        1
        - adaptive_size
        / raw_size_kb
    )
)


comparison = {

    "Metric": [
        "Estimated Size (KB)",
        "Compression Ratio",
        "Space Saving",
        "MSE",
        "PSNR (dB)",
        "SSIM",
        "Coefficient Retention"
    ],

    "Standard DCT": [

        f"{standard_size:.2f}",

        f"{standard_ratio:.2f} : 1",

        f"{standard_saving:.2f} %",

        f"{standard['mse']:.4f}",

        f"{standard['psnr']:.2f}",

        f"{standard['ssim']:.4f}",

        f"{standard['retention']:.2f} %"
    ],

    "Adaptive DCT": [

        f"{adaptive_size:.2f}",

        f"{adaptive_ratio:.2f} : 1",

        f"{adaptive_saving:.2f} %",

        f"{adaptive['mse']:.4f}",

        f"{adaptive['psnr']:.2f}",

        f"{adaptive['ssim']:.4f}",

        f"{adaptive['retention']:.2f} %"
    ]
}


st.dataframe(
    comparison,
    use_container_width=True,
    hide_index=True
)


st.caption(
    "Size values shown here are estimated retained-coefficient "
    "representation sizes for the browser implementation."
)


# ================================================================
# ADAPTIVE ADVANTAGE
# ================================================================

st.markdown(
    '<div class="section-title">'
    '7. ADAPTIVE ADVANTAGE'
    '</div>',
    unsafe_allow_html=True
)


size_gain = (
    standard_size
    - adaptive_size
)

psnr_gain = (
    adaptive["psnr"]
    - standard["psnr"]
)

mse_gain = (
    standard["mse"]
    - adaptive["mse"]
)

ssim_gain = (
    adaptive["ssim"]
    - standard["ssim"]
)


advantage_columns = (
    st.columns(4)
)


advantages = [

    (
        "FILE SIZE",
        f"{size_gain:.2f} KB smaller"
    ),

    (
        "PSNR",
        f"{psnr_gain:+.2f} dB"
    ),

    (
        "MSE",
        f"{mse_gain:.4f} lower"
    ),

    (
        "SSIM",
        f"{ssim_gain:+.4f}"
    )
]


for column, (
    label,
    value
) in zip(
    advantage_columns,
    advantages
):

    with column:

        st.markdown(
            f"""
            <div class="advantage-card">
                <div class="advantage-label">
                    {label}
                </div>
                <div class="advantage-value">
                    {value}
                </div>
            </div>
            """,
            unsafe_allow_html=True
        )


# ================================================================
# ADAPTIVE BLOCK DISTRIBUTION
# ================================================================

st.markdown(
    '<div class="section-title">'
    'ADAPTIVE BLOCK DISTRIBUTION'
    '</div>',
    unsafe_allow_html=True
)


block_columns = (
    st.columns(4)
)


block_information = [

    (
        "HIGH DETAIL",
        adaptive["high"]
    ),

    (
        "MEDIUM DETAIL",
        adaptive["medium"]
    ),

    (
        "LOW DETAIL",
        adaptive["low"]
    ),

    (
        "TOTAL BLOCKS",
        adaptive["total"]
    )
]


for column, (
    label,
    value
) in zip(
    block_columns,
    block_information
):

    with column:

        st.markdown(
            f"""
            <div class="info-card">
                <div class="info-label">
                    {label}
                </div>
                <div class="info-value">
                    {value}
                </div>
            </div>
            """,
            unsafe_allow_html=True
        )


# ================================================================
# WHAT THE RESULTS MEAN
# ================================================================

st.markdown(
    '<div class="section-title">'
    'RESULT INTERPRETATION'
    '</div>',
    unsafe_allow_html=True
)


st.markdown(
    f"""
    <div class="explain">

    <b>Standard DCT:</b>
    applies the same frequency-retention strategy
    to every 8×8 image block.

    <br><br>

    <b>Adaptive DCT:</b>
    analyzes local edge strength and changes the
    retained frequency region according to image detail.

    <br><br>

    <b>At quality {quality}:</b>
    Adaptive DCT achieved
    <b>{adaptive['psnr']:.2f} dB PSNR</b>
    and
    <b>{adaptive['ssim']:.4f} SSIM</b>.

    The image was classified into
    <b>{adaptive['high']}</b> high-detail blocks,
    <b>{adaptive['medium']}</b> medium-detail blocks,
    and
    <b>{adaptive['low']}</b> low-detail blocks.

    </div>
    """,
    unsafe_allow_html=True
)


# ================================================================
# FOOTER
# ================================================================

st.markdown("---")

st.caption(
    "Content-Aware Image Compression | "
    "Manual 8×8 DCT | Sobel Edge Analysis | "
    "Adaptive Frequency Retention"
)