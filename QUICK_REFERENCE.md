# Quick Reference Card

## Olobe Bukka Flyer Enhancement Pipeline

### One-Line Usage
```bash
bash scripts/enhance.sh
```

### Prerequisites
1. Place source image: `assets/olobe-bukka/input/original.jpg`
2. Install ImageMagick 7+ and Real-ESRGAN

### Installation (Quick)

**macOS:**
```bash
brew install imagemagick
# Download Real-ESRGAN from: https://github.com/xinntao/Real-ESRGAN/releases
```

**Linux:**
```bash
sudo apt-get install imagemagick
# Download Real-ESRGAN from: https://github.com/xinntao/Real-ESRGAN/releases
```

### Expected Outputs (6 files)

**Conservative** (gentle):
- `conservative_original_clean.png`
- `conservative_x2.png`
- `conservative_x2_q95.jpg`

**Max-Detail** (aggressive):
- `maxdetail_original_clean.png`
- `maxdetail_x2.png`
- `maxdetail_x2_q95.jpg`

### Processing Time
- Conservative: ~40-50 seconds
- Max-Detail: ~50-90 seconds

### When to Use Each Variant

**Conservative** when you want:
- Natural appearance
- Gentle artifact cleanup
- Subtle enhancement

**Max-Detail** when you want:
- Maximum clarity
- Sharp text
- Vivid details

### File Formats

**PNG** (`*_x2.png`):
- Lossless
- Larger files (~10-20 MB)
- Best for archival

**JPEG** (`*_x2_q95.jpg`):
- Near-lossless quality
- Smaller files (~2-6 MB)
- Best for distribution

### Documentation Map

| Need | Read |
|------|------|
| Quick start | `QUICKSTART.md` |
| Installation details | `README.md` |
| Technical commands | `PIPELINE_REFERENCE.md` |
| Verify outputs | `VERIFICATION_CHECKLIST.md` |
| Customize pipeline | `MAINTENANCE.md` |
| Implementation info | `IMPLEMENTATION_SUMMARY.md` |

### Common Issues

**"No input image found"**
→ Place image as `assets/olobe-bukka/input/original.jpg`

**"realesrgan-ncnn-vulkan not found"**
→ Download from https://github.com/xinntao/Real-ESRGAN/releases

**"ImageMagick (magick) not found"**
→ Install ImageMagick 7+ (not version 6)

### Quick Checks

**Verify dependencies:**
```bash
magick -version
realesrgan-ncnn-vulkan
```

**Check script syntax:**
```bash
bash -n scripts/enhance.sh
```

**View recent outputs:**
```bash
ls -lh assets/olobe-bukka/output/conservative/
ls -lh assets/olobe-bukka/output/maxdetail/
```

---

**Ready?** Place your image and run: `bash scripts/enhance.sh`
