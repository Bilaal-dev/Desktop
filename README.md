# Olobe Bukka Flyer Enhancement Pipeline

This repository contains a reproducible image enhancement pipeline for the Olobe Bukka business flyer. The pipeline produces two enhancement variants (Conservative and Max-Detail) with multiple output formats while preserving all original content and metadata.

## Overview

The enhancement process:
- **Preserves all original content**: No retouching or content changes
- **Reduces artifacts**: Cleans JPEG blockiness, ringing, and chroma noise
- **Enhances details**: Sharpens text edges and micro-details without halos
- **Upscales 2x**: Uses Real-ESRGAN super-resolution for crisp typography
- **Debands gradients**: Smooths purple gradient background with subtle dithering
- **Preserves metadata**: Maintains ICC color profiles and EXIF data

## Variants

### Conservative Variant
Gentle enhancement focused on artifact cleanup and subtle detail improvement.
- Minimal processing to maintain natural appearance
- Light sharpening (0.8 radius, 0.7 amount)
- Mild debanding for gradients
- Best for maintaining original look with cleaner edges

### Max-Detail Variant
Aggressive enhancement for maximum clarity and detail.
- Noise reduction pre-processing (optional waifu2x)
- Stronger sharpening (1.0 radius, 1.0 amount)
- Micro-contrast enhancement (sigmoidal-contrast)
- Enhanced debanding and dithering
- Best for crisp text and vivid details

## Output Files

Both variants produce three files each:

### Conservative
```
assets/olobe-bukka/output/conservative/
├── conservative_original_clean.png  # Cleaned original (same resolution)
├── conservative_x2.png               # 2x upscale, PNG format
└── conservative_x2_q95.jpg           # 2x upscale, JPEG quality 95
```

### Max-Detail
```
assets/olobe-bukka/output/maxdetail/
├── maxdetail_original_clean.png     # Aggressively cleaned original
├── maxdetail_x2.png                  # 2x upscale, PNG format
└── maxdetail_x2_q95.jpg              # 2x upscale, JPEG quality 95
```

## Requirements

### Software Dependencies

1. **ImageMagick 7+** (required)
   - Used for color processing, sharpening, debanding, and format conversion
   - Must support 16-bit processing and sRGB color space

2. **Real-ESRGAN** (required)
   - `realesrgan-ncnn-vulkan` binary
   - Used for 2x super-resolution upscaling
   - Preserves text edges and fine details

3. **waifu2x-ncnn-vulkan** (optional)
   - Used for noise reduction in Max-Detail variant
   - Recommended but not required

### Installation Instructions

#### macOS

```bash
# Install ImageMagick via Homebrew
brew install imagemagick

# Download Real-ESRGAN
# Visit: https://github.com/xinntao/Real-ESRGAN/releases
# Download realesrgan-ncnn-vulkan for macOS
# Extract and add to PATH or move to /usr/local/bin/

# Optional: Download waifu2x-ncnn-vulkan
# Visit: https://github.com/nihui/waifu2x-ncnn-vulkan/releases
# Download for macOS, extract, and add to PATH
```

#### Linux (Ubuntu/Debian)

```bash
# Install ImageMagick
sudo apt-get update
sudo apt-get install imagemagick

# Download Real-ESRGAN
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
unzip realesrgan-ncnn-vulkan-20220424-ubuntu.zip
sudo mv realesrgan-ncnn-vulkan /usr/local/bin/

# Optional: Download waifu2x-ncnn-vulkan
wget https://github.com/nihui/waifu2x-ncnn-vulkan/releases/download/20220728/waifu2x-ncnn-vulkan-20220728-ubuntu.zip
unzip waifu2x-ncnn-vulkan-20220728-ubuntu.zip
sudo mv waifu2x-ncnn-vulkan-20220728-ubuntu/waifu2x-ncnn-vulkan /usr/local/bin/
```

#### Verification

```bash
# Verify installations
magick -version        # Should show ImageMagick 7.x.x
realesrgan-ncnn-vulkan # Should show usage info
waifu2x-ncnn-vulkan    # Should show usage info (optional)
```

## Usage

### 1. Place Source Image

Put the original flyer image in the input directory:

```bash
# Copy your source image as original.jpg or original.png
cp /path/to/your/flyer.jpg assets/olobe-bukka/input/original.jpg
```

### 2. Run Enhancement Script

```bash
bash scripts/enhance.sh
```

The script will:
1. Check for required dependencies
2. Locate the input image
3. Process the Conservative variant (5 steps)
4. Process the Max-Detail variant (6 steps)
5. Save all outputs to respective directories
6. Display a summary of generated files

### 3. Review Outputs

Check the output directories for the six generated files:

```bash
ls -lh assets/olobe-bukka/output/conservative/
ls -lh assets/olobe-bukka/output/maxdetail/
```

## Pipeline Details

### Conservative Processing Steps

