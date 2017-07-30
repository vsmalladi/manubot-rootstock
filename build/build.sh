set -o errexit

# Default Python to read/write text files using UTF-8 encoding
export LC_ALL=en_US.UTF-8

# Generate reference information
echo "Retrieving and processing reference metadata"
(cd build && python references.py)

# pandoc settings
CSL_PATH=references/style.csl
DOCX_PATH=references/pandoc-reference.docx
BIBLIOGRAPHY_PATH=references/generated/bibliography.json
INPUT_PATH=references/generated/all-sections.md

# Make output directory
mkdir -p output

# Create HTML output
# http://pandoc.org/MANUAL.html
echo "Exporting HTML manuscript"
pandoc --verbose \
  --smart \
  --from=markdown \
  --to=html \
  --filter pandoc-fignos \
  --filter pandoc-eqnos \
  --filter pandoc-tablenos \
  --bibliography=$BIBLIOGRAPHY_PATH \
  --csl=$CSL_PATH \
  --metadata link-citations=true \
  --css=github-pandoc.css \
  --include-in-header=build/assets/analytics.js \
  --include-after-body=build/assets/anchors.js \
  --output=output/index.html \
  $INPUT_PATH

# Create PDF output
echo "Exporting PDF manuscript"
wkhtmltopdf \
  --quiet \
  output/index.html \
  output/manuscript.pdf

# Create DOCX output when user specifies to do so
if [ "$BUILD_DOCX" = "true" ];
then
    echo "Exporting Word Docx manuscript"
    pandoc --verbose \
    --smart \
    --from=markdown \
    --to=docx \
    --filter pandoc-fignos \
    --filter pandoc-tablenos \
    --filter pandoc-img-glob \
    --filter build/pandoc-svg.py \
    --bibliography=$BIBLIOGRAPHY_PATH \
    --metadata link-citations=true \
    --csl=$CSL_PATH \
    --reference-docx=$DOCX_PATH \
    --output=output/manuscript.docx \
    $INPUT_PATH
fi

# Create another pdf
echo "Exporting test manuscript"
pandoc \
  --from=markdown \
  --to=html5 \
  --filter pandoc-fignos \
  --filter pandoc-eqnos \
  --filter pandoc-tablenos \
  --filter pandoc-img-glob \
  --filter build/pandoc-svg.py \
  --bibliography=$BIBLIOGRAPHY_PATH \
  --csl=$CSL_PATH \
  --metadata link-citations=true \
  --css=github-pandoc.css \
  --include-in-header=build/assets/analytics.js \
  --include-after-body=build/assets/anchors.js \
  --output=output/index.pdf \
  $INPUT_PATH
