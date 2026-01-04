# Flyer Enhancement Pipeline

This repository contains an automated image enhancement pipeline for processing flyers with two quality variants: **Conservative** and **Max-Detail**. The pipeline performs non-destructive enhancement including artifact removal, debanding, sharpening, and 2x upscaling while preserving all original content and metadata.

> **Note**: A test image is currently included in `assets/olobe-bukka/input/original.jpg` for pipeline validation. Replace it with your actual flyer image to generate production-quality enhancements.

## Project Structure

```
Desktop/
├── assets/
│   └── olobe-bukka/
│       ├── input/
│       │   └── original.jpg          # Source flyer image
│       └── output/
│           ├── conservative/          # Conservative enhancement outputs
│           │   ├── conservative_original_clean.png
│           │   ├── conservative_x2.png
│           │   └── conservative_x2_q95.jpg
│           └── maxdetail/             # Max-Detail enhancement outputs
│               ├── maxdetail_original_clean.png
│               ├── maxdetail_x2.png
│               └── maxdetail_x2_q95.jpg
├── scripts/
│   └── enhance.sh                     # Main enhancement script
├── .github/
│   └── workflows/
│       └── enhance.yml                # GitHub Actions workflow
└── README.md                          # This file
```

## Enhancement Variants

### Conservative Variant
- **Purpose**: Natural-looking enhancement with minimal processing
- **Processing**:
  - Gentle artifact removal and debanding
  - Subtle sharpening (0.5x0.5+0.5+0.008)
  - 2x upscaling using Real-ESRGAN or Lanczos filter
  - Minimal noise reduction
- **Best for**: Preserving the exact original look with slight quality improvements

### Max-Detail Variant
- **Purpose**: Maximum clarity and detail enhancement
- **Processing**:
  - Aggressive debanding using FFmpeg's hqdn3d filter
  - Enhanced sharpening (1.0x1.0+1.0+0.05)
  - 2x upscaling using Real-ESRGAN (anime model preferred)
  - Strong noise reduction
  - Additional text clarity enhancement
- **Best for**: Print-ready outputs, large displays, maximum legibility

## Output Files

Each variant produces three files:

1. **`*_original_clean.png`** - Cleaned original at source resolution with compression artifacts removed
2. **`*_x2.png`** - 2x upscaled version in PNG format (lossless)
3. **`*_x2_q95.jpg`** - 2x upscaled version in JPEG format at 95% quality

All outputs preserve ICC color profiles and EXIF metadata from the source image when available.

## Requirements

### System Dependencies

#### macOS
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install imagemagick ffmpeg exiftool

# Optional: Install Real-ESRGAN for best upscaling quality
# Download from: https://github.com/xinntao/Real-ESRGAN/releases
# Extract and place 'realesrgan-ncnn-vulkan' in the tools/ directory
```

#### Linux (Ubuntu/Debian)
```bash
# Update package list
sudo apt-get update

# Install required tools
sudo apt-get install -y imagemagick ffmpeg libimage-exiftool-perl

