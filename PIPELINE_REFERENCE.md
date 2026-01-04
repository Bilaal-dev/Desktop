# Enhancement Pipeline - Quick Reference

## Pipeline Parameters

### Conservative Variant

| Processing Step | Tool | Parameters | Purpose |
|----------------|------|------------|---------|
| Clean Original | ImageMagick | PNG compression level 9 | Remove artifacts, preserve quality |
| Debanding | ImageMagick | Ordered dither o8x8,8 | Smooth gradients |
| Blur | ImageMagick | 0x0.3 | Reduce noise |
| Sharpen (pre) | ImageMagick | 0x0.5 | Maintain edges |
| Upscale | Real-ESRGAN | 2x, model: x4plus | High-quality interpolation |
| Sharpen (post) | ImageMagick | 0.5x0.5+0.5+0.008 | Refine details |
| JPEG Quality | ImageMagick | 95 | Minimize compression loss |

### Max-Detail Variant

| Processing Step | Tool | Parameters | Purpose |
|----------------|------|------------|---------|
| Clean Original | ImageMagick | PNG compression level 9 | Remove artifacts, preserve quality |
| Debanding | FFmpeg | hqdn3d=1.5:1.5:6:6 | Aggressive gradient smoothing |
| Sharpen (deband) | FFmpeg | unsharp=5:5:0.8:5:5:0.0 | Edge enhancement |
| Upscale | Real-ESRGAN | 2x, model: x4plus-anime | Maximum detail preservation |
| Text Enhance | ImageMagick | unsharp 0x1.0+0.8+0.01 | Crisp text edges |
| JPEG Quality | ImageMagick | 95 | Minimize compression loss |

## ImageMagick Unsharp Mask Parameters

Format: `-unsharp {radius}x{sigma}+{amount}+{threshold}`

- **Radius**: Size of sharpening effect (pixels)
- **Sigma**: Standard deviation of Gaussian
- **Amount**: Strength of sharpening (0.0-5.0)
- **Threshold**: Minimum brightness change to sharpen

### Conservative
`0.5x0.5+0.5+0.008` - Gentle, natural sharpening

### Max-Detail
`1.0x1.0+1.0+0.05` - Aggressive, detail-enhancing

## FFmpeg hqdn3d Filter

Format: `hqdn3d={luma_spatial}:{chroma_spatial}:{luma_temporal}:{chroma_temporal}`

Max-Detail: `1.5:1.5:6:6`
- Luma spatial: 1.5 (denoise brightness)
- Chroma spatial: 1.5 (denoise color)
- Luma temporal: 6 (smooth across frames - not used for stills)
- Chroma temporal: 6 (smooth across frames - not used for stills)

## Real-ESRGAN Models

| Model | Best For | Quality | Speed |
|-------|----------|---------|-------|
| realesrgan-x4plus | Photos, general | High | Fast |
| realesrgan-x4plus-anime | Illustrations, graphics | Higher | Medium |
| realesrnet-x4plus | Realistic photos | Medium | Fastest |

Conservative uses: `x4plus`  
Max-Detail uses: `x4plus-anime` (fallback to `x4plus`)

## Tool Installation

### ImageMagick
```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick

# Verify
convert -version
```

### FFmpeg
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg

# Verify
ffmpeg -version
```

### ExifTool
```bash
# macOS
brew install exiftool

# Ubuntu/Debian
sudo apt-get install libimage-exiftool-perl

# Verify
exiftool -ver
```

### Real-ESRGAN
```bash
# Download from GitHub releases
# macOS: realesrgan-ncnn-vulkan-20220424-macos.zip
# Ubuntu: realesrgan-ncnn-vulkan-20220424-ubuntu.zip
# Windows: realesrgan-ncnn-vulkan-20220424-windows.zip

# Extract and place binary in tools/ directory
mkdir -p tools
# ... extract realesrgan-ncnn-vulkan to tools/
chmod +x tools/realesrgan-ncnn-vulkan
```

## File Naming Convention

### Conservative Variant
- `conservative_original_clean.png` - Source resolution, cleaned
- `conservative_x2.png` - 2x upscale, PNG format
- `conservative_x2_q95.jpg` - 2x upscale, JPEG 95% quality

### Max-Detail Variant
- `maxdetail_original_clean.png` - Source resolution, cleaned
- `maxdetail_x2.png` - 2x upscale, PNG format
- `maxdetail_x2_q95.jpg` - 2x upscale, JPEG 95% quality

## Metadata Preservation

ExifTool copies these tags from source to outputs:
- All EXIF tags (camera, date, settings)
- ICC color profile
- XMP metadata
- IPTC information
- Copyright and author

Command: `exiftool -TagsFromFile source.jpg -all:all output.png`

## Directory Structure

```
assets/olobe-bukka/
├── input/
│   └── original.jpg              # Source image
├── output/
│   ├── conservative/              # Conservative outputs
│   │   ├── conservative_original_clean.png
│   │   ├── conservative_x2.png
│   │   └── conservative_x2_q95.jpg
│   └── maxdetail/                 # Max-detail outputs
│       ├── maxdetail_original_clean.png
│       ├── maxdetail_x2.png
│       └── maxdetail_x2_q95.jpg
└── temp/                          # Temporary (auto-deleted)
    └── (intermediate files)
```

## Customization Examples

### Increase sharpening (Conservative)
```bash
# In scripts/enhance.sh, change:
-unsharp 0.5x0.5+0.5+0.008
# To:
-unsharp 0.5x0.5+0.8+0.008
```

### Reduce noise (Max-Detail)
```bash
# In scripts/enhance.sh, change:
hqdn3d=1.5:1.5:6:6
# To:
hqdn3d=2.0:2.0:6:6
```

### Change upscale ratio
```bash
# In scripts/enhance.sh, change:
-s 2          # Real-ESRGAN
-resize 200%  # ImageMagick
# To:
-s 3          # 3x upscale
-resize 300%
```

### Adjust JPEG quality
```bash
# In scripts/enhance.sh, change:
-quality 95
# To:
-quality 98   # Higher quality, larger file
```

## Workflow Inputs

GitHub Actions workflow accepts:
- `input_image_path`: Path to source image (default: `assets/olobe-bukka/input/original.jpg`)

To use different path:
1. Actions → Flyer Enhancement Pipeline
2. Run workflow
3. Enter custom path: `assets/olobe-bukka/input/my-flyer.png`

## Performance Tips

1. **Use Real-ESRGAN** for best quality (vs ImageMagick fallback)
2. **PNG outputs** are lossless but larger (~2-4x original upscaled size)
3. **JPEG q95** provides good balance of quality/size
4. **Local processing** is faster than GitHub Actions
5. **SSD storage** significantly improves processing speed

## Quality Assessment Checklist

After enhancement, verify:
- [ ] Text is crisp and readable
- [ ] No halos around edges
- [ ] Colors match original (gold, purple)
- [ ] Gradients are smooth (no banding)
- [ ] No excessive noise
- [ ] Food imagery is clear
- [ ] No content was altered
- [ ] Metadata is preserved
- [ ] File sizes are reasonable
- [ ] Both formats (PNG, JPEG) look good

## Common Adjustments

### Text too blurry
→ Increase sharpening amount in unsharp mask

### Text too sharp/halo
→ Decrease sharpening amount or increase threshold

### Colors too saturated
→ Reduce FFmpeg unsharp chroma values

### Gradients still banding
→ Increase hqdn3d spatial values

### File too large
→ Use JPEG q85-90 instead of q95

### Processing too slow
→ Skip FFmpeg debanding, use ImageMagick only
