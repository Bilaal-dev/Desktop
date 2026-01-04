#!/bin/bash
set -e

# Flyer Enhancement Script
# This script processes a source image through two variants:
# 1. Conservative: Clean artifacts, gentle debanding, 2x upscale
# 2. Max-Detail: Aggressive noise reduction, enhanced sharpening, 2x upscale

# Usage: ./scripts/enhance.sh <input_image_path>
# Example: ./scripts/enhance.sh assets/olobe-bukka/input/original.jpg

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No input file specified${NC}"
    echo "Usage: $0 <input_image_path>"
    echo "Example: $0 assets/olobe-bukka/input/original.jpg"
    exit 1
fi

INPUT_IMAGE="$1"

# Check if input file exists
if [ ! -f "$INPUT_IMAGE" ]; then
    echo -e "${RED}Error: Input file not found: $INPUT_IMAGE${NC}"
    exit 1
fi

echo -e "${GREEN}=== Flyer Enhancement Pipeline ===${NC}"
echo "Input: $INPUT_IMAGE"

# Detect script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Output directories
CONSERVATIVE_DIR="$REPO_ROOT/assets/olobe-bukka/output/conservative"
MAXDETAIL_DIR="$REPO_ROOT/assets/olobe-bukka/output/maxdetail"
TEMP_DIR="$REPO_ROOT/assets/olobe-bukka/temp"

# Create directories if they don't exist
mkdir -p "$CONSERVATIVE_DIR" "$MAXDETAIL_DIR" "$TEMP_DIR"

# Check for required tools
echo -e "${YELLOW}Checking for required tools...${NC}"

check_tool() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 found"
        return 0
    else
        echo -e "${RED}✗${NC} $1 not found"
        return 1
    fi
}

MISSING_TOOLS=0
check_tool "convert" || MISSING_TOOLS=$((MISSING_TOOLS + 1))
check_tool "magick" || echo "  (ImageMagick 7 'magick' command not found, falling back to 'convert')"
check_tool "ffmpeg" || MISSING_TOOLS=$((MISSING_TOOLS + 1))
check_tool "exiftool" || echo "  (exiftool not found, metadata preservation will be limited)"

# Check for Real-ESRGAN
REALESRGAN_BIN=""
if [ -f "$REPO_ROOT/tools/realesrgan-ncnn-vulkan" ]; then
    REALESRGAN_BIN="$REPO_ROOT/tools/realesrgan-ncnn-vulkan"
    echo -e "${GREEN}✓${NC} Real-ESRGAN found (local)"
elif command -v realesrgan-ncnn-vulkan &> /dev/null; then
    REALESRGAN_BIN="realesrgan-ncnn-vulkan"
    echo -e "${GREEN}✓${NC} Real-ESRGAN found (system)"
else
    echo -e "${YELLOW}⚠${NC} Real-ESRGAN not found, will use ImageMagick for upscaling (lower quality)"
fi

if [ $MISSING_TOOLS -gt 0 ]; then
    echo -e "${RED}Error: Missing required tools. Please install ImageMagick and FFmpeg.${NC}"
    exit 1
fi

# Use 'magick convert' for ImageMagick 7, or 'convert' for ImageMagick 6
if command -v magick &> /dev/null; then
    CONVERT_CMD="magick convert"
else
    CONVERT_CMD="convert"
fi

echo ""
echo -e "${GREEN}=== Processing Conservative Variant ===${NC}"

# Conservative variant: Gentle cleanup and enhancement
# Step 1: Clean original - remove compression artifacts, gentle debanding
echo "Step 1: Cleaning original (conservative)..."
$CONVERT_CMD "$INPUT_IMAGE" \
    -define png:compression-level=9 \
    -define png:preserve-colormap=true \
    "$CONSERVATIVE_DIR/conservative_original_clean.png"

# Step 2: Gentle debanding and artifact removal
echo "Step 2: Applying gentle debanding..."
$CONVERT_CMD "$CONSERVATIVE_DIR/conservative_original_clean.png" \
    -ordered-dither o8x8,8 \
    -blur 0x0.3 \
    -sharpen 0x0.5 \
    "$TEMP_DIR/conservative_debanded.png"

# Step 3: 2x upscale
echo "Step 3: Upscaling 2x (conservative)..."
if [ -n "$REALESRGAN_BIN" ]; then
    # Use Real-ESRGAN for high-quality upscaling
    $REALESRGAN_BIN \
        -i "$TEMP_DIR/conservative_debanded.png" \
        -o "$TEMP_DIR/conservative_upscaled.png" \
        -s 2 \
        -n realesrgan-x4plus 2>/dev/null || {
        echo -e "${YELLOW}Real-ESRGAN failed, falling back to ImageMagick${NC}"
        $CONVERT_CMD "$TEMP_DIR/conservative_debanded.png" \
            -filter Lanczos \
            -resize 200% \
            -unsharp 0.5x0.5+0.5+0.008 \
            "$TEMP_DIR/conservative_upscaled.png"
    }
else
    # Fallback to ImageMagick Lanczos
    $CONVERT_CMD "$TEMP_DIR/conservative_debanded.png" \
        -filter Lanczos \
        -resize 200% \
        -unsharp 0.5x0.5+0.5+0.008 \
        "$TEMP_DIR/conservative_upscaled.png"
fi

# Step 4: Save PNG output
echo "Step 4: Saving PNG output..."
cp "$TEMP_DIR/conservative_upscaled.png" "$CONSERVATIVE_DIR/conservative_x2.png"

# Step 5: Save high-quality JPEG
echo "Step 5: Saving JPEG output (q95)..."
$CONVERT_CMD "$TEMP_DIR/conservative_upscaled.png" \
    -quality 95 \
    "$CONSERVATIVE_DIR/conservative_x2_q95.jpg"

