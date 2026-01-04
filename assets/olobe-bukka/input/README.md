# Source Image

## Current File
A **test image** (`original.jpg`) has been created to validate the pipeline structure. This is a synthetic flyer-like image with:
- Gradient background (purple to gold)
- Text-like elements
- Simulated compression artifacts
- Dimensions: 800x1200 pixels

## Replacing with Actual Flyer
To use the actual flyer image from the chat conversation:
- **Filename**: `original.jpg` or `original.png`
- **Location**: This directory (`assets/olobe-bukka/input/`)
- **Source**: The flyer image from the chat conversation

## Next Steps

1. Save the flyer image from the chat as `original.jpg` or `original.png`
2. Place it in this directory
3. Run the enhancement pipeline:
   ```bash
   bash scripts/enhance.sh assets/olobe-bukka/input/original.jpg
   ```

Or use the GitHub Actions workflow (Actions tab → "Flyer Enhancement Pipeline" → Run workflow).

## Image Requirements
- Format: JPEG or PNG
- Content: Business flyer with text, images, and graphics
- The pipeline will preserve all original content while enhancing clarity and reducing artifacts
