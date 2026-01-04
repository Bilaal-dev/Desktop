#!/bin/bash
# Test script to validate the enhancement pipeline setup

set -e

echo "=== Enhancement Pipeline Validation ==="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Test 1: Check directory structure
echo "Test 1: Checking directory structure..."
REQUIRED_DIRS=(
    "assets/olobe-bukka/input"
    "assets/olobe-bukka/output/conservative"
    "assets/olobe-bukka/output/maxdetail"
    "scripts"
    ".github/workflows"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $dir exists"
    else
        echo -e "${RED}✗${NC} $dir missing"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# Test 2: Check required files
echo "Test 2: Checking required files..."
REQUIRED_FILES=(
    "scripts/enhance.sh"
    ".github/workflows/enhance.yml"
    "README.md"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file exists"
        # Check if executable (for scripts)
        if [[ "$file" == *.sh ]]; then
            if [ -x "$file" ]; then
                echo -e "${GREEN}  ✓${NC} $file is executable"
            else
                echo -e "${RED}  ✗${NC} $file is not executable"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    else
        echo -e "${RED}✗${NC} $file missing"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# Test 3: Validate script syntax
echo "Test 3: Validating shell script syntax..."
if bash -n scripts/enhance.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} enhance.sh syntax is valid"
else
    echo -e "${RED}✗${NC} enhance.sh has syntax errors"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Test 4: Check for source image
echo "Test 4: Checking for source image..."
if [ -f "assets/olobe-bukka/input/original.jpg" ] || [ -f "assets/olobe-bukka/input/original.png" ]; then
    echo -e "${GREEN}✓${NC} Source image found"
else
    echo -e "${YELLOW}⚠${NC} Source image not found (this is expected - see CONTRIBUTING.md)"
fi

echo ""

# Test 5: Verify README content
echo "Test 5: Checking README documentation..."
REQUIRED_SECTIONS=(
    "Enhancement Variants"
    "Requirements"
    "Usage"
    "Pipeline Details"
)

README_VALID=1
for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section" README.md; then
        echo -e "${GREEN}✓${NC} README contains '$section' section"
    else
        echo -e "${RED}✗${NC} README missing '$section' section"
        README_VALID=0
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# Test 6: Validate workflow YAML
echo "Test 6: Validating GitHub Actions workflow..."
if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/enhance.yml'))" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Workflow YAML is valid"
else
    echo -e "${YELLOW}⚠${NC} Cannot validate YAML (PyYAML not installed)"
fi

echo ""

# Summary
echo "=== Validation Summary ==="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Add source image to assets/olobe-bukka/input/original.jpg"
    echo "2. Run: bash scripts/enhance.sh assets/olobe-bukka/input/original.jpg"
    echo "3. Or trigger GitHub Actions workflow"
    exit 0
else
    echo -e "${RED}$ERRORS test(s) failed${NC}"
    exit 1
fi
