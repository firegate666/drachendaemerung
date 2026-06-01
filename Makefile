IMAGE := drachendaemmerung-latex

.PHONY: all gesamt abenteuer-template abenteuer1 image clean clean-image

all: gesamt abenteuer-template abenteuer1

# ── Docker image ──────────────────────────────────────────────────────────────

image:
	docker build -t $(IMAGE) .

# ── Documents ─────────────────────────────────────────────────────────────────

gesamt: image
	@bash scripts/docker-compile.sh . gesamt drachendaemmerung.pdf with-index

abenteuer-template: image
	@bash scripts/docker-compile.sh abenteuer_template abenteuer abenteuer_template.pdf

abenteuer1: image
	@bash scripts/docker-compile.sh abenteuer1 ab_dasdrachentier ab_dasdrachentier.pdf

# ── Housekeeping ──────────────────────────────────────────────────────────────

clean:
	rm -f \
	    drachendaemmerung.pdf gesamt.dvi gesamt.ps \
	    abenteuer_template/abenteuer_template.pdf abenteuer_template/abenteuer.dvi abenteuer_template/abenteuer.ps \
	    abenteuer1/ab_dasdrachentier.pdf abenteuer1/ab_dasdrachentier.dvi abenteuer1/ab_dasdrachentier.ps

clean-image: clean
	docker image rm -f $(IMAGE)