1. **Artifact Cleanup**: Convert to 16-bit, despeckle to reduce noise
2. **2x Upscale**: Real-ESRGAN with `realesrgan-x4plus` model
3. **Light Sharpening**: Unsharp mask (0x0.8+0.7+0.02) for crisp edges
4. **Debanding**: Floyd-Steinberg dithering for smooth gradients
5. **Export**: PNG (lossless) and JPEG quality 95 (4:4:4 sampling)

### Max-Detail Processing Steps

1. **Aggressive Cleanup**: Optional waifu2x noise reduction + double despeckle + enhance
2. **2x Upscale**: Real-ESRGAN with `realesrgan-x4plus` model
3. **Strong Sharpening**: Unsharp mask (0x1.0+1.0+0.02) for maximum clarity
4. **Micro-Contrast**: Sigmoidal contrast (3x50%) for depth
5. **Debanding**: Floyd-Steinberg dithering with median evaluation
6. **Export**: PNG (lossless) and JPEG quality 95 (4:4:4 sampling)

### Metadata Preservation

All ImageMagick and Real-ESRGAN operations preserve:
- ICC color profiles (sRGB maintained throughout)
- EXIF metadata from source image
- Color accuracy and tone mapping

JPEG exports use:
- Quality 95 (high quality, minimal artifacts)
- 4:4:4 chroma sampling (no color subsampling)
- Preserved metadata

## Technical Notes

### Color Space
- All processing in sRGB color space
- 16-bit depth during processing to prevent banding
- 8-bit final output (sufficient for display)

### Real-ESRGAN Settings
- Model: `realesrgan-x4plus` (best for general images)
- Scale: 2x (specified with `-s 2`)
- Format: PNG for lossless intermediate processing

### Sharpening Parameters
- **Conservative**: `0x0.8+0.7+0.02`
  - Radius: 0.8 (moderate edge detection)
  - Amount: 0.7 (gentle enhancement)
  - Threshold: 0.02 (avoid noise amplification)

- **Max-Detail**: `0x1.0+1.0+0.02`
  - Radius: 1.0 (wider edge detection)
  - Amount: 1.0 (strong enhancement)
  - Threshold: 0.02 (preserve smooth areas)

### Gradient Debanding
Floyd-Steinberg dithering applied to prevent banding in purple gradient background while maintaining natural appearance.

## Troubleshooting

### "realesrgan-ncnn-vulkan not found"
- Download from [Real-ESRGAN releases](https://github.com/xinntao/Real-ESRGAN/releases)
- Ensure binary is in PATH or move to `/usr/local/bin/`
- Make executable: `chmod +x realesrgan-ncnn-vulkan`

### "ImageMagick (magick) not found"
- Install ImageMagick 7+ (not version 6)
- On some systems, command might be `magick` or `convert`
- Verify: `magick -version` should show version 7.x.x

### "Vulkan not supported"
- Real-ESRGAN requires Vulkan-compatible GPU
- Update graphics drivers
- Alternative: Use CPU-based tools (slower)

### Memory Issues
- Large images may require significant RAM
- Real-ESRGAN 2x upscale doubles dimensions (4x pixels)
- Close other applications during processing

## File Structure

```
Desktop/
├── assets/
│   └── olobe-bukka/
│       ├── input/
│       │   ├── README.md
│       │   └── original.jpg          # Place source image here
│       └── output/
│           ├── conservative/
│           │   ├── conservative_original_clean.png
│           │   ├── conservative_x2.png
│           │   └── conservative_x2_q95.jpg
│           └── maxdetail/
│               ├── maxdetail_original_clean.png
│               ├── maxdetail_x2.png
│               └── maxdetail_x2_q95.jpg
├── scripts/
│   └── enhance.sh                    # Main processing script
└── README.md                         # This file
```

## Design Considerations

The Olobe Bukka flyer contains:
- **Text content**: Business name, hiring roles, contact information
- **Gold/yellow tones**: Logo and text highlights
- **Purple gradient background**: Requires debanding
- **Food imagery**: Micro-detail enhancement benefits
- **UI elements**: Sharp edges preserved by Real-ESRGAN

The enhancement pipeline is designed to:
- Keep text crisp and legible (critical for hiring information)
- Preserve brand colors (gold and purple)
- Reduce JPEG compression artifacts around text
- Smooth gradient banding without losing depth
- Enhance food image details naturally

## License

This enhancement pipeline is provided as-is for processing the Olobe Bukka flyer. All tools used (ImageMagick, Real-ESRGAN, waifu2x) are open-source with their respective licenses.

## Credits

- **Real-ESRGAN**: Xintao Wang et al. (Tencent ARC Lab)
- **ImageMagick**: ImageMagick Studio LLC
- **waifu2x**: nihui (ncnn-vulkan implementation)

---

For questions or issues with the enhancement pipeline, please check the tool documentation or open an issue in this repository.
