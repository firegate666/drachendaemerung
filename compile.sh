latex gesamt.tex
makeindex gesamt.idx -o gesamt.ind
makeindex gesamt.pdx -o gesamt.pnd
makeindex gesamt.rdx -o gesamt.rnd
latex gesamt.tex
#dvips -Z* gesamt.dvi
#ps2pdf gesamt.ps
#cp gesamt.pdf dd.pdf
#zip -9 -j dd.zip dd.pdf
