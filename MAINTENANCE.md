# Enhancement Pipeline Maintenance Guide

This guide is for maintaining and customizing the Olobe Bukka flyer enhancement pipeline.

## Pipeline Architecture

### Components

1. **Input Handler** (`scripts/enhance.sh` lines 1-100)
   - Dependency checking
   - Input image detection
   - Directory setup

2. **Conservative Processor** (`scripts/enhance.sh` lines 150-220)
   - Gentle cleanup
   - Light sharpening
   - Mild debanding

3. **Max-Detail Processor** (`scripts/enhance.sh` lines 222-310)
   - Aggressive cleanup
   - Strong sharpening
   - Micro-contrast enhancement

4. **Output Handler** (`scripts/enhance.sh` lines 312-350)
   - File management
   - Metadata preservation
   - Format conversion

## Customizing Enhancement Settings

### Adjusting Sharpening Intensity

Edit the unsharp parameters in `scripts/enhance.sh`:

**Conservative** (currently line ~175):
```bash
# Current: -unsharp 0x0.8+0.7+0.02
# Less sharp: -unsharp 0x0.5+0.5+0.02
# More sharp: -unsharp 0x1.0+0.9+0.02
```

**Max-Detail** (currently line ~255):
```bash
# Current: -unsharp 0x1.0+1.0+0.02
# Less sharp: -unsharp 0x0.8+0.8+0.02
# More sharp: -unsharp 0x1.2+1.2+0.02
```

### Adjusting Noise Reduction

**Conservative** - Change despeckle iterations (currently line ~160):
```bash
# Current: -despeckle (1 iteration)
# More aggressive: -despeckle -despeckle (2 iterations)
# Very aggressive: -despeckle -despeckle -despeckle (3 iterations)
```

**Max-Detail** - Adjust waifu2x noise level (currently line ~240):
```bash
# Current: -n 2 (moderate noise reduction)
# Less: -n 1 (light noise reduction)
# More: -n 3 (heavy noise reduction)
```

### Adjusting Contrast Enhancement

**Max-Detail** - Modify sigmoidal-contrast (currently line ~265):
```bash
# Current: -sigmoidal-contrast 3x50%
# Lighter: -sigmoidal-contrast 2x50%
# Stronger: -sigmoidal-contrast 4x50%
# Darker midpoint: -sigmoidal-contrast 3x45%
# Lighter midpoint: -sigmoidal-contrast 3x55%
```

### Adjusting JPEG Quality

Change quality in both variants (currently lines ~195, ~285):
```bash
# Current: -quality 95
# Higher (larger file): -quality 98
# Lower (smaller file): -quality 90
```

### Changing Upscale Factor

Modify Real-ESRGAN scale parameter (currently lines ~170, ~250):
```bash
# Current: -s 2 (2x upscale)
# 3x upscale: -s 3
# 4x upscale: -s 4
```

**Note**: Adjust output filenames accordingly (e.g., `*_x3.png`, `*_x4.png`).

### Using Different Real-ESRGAN Models

Change the model name (currently lines ~172, ~252):
```bash
# Current: -n realesrgan-x4plus (general purpose)
# Anime/illustration: -n realesrgan-x4plus-anime
# Face enhancement: -n RealESRGAN_x4plus_anime_6B
```

## Adding New Variants

To add a third variant (e.g., "Ultra-Sharp"):

1. Create output directory:
```bash
mkdir -p assets/olobe-bukka/output/ultrasharp
touch assets/olobe-bukka/output/ultrasharp/.gitkeep
```

2. Add processing function to `scripts/enhance.sh`:
```bash
process_ultrasharp() {
    print_info "Processing ULTRA-SHARP variant..."
    mkdir -p "$OUTPUT_ULTRASHARP"
    
    # Add your processing steps here
    # Follow the pattern from process_maxdetail()
}
```

3. Call from main function:
```bash
main() {
    # ... existing code ...
    process_conservative
    process_maxdetail
    process_ultrasharp  # Add this line
    # ... existing code ...
}
```

4. Update documentation to reflect new variant

## Testing Changes

### Test with Sample Image

Before processing important images:

1. Use a test image first:
```bash
cp /path/to/test-image.jpg assets/olobe-bukka/input/original.jpg
bash scripts/enhance.sh
```

2. Verify outputs look correct
3. Adjust settings as needed
4. Test again with actual flyer

### Debugging Processing Steps

Add debug output to see intermediate results:

1. Comment out the temp cleanup line (around line 350):
```bash
# cleanup_temp_dir  # Commented out for debugging
```

2. Run the script
3. Examine intermediate files in `assets/olobe-bukka/temp/`
4. Restore cleanup when done

### Performance Profiling

Add timing to each step:

```bash
# Before a step
STEP_START=$(date +%s)

# After a step
STEP_END=$(date +%s)
STEP_TIME=$((STEP_END - STEP_START))
print_info "Step completed in ${STEP_TIME} seconds"
```

## Common Modifications

