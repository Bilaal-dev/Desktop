# Source Image Required

The enhancement pipeline is ready, but the source image needs to be placed here.

## Expected File
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