# Preserve metadata if exiftool is available
if command -v exiftool &> /dev/null; then
    echo "Step 6: Preserving metadata..."
    exiftool -TagsFromFile "$INPUT_IMAGE" -all:all \
        "$CONSERVATIVE_DIR/conservative_original_clean.png" \
        "$CONSERVATIVE_DIR/conservative_x2.png" \
        "$CONSERVATIVE_DIR/conservative_x2_q95.jpg" \
        -overwrite_original -q 2>/dev/null || true
fi

echo -e "${GREEN}Conservative variant complete!${NC}"
echo ""

echo -e "${GREEN}=== Processing Max-Detail Variant ===${NC}"

# Max-Detail variant: Aggressive enhancement
# Step 1: Clean original with stronger artifact removal
echo "Step 1: Cleaning original (max-detail)..."
$CONVERT_CMD "$INPUT_IMAGE" \
    -define png:compression-level=9 \
    -define png:preserve-colormap=true \
    "$MAXDETAIL_DIR/maxdetail_original_clean.png"

# Step 2: Stronger debanding and noise reduction using FFmpeg
echo "Step 2: Applying aggressive debanding..."
if command -v ffmpeg &> /dev/null; then
    # Use FFmpeg for superior debanding
    ffmpeg -i "$MAXDETAIL_DIR/maxdetail_original_clean.png" \
        -vf "hqdn3d=1.5:1.5:6:6,unsharp=5:5:0.8:5:5:0.0" \
        -pix_fmt rgb24 \
        "$TEMP_DIR/maxdetail_debanded.png" \
        -y -loglevel error
else
    # Fallback to ImageMagick
    $CONVERT_CMD "$MAXDETAIL_DIR/maxdetail_original_clean.png" \
        -ordered-dither o8x8,8 \
        -blur 0x0.5 \
        -sharpen 0x1.0 \
        "$TEMP_DIR/maxdetail_debanded.png"
fi

# Step 3: 2x upscale with max quality
echo "Step 3: Upscaling 2x (max-detail)..."
if [ -n "$REALESRGAN_BIN" ]; then
    # Use Real-ESRGAN with anime model for maximum detail
    $REALESRGAN_BIN \
        -i "$TEMP_DIR/maxdetail_debanded.png" \
        -o "$TEMP_DIR/maxdetail_upscaled.png" \
        -s 2 \
        -n realesrgan-x4plus-anime 2>/dev/null || {
        # Fallback to standard model
        $REALESRGAN_BIN \
            -i "$TEMP_DIR/maxdetail_debanded.png" \
            -o "$TEMP_DIR/maxdetail_upscaled.png" \
            -s 2 \
            -n realesrgan-x4plus 2>/dev/null || {
            echo -e "${YELLOW}Real-ESRGAN failed, falling back to ImageMagick${NC}"
            $CONVERT_CMD "$TEMP_DIR/maxdetail_debanded.png" \
                -filter Lanczos \
                -resize 200% \
                -unsharp 1.0x1.0+1.0+0.05 \
                "$TEMP_DIR/maxdetail_upscaled.png"
        }
    }
else
    # Enhanced ImageMagick upscaling
    $CONVERT_CMD "$TEMP_DIR/maxdetail_debanded.png" \
        -filter Lanczos \
        -resize 200% \
        -unsharp 1.0x1.0+1.0+0.05 \
        "$TEMP_DIR/maxdetail_upscaled.png"
fi

# Step 4: Additional sharpening for text clarity
echo "Step 4: Enhancing text clarity..."
$CONVERT_CMD "$TEMP_DIR/maxdetail_upscaled.png" \
    -unsharp 0x1.0+0.8+0.01 \
    "$TEMP_DIR/maxdetail_final.png"

# Step 5: Save PNG output
echo "Step 5: Saving PNG output..."
cp "$TEMP_DIR/maxdetail_final.png" "$MAXDETAIL_DIR/maxdetail_x2.png"

# Step 6: Save high-quality JPEG
echo "Step 6: Saving JPEG output (q95)..."
$CONVERT_CMD "$TEMP_DIR/maxdetail_final.png" \
    -quality 95 \
    "$MAXDETAIL_DIR/maxdetail_x2_q95.jpg"

# Preserve metadata if exiftool is available
if command -v exiftool &> /dev/null; then
    echo "Step 7: Preserving metadata..."
    exiftool -TagsFromFile "$INPUT_IMAGE" -all:all \
        "$MAXDETAIL_DIR/maxdetail_original_clean.png" \
        "$MAXDETAIL_DIR/maxdetail_x2.png" \
        "$MAXDETAIL_DIR/maxdetail_x2_q95.jpg" \
        -overwrite_original -q 2>/dev/null || true
fi

echo -e "${GREEN}Max-Detail variant complete!${NC}"
echo ""

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo -e "${GREEN}=== Enhancement Complete ===${NC}"
echo ""
echo "Output files:"
echo "Conservative variant:"
echo "  - $CONSERVATIVE_DIR/conservative_original_clean.png"
echo "  - $CONSERVATIVE_DIR/conservative_x2.png"
echo "  - $CONSERVATIVE_DIR/conservative_x2_q95.jpg"
echo ""
echo "Max-Detail variant:"
echo "  - $MAXDETAIL_DIR/maxdetail_original_clean.png"
echo "  - $MAXDETAIL_DIR/maxdetail_x2.png"
echo "  - $MAXDETAIL_DIR/maxdetail_x2_q95.jpg"
echo ""
echo -e "${GREEN}All files generated successfully!${NC}"
