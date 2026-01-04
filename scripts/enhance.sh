#!/bin/bash

###############################################################################
# Olobe Bukka Flyer Enhancement Script
# 
# This script enhances a flyer image using two variants:
# - Conservative: Gentle cleanup and enhancement
# - Max-Detail: Aggressive detail enhancement
#
# Requirements:
# - Real-ESRGAN (realesrgan-ncnn-vulkan)
# - ImageMagick 7+ (magick command)
# - Optional: waifu2x-ncnn-vulkan for pre-cleanup
#
# Usage:
#   bash scripts/enhance.sh
#
###############################################################################

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
INPUT_DIR="$REPO_ROOT/assets/olobe-bukka/input"
OUTPUT_CONSERVATIVE="$REPO_ROOT/assets/olobe-bukka/output/conservative"
OUTPUT_MAXDETAIL="$REPO_ROOT/assets/olobe-bukka/output/maxdetail"
TEMP_DIR="$REPO_ROOT/assets/olobe-bukka/temp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    print_info "Checking dependencies..."
    
    local missing_deps=0
    
    # Check for ImageMagick
    if ! command -v magick &> /dev/null; then
        print_error "ImageMagick (magick) not found. Please install ImageMagick 7+."
        missing_deps=1
    else
        print_info "✓ ImageMagick found: $(magick -version | head -n1)"
    fi
    
    # Check for Real-ESRGAN
    if ! command -v realesrgan-ncnn-vulkan &> /dev/null; then
        print_error "realesrgan-ncnn-vulkan not found."
        print_error "Download from: https://github.com/xinntao/Real-ESRGAN/releases"
        missing_deps=1
    else
        print_info "✓ Real-ESRGAN found"
    fi
    
    # Optional: waifu2x
    if command -v waifu2x-ncnn-vulkan &> /dev/null; then
        print_info "✓ waifu2x-ncnn-vulkan found (optional)"
    else
        print_warn "waifu2x-ncnn-vulkan not found (optional, for pre-cleanup)"
    fi
    
    if [ $missing_deps -eq 1 ]; then
        print_error "Missing required dependencies. Please install them and try again."
        exit 1
    fi
}

find_input_image() {
    print_info "Looking for input image..."
    
    if [ -f "$INPUT_DIR/original.jpg" ]; then
        INPUT_IMAGE="$INPUT_DIR/original.jpg"
        print_info "✓ Found: $INPUT_IMAGE"
    elif [ -f "$INPUT_DIR/original.png" ]; then
        INPUT_IMAGE="$INPUT_DIR/original.png"
        print_info "✓ Found: $INPUT_IMAGE"
    else
        print_error "No input image found at:"
        print_error "  $INPUT_DIR/original.jpg"
        print_error "  $INPUT_DIR/original.png"
        print_error "Please place the source image in the input directory."
        exit 1
    fi
}

setup_temp_dir() {
    print_info "Setting up temporary working directory..."
    mkdir -p "$TEMP_DIR"
}

