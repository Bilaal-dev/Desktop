# Quick Start Guide - Olobe Bukka Flyer Enhancement

This guide will help you get started quickly with enhancing the Olobe Bukka flyer.

## Prerequisites Check

Before starting, verify you have the required tools:

```bash
# Check ImageMagick
magick -version
# Should show: Version: ImageMagick 7.x.x

# Check Real-ESRGAN
realesrgan-ncnn-vulkan
# Should show usage information

# Optional: Check waifu2x
waifu2x-ncnn-vulkan
# Should show usage information
```

If any tool is missing, see the [README.md](README.md#installation-instructions) for installation instructions.

## Step-by-Step Usage

### 1. Add Your Source Image

Place the flyer image in the input directory:

```bash
# Option 1: Copy from your downloads
cp ~/Downloads/olobe-bukka-flyer.jpg assets/olobe-bukka/input/original.jpg

# Option 2: If you have a PNG
cp ~/Downloads/olobe-bukka-flyer.png assets/olobe-bukka/input/original.png
```

### 2. Run the Enhancement Script

```bash
bash scripts/enhance.sh
```

You'll see colored output showing progress:
- **GREEN [INFO]**: Progress messages
- **YELLOW [WARN]**: Optional features (like waifu2x)
- **RED [ERROR]**: Problems that need fixing

### 3. Review the Results

Once complete, check the output directories:

```bash
# Conservative variant (gentle enhancement)
ls -lh assets/olobe-bukka/output/conservative/
# You should see:
# - conservative_original_clean.png
# - conservative_x2.png
# - conservative_x2_q95.jpg

# Max-Detail variant (aggressive enhancement)
ls -lh assets/olobe-bukka/output/maxdetail/
# You should see:
# - maxdetail_original_clean.png
# - maxdetail_x2.png
# - maxdetail_x2_q95.jpg
```

### 4. Compare Variants

**Conservative** is best when:
- You want to maintain the original look
- Artifact cleanup is the main goal
- Natural appearance is preferred

**Max-Detail** is best when:
- You need maximum clarity and sharpness
- Text legibility is critical
- You want vivid, enhanced details

## Expected Results

All outputs will:
- ✓ Preserve all original content (no retouching)
- ✓ Have clearer, crisper text edges
- ✓ Show reduced JPEG artifacts and noise
- ✓ Display smoother purple gradient background
- ✓ Maintain natural gold/yellow tones
- ✓ Include preserved ICC/EXIF metadata

## Processing Time

For a typical 1920x1080 flyer:
- **Conservative**: ~40-50 seconds
- **Max-Detail**: ~50-60 seconds (or ~80-90 with waifu2x)

GPU acceleration (Vulkan) is used if available.

## What's Happening Behind the Scenes?

The script performs these steps for each variant:

### Conservative (5 steps)
1. Clean artifacts from original → save as `*_original_clean.png`
2. Upscale 2x with Real-ESRGAN
3. Apply light sharpening
4. Deband gradients with dithering
5. Export PNG and JPEG q95

### Max-Detail (6 steps)
1. Aggressive cleanup (optionally with waifu2x) → save as `*_original_clean.png`
2. Upscale 2x with Real-ESRGAN
3. Apply strong sharpening
4. Enhance micro-contrast
5. Deband gradients with dithering
6. Export PNG and JPEG q95

## Choosing Output Format

**When to use PNG** (`*_x2.png`):
- Archival storage
- Further editing needed
- File size not a concern

**When to use JPEG** (`*_x2_q95.jpg`):
- Web distribution
- Printing
- Email/sharing
- Smaller file size needed

Both formats maintain high quality. JPEG q95 is visually identical to PNG for most purposes.

## Troubleshooting

### Script exits with "No input image found"
→ Make sure you copied the image as `original.jpg` or `original.png` in `assets/olobe-bukka/input/`

### Script exits with "realesrgan-ncnn-vulkan not found"
→ Download and install Real-ESRGAN from [releases page](https://github.com/xinntao/Real-ESRGAN/releases)

### Script exits with "ImageMagick (magick) not found"
→ Install ImageMagick 7+ (not version 6):
- macOS: `brew install imagemagick`
- Linux: `sudo apt-get install imagemagick`

### Real-ESRGAN crashes or gives Vulkan error
→ Update your graphics drivers or use CPU mode (slower)

### Process takes too long
→ This is normal for large images. Real-ESRGAN processing can take 20-60 seconds depending on your GPU.

## File Sizes (Approximate)

For a 2x upscaled image from 1920x1080 source:

| File | Format | Size |
|------|--------|------|
| `*_original_clean.png` | PNG | 3-8 MB |
| `*_x2.png` | PNG | 10-20 MB |
| `*_x2_q95.jpg` | JPEG | 2-6 MB |

Sizes vary based on image complexity.

## Next Steps

After generating the enhanced images:

1. **Compare variants**: Open both conservative and max-detail outputs side by side
2. **Check text clarity**: Zoom in to verify text edges are crisp
3. **Verify colors**: Ensure gold and purple tones look natural
4. **Choose your favorite**: Pick the variant that best suits your needs
5. **Use the JPEG for distribution**: It's smaller and compatible with all platforms

## Advanced Usage

For custom processing, see [PIPELINE_REFERENCE.md](PIPELINE_REFERENCE.md) for individual command syntax and parameter explanations.

## Need Help?

1. Check the main [README.md](README.md) for detailed information
2. Review [PIPELINE_REFERENCE.md](PIPELINE_REFERENCE.md) for technical details
3. Verify all dependencies are properly installed
4. Check that your source image is valid (not corrupted)

---

**Ready?** Place your image and run: `bash scripts/enhance.sh`