# Optional: Install Real-ESRGAN for best upscaling quality
mkdir -p tools
cd tools
wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
unzip realesrgan-ncnn-vulkan-20220424-ubuntu.zip
mv realesrgan-ncnn-vulkan-20220424-ubuntu/realesrgan-ncnn-vulkan ./
chmod +x realesrgan-ncnn-vulkan
rm -rf realesrgan-ncnn-vulkan-20220424-ubuntu.zip realesrgan-ncnn-vulkan-20220424-ubuntu
cd ..
```

### Tool Versions

Tested with:
- **ImageMagick**: 6.9+ or 7.0+
- **FFmpeg**: 4.2+
- **ExifTool**: 11.0+
- **Real-ESRGAN**: v0.2.0 (optional but recommended)

## Usage

### Running Locally

1. **Place your source image** in the input directory:
   ```bash
   # Place your image as:
   # assets/olobe-bukka/input/original.jpg
   # or
   # assets/olobe-bukka/input/original.png
   ```

2. **Run the enhancement script**:
   ```bash
   # From repository root
   bash scripts/enhance.sh assets/olobe-bukka/input/original.jpg
   ```

3. **Find outputs** in:
   - `assets/olobe-bukka/output/conservative/`
   - `assets/olobe-bukka/output/maxdetail/`

### Running via GitHub Actions

1. **Navigate to Actions tab** in your GitHub repository
2. **Select "Flyer Enhancement Pipeline"** workflow
3. **Click "Run workflow"**
4. **Optionally specify** input image path (defaults to `assets/olobe-bukka/input/original.jpg`)
5. **Wait for completion** (typically 2-5 minutes)
6. **Download artifacts** from the workflow run:
   - `conservative-variant` - Conservative enhancement outputs
   - `maxdetail-variant` - Max-Detail enhancement outputs
   - `all-enhanced-outputs` - All files combined

## Pipeline Details

### Processing Steps

#### Conservative Variant
1. **Clean Original**: PNG conversion with optimal compression
2. **Gentle Debanding**: Ordered dithering (o8x8,8) + minimal blur (0x0.3)
3. **Subtle Sharpening**: Unsharp mask (0x0.5)
4. **2x Upscale**: Real-ESRGAN or Lanczos interpolation
5. **Format Export**: PNG (lossless) and JPEG (q95)
6. **Metadata Preservation**: Copy ICC/EXIF from source

#### Max-Detail Variant
1. **Clean Original**: PNG conversion with optimal compression
2. **Aggressive Debanding**: FFmpeg hqdn3d filter (1.5:1.5)
3. **Strong Sharpening**: Unsharp mask (0x1.0 during debanding)
4. **2x Upscale**: Real-ESRGAN (anime model preferred)
5. **Text Enhancement**: Additional sharpening (0x1.0+0.8+0.01)
6. **Format Export**: PNG (lossless) and JPEG (q95)
7. **Metadata Preservation**: Copy ICC/EXIF from source

### Real-ESRGAN Integration

The script automatically detects and uses Real-ESRGAN if available:

- **Location check**: `tools/realesrgan-ncnn-vulkan` (local) or system PATH
- **Conservative**: Uses `realesrgan-x4plus` model with 2x scaling
- **Max-Detail**: Prefers `realesrgan-x4plus-anime` model, falls back to standard
- **Fallback**: If Real-ESRGAN unavailable, uses ImageMagick Lanczos filter

### Metadata Preservation

When ExifTool is available:
- Copies all EXIF tags from source to outputs
- Preserves ICC color profiles
- Maintains creation dates and camera info
- Retains copyright and author information

## Technical Specifications

### Image Quality Settings

| Parameter | Conservative | Max-Detail |
|-----------|--------------|------------|
| Noise Reduction | Minimal (blur 0x0.3) | Strong (hqdn3d 1.5:1.5) |
| Sharpening (pre-upscale) | 0x0.5 | 0x1.0 |
| Sharpening (post-upscale) | 0.5x0.5+0.5+0.008 | 1.0x1.0+1.0+0.05 |
| Upscale Filter | Real-ESRGAN x4plus | Real-ESRGAN x4plus-anime |
| Dithering | o8x8,8 | o8x8,8 |
| JPEG Quality | 95 | 95 |

### Color Management

- PNG outputs preserve full color depth and ICC profiles
- JPEG exports use 95% quality to minimize compression artifacts
- No color space conversion unless required by output format
- Preserves original gamma and color profiles

## Troubleshooting

### Script fails with "command not found"
- Ensure all dependencies are installed (ImageMagick, FFmpeg, ExifTool)
- Check that binaries are in your PATH: `which convert ffmpeg exiftool`

### Real-ESRGAN not found
- The script will fall back to ImageMagick's Lanczos filter
- For best quality, download Real-ESRGAN binary for your platform
- Place in `tools/` directory or system PATH

### Workflow fails with "Input image not found"
- Ensure source image is committed to repository
- Default path: `assets/olobe-bukka/input/original.jpg`
- Use workflow input to specify alternative path

### Outputs look over-sharpened
- Use Conservative variant for more natural results
- Adjust unsharp mask parameters in `scripts/enhance.sh`

### Colors look different from original
- Check ICC profile preservation with: `exiftool -ICC_Profile output.png`
- Ensure your viewer supports color management
- Compare in same application for consistent rendering

## Customization

To modify enhancement parameters, edit `scripts/enhance.sh`:

- **Debanding strength**: Adjust `-ordered-dither` and blur values
- **Sharpening**: Modify `-unsharp` parameters (radius x sigma + amount + threshold)
- **Noise reduction**: Change FFmpeg `hqdn3d` values
- **Upscale ratio**: Modify `-s` parameter for Real-ESRGAN or `-resize` percentage

## Performance

Typical processing times (on modern hardware):

- **Conservative**: 10-30 seconds per image
- **Max-Detail**: 20-60 seconds per image
- **GitHub Actions**: 2-5 minutes total (including setup)

Real-ESRGAN significantly increases processing time but provides superior quality compared to traditional interpolation.

## Additional Documentation

- **[TESTING.md](TESTING.md)** - Comprehensive testing guide, troubleshooting, and quality verification
- **[PIPELINE_REFERENCE.md](PIPELINE_REFERENCE.md)** - Quick reference for all pipeline parameters and settings
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guide for adding and replacing the source image

## License

This pipeline is part of the Desktop repository. Refer to the repository license for usage terms.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review script output for specific error messages
3. Verify all dependencies are correctly installed
4. Open an issue in the GitHub repository

## Credits

- **Real-ESRGAN**: [xinntao/Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN)
- **ImageMagick**: [ImageMagick Studio LLC](https://imagemagick.org/)
- **FFmpeg**: [FFmpeg Developers](https://ffmpeg.org/)
- **ExifTool**: [Phil Harvey](https://exiftool.org/)