### Skip Real-ESRGAN (Use ImageMagick Instead)

Replace Real-ESRGAN call with ImageMagick resize:

```bash
# Original (lines ~170, ~250):
realesrgan-ncnn-vulkan -i input.png -o output.png -s 2 -n realesrgan-x4plus -f png

# Replacement:
magick input.png -filter Lanczos -resize 200% output.png
```

**Note**: ImageMagick upscaling won't preserve details as well as Real-ESRGAN.

### Add Watermark to Outputs

Add after final PNG is created:

```bash
magick output.png \
    -gravity SouthEast \
    -pointsize 20 \
    -fill white \
    -stroke black \
    -strokewidth 2 \
    -annotate +10+10 "Enhanced by Pipeline" \
    output_watermarked.png
```

### Batch Process Multiple Images

Modify script to accept input filename:

```bash
# Add to script beginning:
INPUT_FILE="${1:-original.jpg}"

# Modify find_input_image():
if [ -f "$INPUT_DIR/$INPUT_FILE" ]; then
    INPUT_IMAGE="$INPUT_DIR/$INPUT_FILE"
else
    print_error "Image not found: $INPUT_FILE"
    exit 1
fi

# Usage:
bash scripts/enhance.sh image1.jpg
bash scripts/enhance.sh image2.jpg
```

### Save Processing Log

Add at script beginning:

```bash
LOG_FILE="$REPO_ROOT/enhancement_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1
```

All output will be saved to timestamped log file.

## Troubleshooting Development

### Script Syntax Errors

Check script syntax:
```bash
bash -n scripts/enhance.sh
```

### Permission Issues

Ensure script is executable:
```bash
chmod +x scripts/enhance.sh
```

### Path Issues

Use absolute paths during development:
```bash
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

### ImageMagick Errors

Test commands individually:
```bash
magick identify original.jpg  # Check if image is valid
magick convert original.jpg -depth 16 test.png  # Test basic operation
```

## Version Control Best Practices

### What to Commit

✅ **Do commit**:
- Script updates (`scripts/enhance.sh`)
- Documentation updates
- Directory structure (`.gitkeep` files)
- Configuration files

❌ **Don't commit**:
- Large output images (unless needed)
- Temporary files
- Source image (unless public)
- Log files

### Making Changes

1. Create feature branch:
```bash
git checkout -b enhance-pipeline-improvements
```

2. Make and test changes

3. Commit with clear messages:
```bash
git add scripts/enhance.sh
git commit -m "Adjust sharpening for better text clarity"
```

4. Push and create PR

## Performance Optimization

### GPU Acceleration

Ensure Vulkan is enabled for Real-ESRGAN:
- Update graphics drivers
- Verify: `vulkaninfo` (install vulkan-tools)

### Parallel Processing

Process both variants simultaneously:
```bash
process_conservative &
PID1=$!
process_maxdetail &
PID2=$!
wait $PID1 $PID2
```

**Warning**: Uses more memory.

### Reduce Processing Depth

For faster processing, use 8-bit instead of 16-bit:
```bash
# Current: -depth 16
# Faster: -depth 8
```

**Warning**: May introduce banding in gradients.

## Extending the Pipeline

### Add Pre-Processing Hook

Before enhancement:
```bash
pre_process() {
    print_info "Running pre-processing..."
    # Auto-rotate, crop, etc.
}

main() {
    check_dependencies
    find_input_image
    pre_process  # Add this
    setup_temp_dir
    # ...
}
```

### Add Post-Processing Hook

After enhancement:
```bash
post_process() {
    print_info "Running post-processing..."
    # Generate thumbnails, compress, etc.
}

main() {
    # ... existing processing ...
    post_process  # Add this
    print_summary
}
```

### Export to Additional Formats

Add WebP export:
```bash
# After JPEG export
magick final.png -quality 90 output.webp
print_info "✓ Saved: output.webp"
```

## Documentation Updates

When modifying the pipeline:

1. Update `README.md` if user-facing changes
2. Update `PIPELINE_REFERENCE.md` if technical changes
3. Update `QUICKSTART.md` if usage changes
4. Update this file if maintenance procedures change
5. Update `VERIFICATION_CHECKLIST.md` if new outputs

## Getting Help

### ImageMagick Documentation
- Official docs: https://imagemagick.org/
- Command-line reference: https://imagemagick.org/script/command-line-options.php

### Real-ESRGAN Documentation
- GitHub: https://github.com/xinntao/Real-ESRGAN
- Issues: https://github.com/xinntao/Real-ESRGAN/issues

### waifu2x Documentation
- GitHub: https://github.com/nihui/waifu2x-ncnn-vulkan
- Issues: https://github.com/nihui/waifu2x-ncnn-vulkan/issues

### Shell Scripting
- Bash Guide: https://mywiki.wooledge.org/BashGuide
- ShellCheck: https://www.shellcheck.net/ (for linting)

---

**Remember**: Always test changes with sample images before processing important flyers!
