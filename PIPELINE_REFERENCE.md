# Enhancement Pipeline Quick Reference

This document provides a quick reference for the enhancement settings and commands used in the Olobe Bukka flyer enhancement pipeline.

## Command Reference

### Conservative Variant Commands

```bash
# Step 1: Clean original
magick original.jpg \
    -depth 16 \
    -colorspace sRGB \
    -despeckle \
    -quality 100 \
    conservative_original_clean.png

# Step 2: 2x upscale
realesrgan-ncnn-vulkan \
    -i conservative_original_clean.png \
    -o conservative_upscaled.png \
    -s 2 \
    -n realesrgan-x4plus \
    -f png

# Step 3: Light sharpening
magick conservative_upscaled.png \
    -unsharp 0x0.8+0.7+0.02 \
    conservative_sharpened.png

# Step 4: Debanding and dithering
magick conservative_sharpened.png \
    -depth 16 \
    -colorspace sRGB \
    -evaluate-sequence median \
    +dither \
    -colors 16777216 \
    -dither FloydSteinberg \
    -depth 8 \
    conservative_x2.png

# Step 5: JPEG export
magick conservative_x2.png \
    -quality 95 \
    -sampling-factor 4:4:4 \
    conservative_x2_q95.jpg
```

### Max-Detail Variant Commands

```bash
# Step 1: Aggressive cleanup (with optional waifu2x pre-processing)
waifu2x-ncnn-vulkan \
    -i original.jpg \
    -o preclean.png \
    -n 2 \
    -s 1 \
    -f png

magick preclean.png \
    -depth 16 \
    -colorspace sRGB \
    -despeckle \
    -despeckle \
    -enhance \
    -quality 100 \
    maxdetail_original_clean.png

# Step 2: 2x upscale
realesrgan-ncnn-vulkan \
    -i maxdetail_original_clean.png \
    -o maxdetail_upscaled.png \
    -s 2 \
    -n realesrgan-x4plus \
    -f png

# Step 3: Strong sharpening
magick maxdetail_upscaled.png \
    -unsharp 0x1.0+1.0+0.02 \
    maxdetail_sharpened.png

# Step 4: Micro-contrast enhancement
magick maxdetail_sharpened.png \
    -depth 16 \
    -colorspace sRGB \
    -sigmoidal-contrast 3x50% \
    maxdetail_contrast.png

# Step 5: Debanding and dithering
magick maxdetail_contrast.png \
    -depth 16 \
    -colorspace sRGB \
    -evaluate-sequence median \
    +dither \
    -colors 16777216 \
    -dither FloydSteinberg \
    -depth 8 \
    maxdetail_x2.png

# Step 6: JPEG export
magick maxdetail_x2.png \
    -quality 95 \
    -sampling-factor 4:4:4 \
    maxdetail_x2_q95.jpg
```

## Parameter Explanations

### ImageMagick Operations

| Operation | Parameters | Purpose |
|-----------|-----------|---------|
| `-depth 16` | 16-bit | Prevent banding during processing |
| `-colorspace sRGB` | sRGB | Maintain consistent color space |
| `-despeckle` | - | Remove salt-and-pepper noise |
| `-enhance` | - | Statistical noise reduction |
| `-unsharp` | `radius x sigma + amount + threshold` | Edge sharpening |
| `-sigmoidal-contrast` | `contrast x midpoint%` | S-curve contrast |
| `-evaluate-sequence median` | median | Reduce banding artifacts |
| `-dither FloydSteinberg` | - | Error diffusion dithering |
| `-quality 95` | 95% | JPEG quality level |
| `-sampling-factor 4:4:4` | no subsampling | Full chroma resolution |

### Real-ESRGAN Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `-i` | input file | Source image path |
| `-o` | output file | Destination image path |
| `-s` | 2 | Scale factor (2x) |
| `-n` | realesrgan-x4plus | Model name (best for general images) |
| `-f` | png | Output format (lossless) |

### waifu2x Parameters (Optional)

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `-i` | input file | Source image path |
| `-o` | output file | Destination image path |
| `-n` | 2 | Noise reduction level (0-3) |
| `-s` | 1 | Scale factor (1x = no scaling) |
| `-f` | png | Output format |

## Sharpening Settings Comparison

### Conservative: `-unsharp 0x0.8+0.7+0.02`
- **Radius**: 0.8 pixels (moderate halo size)
- **Sigma**: 0 (auto-calculated from radius)
- **Amount**: 0.7 (70% enhancement)
- **Threshold**: 0.02 (ignore noise below 2%)

Result: Gentle sharpening, natural appearance

### Max-Detail: `-unsharp 0x1.0+1.0+0.02`
- **Radius**: 1.0 pixels (wider halo)
- **Sigma**: 0 (auto-calculated)
- **Amount**: 1.0 (100% enhancement)
- **Threshold**: 0.02 (ignore noise below 2%)

Result: Strong sharpening, crisp edges

## Processing Time Estimates

Estimates for a typical 1920x1080 flyer:

| Step | Conservative | Max-Detail |
|------|-------------|------------|
| Cleanup | ~5 sec | ~10 sec (+waifu2x: +30 sec) |
| Real-ESRGAN 2x | ~20-30 sec | ~20-30 sec |
| Sharpening | ~3 sec | ~3 sec |
| Contrast | - | ~3 sec |
| Debanding | ~5 sec | ~5 sec |
| JPEG export | ~2 sec | ~2 sec |
| **Total** | **~40-50 sec** | **~50-60 sec** (+waifu2x: ~80-90 sec) |

Times vary based on CPU/GPU performance. Real-ESRGAN uses GPU (Vulkan) if available.

## Quality Settings Rationale

### PNG Outputs
- Lossless compression
- Preserves all enhanced details
- Larger file sizes (~5-15 MB for 2x upscale)
- Best for archival and further editing

### JPEG q95 Outputs
- Near-lossless quality
- 4:4:4 chroma sampling (no color reduction)
- Smaller file sizes (~2-5 MB for 2x upscale)
- Best for web/print distribution
- Visually identical to PNG for most uses

## Troubleshooting Tips

### Banding in Purple Gradient
- Increase dithering with `-dither FloydSteinberg`
- Use 16-bit processing depth
- Apply `-evaluate-sequence median` before dithering

### Halos Around Text
- Reduce unsharp amount (e.g., 0.5 instead of 0.7)
- Increase threshold (e.g., 0.05 instead of 0.02)
- Use smaller radius (e.g., 0.5 instead of 0.8)

### Over-Sharpened Noise
- Apply more noise reduction in cleanup step
- Use waifu2x with higher `-n` value (3 instead of 2)
- Reduce unsharp amount

### Colors Look Flat
- Increase sigmoidal-contrast (e.g., 4x50% instead of 3x50%)
- Adjust midpoint (e.g., 3x45% for darker, 3x55% for lighter)

### File Size Too Large
- Use JPEG instead of PNG for distribution
- Reduce JPEG quality slightly (q90 instead of q95)
- Consider lossy WebP format as alternative

---

**Note**: All commands preserve ICC profiles and EXIF metadata automatically with ImageMagick and Real-ESRGAN.
