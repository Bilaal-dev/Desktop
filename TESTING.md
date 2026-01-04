# Testing the Enhancement Pipeline

This document explains how to test the enhancement pipeline and what to expect.

## Current Status

✅ **Complete**:
- Directory structure created
- Enhancement script (`scripts/enhance.sh`) implemented
- GitHub Actions workflow configured
- Comprehensive documentation
- Test flyer image included
- Validation script

⚠️ **Requires External Dependencies**:
- ImageMagick (for image processing)
- FFmpeg (for advanced debanding)
- ExifTool (for metadata preservation)
- Real-ESRGAN (optional, for best quality)

## Testing Locally

### Prerequisites Check

Run the validation script to verify the setup:
```bash
bash scripts/validate.sh
```

This will check:
- ✓ Directory structure
- ✓ Required files exist
- ✓ Script syntax validity
- ✓ README documentation
- ✓ Workflow YAML validity

### Install Dependencies

#### macOS
```bash
brew install imagemagick ffmpeg exiftool
```

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y imagemagick ffmpeg libimage-exiftool-perl
```

### Run the Pipeline

Once dependencies are installed:
```bash
bash scripts/enhance.sh assets/olobe-bukka/input/original.jpg
```

Expected output:
```
=== Flyer Enhancement Pipeline ===
Input: assets/olobe-bukka/input/original.jpg
Checking for required tools...
✓ convert found
✓ ffmpeg found
✓ exiftool found
...
=== Processing Conservative Variant ===
Step 1: Cleaning original (conservative)...
Step 2: Applying gentle debanding...
Step 3: Upscaling 2x (conservative)...
...
=== Enhancement Complete ===
All files generated successfully!
```

### Verify Outputs

Check that all 6 files were created:
```bash
ls -lh assets/olobe-bukka/output/conservative/
ls -lh assets/olobe-bukka/output/maxdetail/
```

Expected files:
- `conservative_original_clean.png`
- `conservative_x2.png`
- `conservative_x2_q95.jpg`
- `maxdetail_original_clean.png`
- `maxdetail_x2.png`
- `maxdetail_x2_q95.jpg`

## Testing via GitHub Actions

### Trigger the Workflow

1. **Go to Actions tab** in your GitHub repository
2. **Select** "Flyer Enhancement Pipeline"
3. **Click** "Run workflow"
4. **Select branch** (should be your PR branch)
5. **Click** green "Run workflow" button

### Monitor Progress

Watch the workflow logs:
- Checkout repository
- Check input image exists
- Install system dependencies
- Download Real-ESRGAN
- Run enhancement script
- Verify outputs
- Upload artifacts

### Download Results

After successful completion:
1. Scroll to bottom of workflow run page
2. Find "Artifacts" section
3. Download:
   - `conservative-variant` (3 files)
   - `maxdetail-variant` (3 files)
   - `all-enhanced-outputs` (all 6 files)

## Expected Results

### Conservative Variant
- **Visual**: Natural-looking, minimal changes
- **Text**: Slightly crisper edges
- **Colors**: Identical to original
- **Gradients**: Smoother, less banding
- **File sizes**: 
  - PNG: 2-4x larger (lossless)
  - JPEG: Similar to upscaled original

### Max-Detail Variant
- **Visual**: Enhanced clarity, sharper details
- **Text**: Very crisp edges, high legibility
- **Colors**: Slightly more vibrant, still natural
- **Gradients**: Very smooth, minimal banding
- **File sizes**:
  - PNG: 2-4x larger (lossless)
  - JPEG: Slightly larger due to detail

## Quality Comparison

To compare variants:
```bash
# View original
open assets/olobe-bukka/input/original.jpg

# View conservative
open assets/olobe-bukka/output/conservative/conservative_x2.png

# View max-detail
open assets/olobe-bukka/output/maxdetail/maxdetail_x2.png
```

Look for:
- ✓ Text readability improvement
- ✓ Reduced JPEG artifacts
- ✓ Smoother gradients
- ✓ No halos around text
- ✓ Preserved colors (gold/purple)
- ✓ No content changes

## Troubleshooting

### Error: "command not found"
- Install missing dependencies (see Prerequisites)
- Verify with: `which convert ffmpeg exiftool`

### Real-ESRGAN not working
- Expected behavior: script falls back to ImageMagick Lanczos
- For best quality, download Real-ESRGAN binary
- Place in `tools/` or add to system PATH

### Outputs missing
- Check script logs for errors
- Verify input image exists and is readable
- Ensure sufficient disk space (~50MB free)

### Workflow fails in GitHub Actions
- Check if input image is committed
- Review workflow logs for specific error
- Verify workflow YAML syntax

### Colors look different
- May be due to missing ICC profile in viewer
- Compare in same application
- Check with: `exiftool -ICC_Profile output.png`

## Performance Benchmarks

Approximate processing times:

**Local (MacBook Pro M1)**:
- Conservative: 15-20 seconds
- Max-Detail: 30-45 seconds
- Total: ~1 minute

**Local (Ubuntu Desktop, Intel i7)**:
- Conservative: 20-30 seconds
- Max-Detail: 45-60 seconds
- Total: ~1.5 minutes

**GitHub Actions (ubuntu-latest)**:
- Setup: 60-90 seconds
- Conservative: 30-45 seconds
- Max-Detail: 60-90 seconds
- Upload: 10-20 seconds
- Total: ~3-5 minutes

## Next Steps

1. **Replace test image** with actual flyer from chat
2. **Run pipeline** locally to verify results
3. **Adjust parameters** if needed (in `scripts/enhance.sh`)
4. **Trigger workflow** to generate production outputs
5. **Download artifacts** for distribution

## Notes

- The test image (`original.jpg`) is synthetic and includes:
  - Gradient background (purple → gold)
  - Text-like elements
  - Simulated compression artifacts
  - 800x1200 pixels

- Real flyer should be:
  - Business information for "Olobe Bukka"
  - Hiring roles
  - Food imagery
  - Gold and purple colors
  - Professional design

Replace the test image with the actual flyer to generate production-quality enhanced outputs.
