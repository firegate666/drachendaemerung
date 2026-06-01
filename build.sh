#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="drachendaemmerung-latex"
OUTPUT="drachendaemmerung.pdf"

# Build Docker image (cached after first run)
echo "==> Building Docker image..."
docker build -t "$IMAGE" "$SCRIPT_DIR"

echo "==> Compiling LaTeX (latex -> makeindex -> latex -> dvips -> ps2pdf)..."
docker run --rm \
    -v "$SCRIPT_DIR:/build" \
    -w /build \
    "$IMAGE" \
    bash -c "
        set -e
        run_latex() {
            latex -interaction=nonstopmode gesamt.tex || true
            if [ ! -f gesamt.dvi ]; then
                echo 'ERROR: gesamt.dvi not produced, check gesamt.log'
                exit 1
            fi
        }
        echo '--- Step 1/6: latex (first pass)'
        run_latex
        echo '--- Step 2/6: makeindex'
        makeindex gesamt.idx -o gesamt.ind
        makeindex gesamt.pdx -o gesamt.pnd
        makeindex gesamt.rdx -o gesamt.rnd
        echo '--- Step 3/6: latex (second pass)'
        run_latex
        echo '--- Step 4/6: latex (third pass, resolves index references)'
        run_latex
        echo '--- Step 5/6: dvips'
        dvips gesamt.dvi -o gesamt.ps || true
        if [ ! -f gesamt.ps ]; then
            echo 'ERROR: gesamt.ps not produced, check dvips output'
            exit 1
        fi
        echo '--- Step 6/6: ps2pdf'
        ps2pdf gesamt.ps '$OUTPUT'
    "

echo "==> Done: $SCRIPT_DIR/$OUTPUT"