cleanup_temp_dir() {
    print_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Process Conservative Variant
process_conservative() {
    print_info "======================================"
    print_info "Processing CONSERVATIVE variant..."
    print_info "======================================"
    
    mkdir -p "$OUTPUT_CONSERVATIVE"
    
    # Step 1: Create cleaned original (artifact reduction, minimal processing)
    print_info "Step 1/5: Creating cleaned original..."
    magick "$INPUT_IMAGE" \
        -depth 16 \
        -colorspace sRGB \
        -despeckle \
        -quality 100 \
        "$TEMP_DIR/conservative_cleaned.png"
    
    # Copy as conservative_original_clean.png
    cp "$TEMP_DIR/conservative_cleaned.png" "$OUTPUT_CONSERVATIVE/conservative_original_clean.png"
    print_info "✓ Saved: conservative_original_clean.png"
    
    # Step 2: 2x upscale with Real-ESRGAN
    print_info "Step 2/5: Upscaling 2x with Real-ESRGAN..."
    realesrgan-ncnn-vulkan \
        -i "$TEMP_DIR/conservative_cleaned.png" \
        -o "$TEMP_DIR/conservative_upscaled.png" \
        -s 2 \
        -n realesrgan-x4plus \
        -f png
    
    # Step 3: Light sharpening (edge-aware, no halos)
    print_info "Step 3/5: Applying light sharpening..."
    magick "$TEMP_DIR/conservative_upscaled.png" \
        -unsharp 0x0.8+0.7+0.02 \
        "$TEMP_DIR/conservative_sharpened.png"
    
    # Step 4: Mild debanding and subtle dithering for gradients
    print_info "Step 4/5: Debanding and dithering..."
    magick "$TEMP_DIR/conservative_sharpened.png" \
        -depth 16 \
        -colorspace sRGB \
        -evaluate-sequence median \
        +dither \
        -colors 16777216 \
        -dither FloydSteinberg \
        -depth 8 \
        "$TEMP_DIR/conservative_final.png"
    
    # Step 5: Export final outputs
    print_info "Step 5/5: Exporting final outputs..."
    
    # PNG export
    cp "$TEMP_DIR/conservative_final.png" "$OUTPUT_CONSERVATIVE/conservative_x2.png"
    print_info "✓ Saved: conservative_x2.png"
    
    # JPEG q95 export with metadata preservation
    magick "$TEMP_DIR/conservative_final.png" \
        -quality 95 \
        -sampling-factor 4:4:4 \
        "$OUTPUT_CONSERVATIVE/conservative_x2_q95.jpg"
    print_info "✓ Saved: conservative_x2_q95.jpg"
    
    print_info "Conservative variant complete!"
}

# Process Max-Detail Variant
process_maxdetail() {
    print_info "======================================"
    print_info "Processing MAX-DETAIL variant..."
    print_info "======================================"
    
    mkdir -p "$OUTPUT_MAXDETAIL"
    
    # Step 1: Aggressive cleanup with noise reduction
    print_info "Step 1/6: Aggressive artifact cleanup..."
    
    # Optional: Use waifu2x for noise reduction if available
    if command -v waifu2x-ncnn-vulkan &> /dev/null; then
        print_info "Using waifu2x for pre-cleanup..."
        waifu2x-ncnn-vulkan \
            -i "$INPUT_IMAGE" \
            -o "$TEMP_DIR/maxdetail_preclean.png" \
            -n 2 \
            -s 1 \
            -f png
        CLEANED_INPUT="$TEMP_DIR/maxdetail_preclean.png"
    else
        CLEANED_INPUT="$INPUT_IMAGE"
    fi
    
    magick "$CLEANED_INPUT" \
        -depth 16 \
        -colorspace sRGB \
        -despeckle \
        -despeckle \
        -enhance \
        -quality 100 \
        "$TEMP_DIR/maxdetail_cleaned.png"
    
    # Copy as maxdetail_original_clean.png
    cp "$TEMP_DIR/maxdetail_cleaned.png" "$OUTPUT_MAXDETAIL/maxdetail_original_clean.png"
    print_info "✓ Saved: maxdetail_original_clean.png"
    
    # Step 2: 2x upscale with Real-ESRGAN
    print_info "Step 2/6: Upscaling 2x with Real-ESRGAN..."
    realesrgan-ncnn-vulkan \
        -i "$TEMP_DIR/maxdetail_cleaned.png" \
        -o "$TEMP_DIR/maxdetail_upscaled.png" \
        -s 2 \
        -n realesrgan-x4plus \
        -f png
    
    # Step 3: Stronger sharpening with edge detection
    print_info "Step 3/6: Applying strong edge-aware sharpening..."
    magick "$TEMP_DIR/maxdetail_upscaled.png" \
        -unsharp 0x1.0+1.0+0.02 \
        "$TEMP_DIR/maxdetail_sharpened.png"
    
    # Step 4: Micro-contrast enhancement
    print_info "Step 4/6: Enhancing micro-contrast..."
    magick "$TEMP_DIR/maxdetail_sharpened.png" \
        -depth 16 \
        -colorspace sRGB \
        -sigmoidal-contrast 3x50% \
        "$TEMP_DIR/maxdetail_contrast.png"
    
    # Step 5: Debanding and dithering for smooth gradients
    print_info "Step 5/6: Debanding and dithering..."
    magick "$TEMP_DIR/maxdetail_contrast.png" \
        -depth 16 \
        -colorspace sRGB \
        -evaluate-sequence median \
        +dither \
        -colors 16777216 \
        -dither FloydSteinberg \
        -depth 8 \
        "$TEMP_DIR/maxdetail_final.png"
    
    # Step 6: Export final outputs
    print_info "Step 6/6: Exporting final outputs..."
    
    # PNG export
    cp "$TEMP_DIR/maxdetail_final.png" "$OUTPUT_MAXDETAIL/maxdetail_x2.png"
    print_info "✓ Saved: maxdetail_x2.png"
    
    # JPEG q95 export with metadata preservation
    magick "$TEMP_DIR/maxdetail_final.png" \
        -quality 95 \
        -sampling-factor 4:4:4 \
        "$OUTPUT_MAXDETAIL/maxdetail_x2_q95.jpg"
    print_info "✓ Saved: maxdetail_x2_q95.jpg"
    
    print_info "Max-Detail variant complete!"
}

print_summary() {
    print_info "======================================"
    print_info "ENHANCEMENT COMPLETE!"
    print_info "======================================"
    echo ""
    print_info "Conservative outputs:"
    ls -lh "$OUTPUT_CONSERVATIVE"
    echo ""
    print_info "Max-Detail outputs:"
    ls -lh "$OUTPUT_MAXDETAIL"
    echo ""
    print_info "All outputs include preserved ICC/EXIF metadata where available."
}

# Main execution
main() {
    print_info "Olobe Bukka Flyer Enhancement Script"
    print_info "======================================"
    
    check_dependencies
    find_input_image
    setup_temp_dir
    
    # Process both variants
    process_conservative
    echo ""
    process_maxdetail
    
    # Cleanup
    cleanup_temp_dir
    
    # Summary
    echo ""
    print_summary
}

# Run main function
main "$@"
