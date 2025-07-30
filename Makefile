include /usr/share/dpkg/pkg-info.mk

# overwriting below ensures that we can build without full PVE installed
DGDIR=.
ASCIIDOC_PVE=./asciidoc-pve

BUILDDIR ?= $(DEB_SOURCE)-$(DEB_VERSION)
DSC=$(DEB_SOURCE)_$(DEB_VERSION).dsc

GEN_PACKAGE=pve-doc-generator
DOC_PACKAGE=pve-docs
MEDIAWIKI_PACKAGE=pve-docs-mediawiki

GITVERSION:=$(shell git rev-parse HEAD)

GEN_DEB=$(GEN_PACKAGE)_$(DEB_VERSION)_all.deb
DOC_DEB=$(DOC_PACKAGE)_$(DEB_VERSION)_all.deb
MEDIAWIKI_DEB=$(MEDIAWIKI_PACKAGE)_$(DEB_VERSION)_all.deb

export SOURCE_DATE_EPOCH ?= $(shell dpkg-parsechangelog -STimestamp)
SOURCE_DATE_HUMAN := $(shell date -d "@$(SOURCE_DATE_EPOCH)")

all: index.html

.PHONY: verify-images
verify-images:
	for i in ./images/screenshot/*.png; do ./png-verify.pl $$i; done

ADOC_SOURCES_GUESS=$(filter-out %-synopsis.adoc %-opts.adoc %-table.adoc, $(wildcard *.adoc))
.pve-doc-depends link-refs.json: $(ADOC_SOURCES_GUESS) scan-adoc-refs
	./scan-adoc-refs *.adoc --depends .pve-doc-depends.tmp > link-refs.json.tmp
	@cmp --quiet .pve-doc-depends .pve-doc-depends.tmp || mv .pve-doc-depends.tmp .pve-doc-depends
	@cmp --quiet link-refs.json link-refs.json.tmp || mv link-refs.json.tmp link-refs.json

pve-doc-generator.mk: .pve-doc-depends pve-doc-generator.mk.in
	cat pve-doc-generator.mk.in .pve-doc-depends > $@.tmp
	sed -i "s/@RELEASE@$$/$(DEB_VERSION_UPSTREAM)/" $@.tmp
	mv $@.tmp $@

-include ./pve-doc-generator.mk

GEN_DEB_SOURCES=				\
	pve-doc-generator.mk			\
	$(MANUAL_SOURCES)			\
	pmxcfs.8-synopsis.adoc			\
	qmeventd.8-synopsis.adoc		\
	docinfo.xml

GEN_SCRIPTS=					\
	gen-ha-groups-opts.pl			\
	gen-ha-resources-opts.pl		\
	gen-ha-rules-node-affinity-opts.pl	\
	gen-ha-rules-opts.pl			\
	gen-ha-rules-resource-affinity-opts.pl	\
	gen-datacenter.cfg.5-opts.pl		\
	gen-pct.conf.5-opts.pl			\
	gen-pct-network-opts.pl			\
	gen-pct-mountpoint-opts.pl		\
	gen-qm.conf.5-opts.pl			\
	gen-cpu-models.conf.5-opts.pl 		\
	gen-qm-cloud-init-opts.pl		\
	gen-vzdump.conf.5-opts.pl		\
	gen-pve-firewall-cluster-opts.pl	\
	gen-pve-firewall-host-opts.pl		\
	gen-pve-firewall-macros-adoc.pl		\
	gen-pve-firewall-rules-opts.pl		\
	gen-pve-firewall-vm-opts.pl		\
	gen-pve-firewall-vnet-opts.pl		\
	gen-output-format-opts.pl

API_VIEWER_FILES=							\
	api-viewer/apidata.js						\
	api-viewer/PVEAPI.js						\
	/usr/share/javascript/proxmox-widget-toolkit-dev/APIViewer.js

API_VIEWER_SOURCES=				\
	api-viewer/index.html			\
	api-viewer/apidoc.js

asciidoc-pve: asciidoc-pve.in link-refs.json
	cat asciidoc-pve.in link-refs.json >asciidoc-pve.tmp
	sed -e s/@RELEASE@/$(DOCRELEASE)/ -i asciidoc-pve.tmp
	chmod +x asciidoc-pve.tmp
	mv asciidoc-pve.tmp asciidoc-pve

pve-docs-mediawiki-import: pve-docs-mediawiki-import.in link-refs.json
	cat pve-docs-mediawiki-import.in link-refs.json >  pve-docs-mediawiki-import.tmp
	chmod +x pve-docs-mediawiki-import.tmp
	mv pve-docs-mediawiki-import.tmp pve-docs-mediawiki-import

INDEX_INCLUDES=								\
	pve-admin-guide.pdf 						\
	pve-admin-guide.epub 						\
	chapter-index-table.adoc					\
	man1-index-table.adoc						\
	man5-index-table.adoc						\
	man8-index-table.adoc						\
	$(sort $(addsuffix .html, $(MANUAL_PAGES)) $(CHAPTER_LIST))

ADOC_STDARG=-b $(shell pwd)/asciidoc/pve-html -f asciidoc/asciidoc-pve.conf -a icons -a data-uri -a "date=$(SOURCE_DATE_HUMAN)" -a "revnumber=$(DOCRELEASE)" -a footer-style=revdate

README.html: README.adoc
	asciidoc -a toc $(ADOC_STDARG) -o $@ $<

chapter-index-table.adoc: asciidoc-pve
	./asciidoc-pve chapter-table >$@.tmp
	mv $@.tmp $@

man1-index-table.adoc: asciidoc-pve
	./asciidoc-pve man1page-table >$@.tmp
	mv $@.tmp $@

man5-index-table.adoc: asciidoc-pve
	./asciidoc-pve man5page-table >$@.tmp
	mv $@.tmp $@

man8-index-table.adoc: asciidoc-pve
	./asciidoc-pve man8page-table >$@.tmp
	mv $@.tmp $@

index.html: index.adoc $(API_VIEWER_SOURCES) $(INDEX_INCLUDES)
	asciidoc $(ADOC_STDARG) -o $@ index.adoc

pve-admin-guide.html: $(PVE_ADMIN_GUIDE_ADOCDEPENDS)
	asciidoc -a pvelogo $(ADOC_STDARG) -o $@ pve-admin-guide.adoc

pve-admin-guide.chunked: $(PVE_ADMIN_GUIDE_ADOCDEPENDS)
	rm -rf $@.tmp $@
	mkdir $@.tmp
	a2x -D $@.tmp -a docinfo -a docinfo1 -a icons -f chunked pve-admin-guide.adoc
	mv $@.tmp/$@ $@

PVE_DOCBOOK_CONF=-b $(shell pwd)/asciidoc/pve-docbook -f asciidoc/asciidoc-pve.conf
PVE_DBLATEX_OPTS='-p ./asciidoc/pve-dblatex.xsl -s asciidoc/dblatex-custom.sty -c asciidoc/dblatex-export.conf'

YEAR:=$(shell date '+%Y')
pve-admin-guide-docinfo.xml: pve-admin-guide-docinfo.xml.in
	sed -e 's/@RELEASE@/$(DOCRELEASE)/' -e 's/@YEAR@/$(YEAR)/' <$< >$@

pve-admin-guide.pdf: $(PVE_ADMIN_GUIDE_ADOCDEPENDS) docinfo.xml pve-admin-guide-docinfo.xml
	rsvg-convert -f pdf -o proxmox-logo.pdf images/proxmox-logo.svg
	rsvg-convert -f pdf -o proxmox-ci-header.pdf images/proxmox-ci-header.svg
	grep ">Release $(DOCRELEASE)<" pve-admin-guide-docinfo.xml || (echo "wrong release in  pve-admin-guide-docinfo.xml" && false);
	a2x -a docinfo -a docinfo1 -f pdf -L --asciidoc-opts="$(PVE_DOCBOOK_CONF)" --dblatex-opts $(PVE_DBLATEX_OPTS) pve-admin-guide.adoc
	rm proxmox-logo.pdf proxmox-ci-header.pdf

pve-admin-guide.epub: $(PVE_ADMIN_GUIDE_ADOCDEPENDS)
	rm -rf $@.tmp $@
	mkdir $@.tmp
	a2x -D $@.tmp -f epub --asciidoc-opts="$(PVE_DOCBOOK_CONF)" pve-admin-guide.adoc
	mv $@.tmp/$@ $@

api-viewer/apidata.js: extractapi.pl
	./extractapi.pl >$@

api-viewer/apidoc.js: $(API_VIEWER_FILES)
	cat $(API_VIEWER_FILES) >$@.tmp
	mv $@.tmp $@

$(BUILDDIR):
	rm -rf $@ $@.tmp
	rsync -a * $@.tmp/
	echo "git clone git://git.proxmox.com/git/pve-docs.git\\ngit checkout $(GITVERSION)" > $@.tmp/debian/SOURCE
	mv $@.tmp $@

.PHONY: dsc deb
dsc: $(DSC)
$(DSC): $(BUILDDIR)
	cd $(BUILDDIR); dpkg-buildpackage -S -us -uc -d
	lintian $(DSC)

sbuild: $(DSC)
	sbuild $(DSC)

deb:
	rm -f $(GEN_DEB) $(DOC_DEB) $(MEDIAWIKI_DEB)
	rm -rf $(BUILDDIR)
	$(MAKE) $(DOC_DEB)

$(MEDIAWIKI_DEB) $(GEN_DEB): $(DOC_DEB)
$(DOC_DEB): $(BUILDDIR)
	cd $(BUILDDIR); dpkg-buildpackage -b -us -uc
	lintian $(DOC_DEB) $(GEN_DEB) $(MEDIAWIKI_DEB)

.PHONY: dinstall
dinstall: $(GEN_DEB) $(DOC_DEB) $(MEDIAWIKI_DEB)
	dpkg -i $(GEN_DEB) $(DOC_DEB) # $(MEDIAWIKI_DEB)

.PHONY: clean-build
clean-build:
	rm -rf build

.PHONY: install
install: gen-install doc-install mediawiki-install

.PHONY: gen-install
gen-install: $(GEN_DEB_SOURCES) asciidoc-pve asciidoc/mediawiki.conf
	install -dm755 $(DESTDIR)/usr/share/$(GEN_PACKAGE)
	install -dm755 $(DESTDIR)/usr/share/doc/$(GEN_PACKAGE)
	install -dm755 $(DESTDIR)/usr/bin
	# install files
	install -m 0644 $(GEN_DEB_SOURCES) $(DESTDIR)/usr/share/$(GEN_PACKAGE)
	install -m 0755 $(GEN_SCRIPTS) $(DESTDIR)/usr/share/$(GEN_PACKAGE)
	# install asciidoc-pve
	install -m 0755 asciidoc-pve $(DESTDIR)/usr/bin/
	install -D -m 0644 asciidoc/mediawiki.conf $(DESTDIR)/usr/share/$(GEN_PACKAGE)/asciidoc/mediawiki.conf
	install -m 0644 asciidoc/asciidoc-pve.conf $(DESTDIR)/usr/share/$(GEN_PACKAGE)/asciidoc/
	install -m 0644 asciidoc/pve-docbook.conf $(DESTDIR)/usr/share/$(GEN_PACKAGE)/asciidoc/
	install -m 0644 asciidoc/pve-html.conf $(DESTDIR)/usr/share/$(GEN_PACKAGE)/asciidoc/

.PHONY: doc-install
doc-install: index.html $(WIKI_IMPORTS) $(API_VIEWER_SOURCES) verify-images examples
	install -dm755 $(DESTDIR)/usr/share/$(DOC_PACKAGE)
	install -dm755 $(DESTDIR)/usr/share/doc/$(DOC_PACKAGE)
	# install files for pvedocs package
	install -dm755 $(DESTDIR)/usr/share/$(DOC_PACKAGE)
	install -dm755 $(DESTDIR)/usr/share/doc/$(DOC_PACKAGE)
	install -dm755 $(DESTDIR)/usr/share/$(DOC_PACKAGE)/examples/
	install -m 755 examples/guest-example-hookscript.pl $(DESTDIR)/usr/share/$(DOC_PACKAGE)/examples/
	install -m 0644 index.html $(INDEX_INCLUDES) $(DESTDIR)/usr/share/$(DOC_PACKAGE)
	install -m 0644 $(WIKI_IMPORTS) $(DESTDIR)/usr/share/$(DOC_PACKAGE)
	# install images
	make -C images install
	# install screenshot images
	install -dm755 $(DESTDIR)/usr/share/$(DOC_PACKAGE)/images/screenshot
	install -m 0644 images/screenshot/*.png $(DESTDIR)/usr/share/$(DOC_PACKAGE)/images/screenshot
	# install api doc viewer
	install -dm755 $(DESTDIR)/usr/share/$(DOC_PACKAGE)/api-viewer
	install -m 0644 $(API_VIEWER_SOURCES) $(DESTDIR)/usr/share/$(DOC_PACKAGE)/api-viewer

.PHONY: mediawiki-install
mediawiki-install: pve-docs-mediawiki-import
	install -dm755 $(DESTDIR)/usr/share/$(MEDIAWIKI_PACKAGE)
	install -dm755 $(DESTDIR)/usr/share/doc/$(MEDIAWIKI_PACKAGE)
	install -dm755 $(DESTDIR)/usr/bin
	install -dm755 $(DESTDIR)/usr/share/$(MEDIAWIKI_PACKAGE)
	install -dm755 $(DESTDIR)/usr/share/doc/$(MEDIAWIKI_PACKAGE)
	install -m 0755 pve-docs-mediawiki-import $(DESTDIR)/usr/bin/

.PHONY: upload
upload: UPLOAD_DIST ?= $(DEB_DISTRIBUTION)
upload: $(GEN_DEB) $(DOC_DEB) $(MEDIAWIKI_DEB)
	tar cf - $(GEN_DEB) $(DOC_DEB) $(MEDIAWIKI_DEB) | ssh -X repoman@repo.proxmox.com -- upload --product pve --dist $(UPLOAD_DIST)

.PHONY: update
update:
	make clean clean-static
	make update-static
	make all

.PHONY: update-static
update-static:
	make clean-static
	make $(filter %-synopsis.adoc %-opts.adoc, $(PVE_ADMIN_GUIDE_ADOCDEPENDS)) pve-firewall-macros.adoc api-viewer/apidata.js

.PHONY: clean-static
clean-static:
	find . -regex '.*-\(opts\|synopsis\)\.adoc' -not -name pmxcfs.8-synopsis.adoc -not -name qmeventd.8-synopsis.adoc -exec rm -f \{\} \;
	rm -f api-viewer/apidata.js
	rm -f pve-firewall-macros.adoc pct-network-opts.adoc pct-mountpoint-opts.adoc

clean:
	rm -rf *.html *.pdf *.epub *.tmp *.1 *.5 *.8
	rm -f *.deb *.dsc *.tar.* *.changes *.buildinfo *.build
	rm -f api-viewer/apidoc.js chapter-*.html *-plain.html chapter-*.html pve-admin-guide.chunked asciidoc-pve link-refs.json .asciidoc-pve-tmp_* pve-docs-mediawiki-import
	rm -rf .pve-doc-depends
	rm -f pve-doc-generator.mk chapter-index-table.adoc man1-index-table.adoc man5-index-table.adoc man8-index-table.adoc pve-admin-guide-docinfo.xml
	rm -rf $(DEB_SOURCE)-[0-9]*/
