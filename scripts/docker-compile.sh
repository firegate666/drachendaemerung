#!/usr/bin/env bash
# Compiles a LaTeX document inside the shared Docker image.
#
# Usage: docker-compile.sh <subdir> <texbase> <output-pdf> [with-index]
#   subdir      path relative to project root (use . for the root itself)
#   texbase     base name of the main .tex file (without .tex extension)
#   output-pdf  filename for the generated PDF
#   with-index  pass "with-index" to run makeindex between latex passes
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="drachendaemmerung-latex"
SUBDIR="$1"
TEXBASE="$2"
OUTPUT="$3"
WITH_INDEX="${4:-}"

echo "==> Building ${OUTPUT}..."

docker run --rm -i \
    -v "${ROOT}:/build" \
    -w "/build/${SUBDIR}" \
    "${IMAGE}" \
    bash << EOF
set -e

run_latex() {
    latex -interaction=nonstopmode ${TEXBASE}.tex || true
    [ -f ${TEXBASE}.dvi ] || { echo "ERROR: ${TEXBASE}.dvi not produced — check ${TEXBASE}.log"; exit 1; }
}

echo "--- Step 1: latex (first pass)"
run_latex

if [ "${WITH_INDEX}" = "with-index" ]; then
    echo "--- Step 2: makeindex"
    makeindex ${TEXBASE}.idx -o ${TEXBASE}.ind
    makeindex ${TEXBASE}.pdx -o ${TEXBASE}.pnd
    makeindex ${TEXBASE}.rdx -o ${TEXBASE}.rnd
    echo "--- Step 3: latex (second pass)"; run_latex
    echo "--- Step 4: latex (third pass)";  run_latex
    echo "--- Step 5: dvips"
else
    echo "--- Step 2: latex (second pass)"; run_latex
    echo "--- Step 3: dvips"
fi

dvips ${TEXBASE}.dvi -o ${TEXBASE}.ps || true
[ -f ${TEXBASE}.ps ] || { echo "ERROR: ${TEXBASE}.ps not produced"; exit 1; }

echo "--- Final step: ps2pdf"
ps2pdf ${TEXBASE}.ps ${OUTPUT}
EOF

echo "==> Done: $(cd "${ROOT}/${SUBDIR}" && pwd)/${OUTPUT}"
