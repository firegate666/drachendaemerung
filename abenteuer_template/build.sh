#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGE="drachendaemmerung-latex"
OUTPUT="abenteuer_template.pdf"

# Reuse the shared image (build it if not present)
if ! docker image inspect "$IMAGE" &>/dev/null; then
    echo "==> Building Docker image..."
    docker build -t "$IMAGE" "$PROJECT_ROOT"
fi

echo "==> Compiling LaTeX (latex -> latex -> dvips -> ps2pdf)..."
docker run --rm \
    -v "$PROJECT_ROOT:/build" \
    -w /build/abenteuer_template \
    "$IMAGE" \
    bash -c "
        set -e
        run_latex() {
            latex -interaction=nonstopmode abenteuer.tex || true
            if [ ! -f abenteuer.dvi ]; then
                echo 'ERROR: abenteuer.dvi not produced, check abenteuer.log'
                exit 1
            fi
        }
        echo '--- Step 1/4: latex (first pass)'
        run_latex
        echo '--- Step 2/4: latex (second pass)'
        run_latex
        echo '--- Step 3/4: dvips'
        dvips abenteuer.dvi -o abenteuer.ps || true
        if [ ! -f abenteuer.ps ]; then
            echo 'ERROR: abenteuer.ps not produced, check dvips output'
            exit 1
        fi
        echo '--- Step 4/4: ps2pdf'
        ps2pdf abenteuer.ps '$OUTPUT'
    "

echo "==> Done: $SCRIPT_DIR/$OUTPUT"
