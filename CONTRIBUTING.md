# Adding the Source Image

Since the source image from the chat conversation cannot be automatically extracted, please follow these steps to complete the setup:

## Steps to Add the Image

1. **Locate the flyer image** from the chat conversation
   
2. **Save the image** to your local machine

3. **Add to repository**:
   ```bash
   # Option A: Using git (recommended)
   # Save the image as original.jpg in the input directory
   cp /path/to/your/flyer-image.jpg assets/olobe-bukka/input/original.jpg
   
   # Stage and commit
   git add assets/olobe-bukka/input/original.jpg
   git commit -m "Add source flyer image for enhancement"
   git push
   ```

   ```bash
   # Option B: Via GitHub web interface
   # 1. Navigate to: assets/olobe-bukka/input/
   # 2. Click "Add file" → "Upload files"
   # 3. Upload your image as "original.jpg"
   # 4. Commit directly to the branch
   ```

## Running the Pipeline

Once the image is added, you can run the enhancement pipeline:

### Locally
```bash
bash scripts/enhance.sh assets/olobe-bukka/input/original.jpg
```

### Via GitHub Actions
1. Go to the "Actions" tab in your repository
2. Select "Flyer Enhancement Pipeline"
3. Click "Run workflow"
4. Wait for completion
5. Download the artifacts containing all enhanced variants

## Expected Results

After running, you should have 6 output files:

**Conservative variant** (natural enhancement):
- `conservative_original_clean.png` - Cleaned original
- `conservative_x2.png` - 2x upscale PNG
- `conservative_x2_q95.jpg` - 2x upscale JPEG

**Max-Detail variant** (maximum clarity):
- `maxdetail_original_clean.png` - Cleaned original
- `maxdetail_x2.png` - 2x upscale PNG
- `maxdetail_x2_q95.jpg` - 2x upscale JPEG

## Image Requirements

The pipeline works best with:
- **Format**: JPEG or PNG
- **Content**: Flyers, posters, documents with text and graphics
- **Resolution**: Any resolution (will be upscaled 2x)
- **Color**: RGB or grayscale

The flyer mentioned in the requirements contains:
- Business information (Olobe Bukka)
- Hiring roles
- Food imagery
- Text with gold/purple colors
- Gradient backgrounds

The enhancement will:
- ✓ Preserve all original content
- ✓ Reduce compression artifacts
- ✓ Enhance text clarity
- ✓ Improve gradient smoothness
- ✓ Maintain natural colors
- ✗ Not alter design or content
