# Drachendämmerung

A German-language tabletop RPG worldbook written in LaTeX by Marco Behnke.
Inspired by the *Dragonlance Chronicles*, this is a High Fantasy setting built as an extension
for the ERPS (Ernest Role Playing System) rule system, usable with other systems as well.

## Project structure

```
gesamt.tex              master document
docform.tex             page layout and package configuration
Makefile                build all documents
Dockerfile              build environment (TeX Live full)
scripts/
  docker-compile.sh     shared compile helper used by the Makefile
compile.sh              original build script (historical reference)

klassen/                character classes (18 classes)
rassen/                 races (5 races)
magie/                  magic schools (6 schools)
die_staedte/            city descriptions (8 cities)
zeitalter/              world history / ages
legenden/               legends and stories
voelker/                peoples
abenteuer1/             first adventure module
abenteuer_template/     template for new adventures
pics/                   EPS illustrations
```

## Building

Requires [Docker](https://www.docker.com/) and `make`.

| Command | Output |
|---|---|
| `make` / `make all` | Build all three documents |
| `make gesamt` | `drachendaemmerung.pdf` (main rulebook) |
| `make abenteuer-template` | `abenteuer_template/abenteuer_template.pdf` |
| `make abenteuer1` | `abenteuer1/ab_dasdrachentier.pdf` |
| `make image` | (Re)build the Docker image only |
| `make clean` | Remove generated PDF, DVI, and PS files |
| `make clean-image` | `clean` + remove the Docker image |

The first run pulls `texlive/texlive:latest` (several GB); subsequent runs use the cached image.

### Adding a new adventure

1. Copy `abenteuer_template/` to a new folder (e.g. `abenteuer2/`)
2. Add a target to the `Makefile`:
   ```makefile
   abenteuer2: image
       @bash scripts/docker-compile.sh abenteuer2 <main-tex-basename> <output>.pdf
   ```
3. Add the new target to the `all` dependency list

### Converting a JPG/PNG logo to EPS (for the title page)

```bash
magick pics/drache_final.jpg -fuzz 10% -transparent white pics/dd.eps
```

Requires [ImageMagick](https://imagemagick.org/) (`brew install imagemagick`).

## TODO — missing illustration files

The following EPS files are referenced in the source but missing from `pics/`.
The build completes without them (dvips skips missing figures), but the corresponding
pages will have blank spaces where the illustrations should appear.

| Missing file | Referenced in | Description |
|---|---|---|
| `pics/kleriker.eps` | `klassen/kleriker.tex:3` | Illustration for the Kleriker (Priest/Cleric) character class |
| `pics/moonshadow.eps` | `zeitalter/ersteszeitalter.tex` | Illustration in the First Age (Erstes Zeitalter) chapter |

## Build pipeline

The project uses the classic latex → dvips → ps2pdf pipeline (not pdflatex)
because all graphics are EPS files.

```
latex gesamt.tex          (first pass — generates .aux, .idx, .pdx, .rdx)
makeindex gesamt.idx      (main keyword index)
makeindex gesamt.pdx      (persons index)
makeindex gesamt.rdx      (cities/regions index)
latex gesamt.tex          (second pass — incorporates index data)
latex gesamt.tex          (third pass — resolves cross-references)
dvips gesamt.dvi          (DVI → PostScript)
ps2pdf gesamt.ps          (PostScript → PDF)
```

## License

See [LICENSE](LICENSE).
