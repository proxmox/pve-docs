DGDIR=.
ASCIIDOC_PVE=./asciidoc-pve

GEN_PACKAGE=pve-doc-generator
DOC_PACKAGE=pve-docs
MEDIAWIKI_PACKAGE=pve-docs-mediawiki

# also update debian/changelog
PKGREL=15

GITVERSION:=$(shell cat .git/refs/heads/master)

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)

GEN_DEB=${GEN_PACKAGE}_${DOCRELEASE}-${PKGREL}_${ARCH}.deb
DOC_DEB=${DOC_PACKAGE}_${DOCRELEASE}-${PKGREL}_all.deb
MEDIAWIKI_DEB=${MEDIAWIKI_PACKAGE}_${DOCRELEASE}-${PKGREL}_all.deb


all: index.html

.PHONY: verify-images
verify-images:
	for i in ./images/screenshot/*.png; do ./png-verify.pl $$i; done

ADOC_SOURCES_GUESS=$(filter-out %-synopsis.adoc %-opts.adoc %-table.adoc, $(wildcard *.adoc))
.pve-doc-depends link-refs.json: ${ADOC_SOURCES_GUESS} scan-adoc-refs
	./scan-adoc-refs *.adoc --depends .pve-doc-depends.tmp > link-refs.json.tmp
	@cmp --quiet .pve-doc-depends .pve-doc-depends.tmp || mv .pve-doc-depends.tmp .pve-doc-depends
	@cmp --quiet link-refs.json link-refs.json.tmp || mv link-refs.json.tmp link-refs.json

pve-doc-generator.mk: .pve-doc-depends pve-doc-generator.mk.in
	cat pve-doc-generator.mk.in .pve-doc-depends > $@.tmp
	mv $@.tmp $@

include ./pve-doc-generator.mk

GEN_DEB_SOURCES=				\
	pve-doc-generator.mk			\
	${MANUAL_SOURCES}			\
	pmxcfs.8-synopsis.adoc			\
	docinfo.xml

GEN_SCRIPTS=					\
	gen-datacenter.cfg.5-opts.pl		\
	gen-pct.conf.5-opts.pl			\
	gen-pct-network-opts.pl			\
	gen-pct-mountpoint-opts.pl		\
	gen-qm.conf.5-opts.pl			\
	gen-vzdump.conf.5-opts.pl		\
	gen-pve-firewall-cluster-opts.pl	\
	gen-pve-firewall-host-opts.pl		\
	gen-pve-firewall-macros-adoc.pl		\
	gen-pve-firewall-rules-opts.pl		\
	gen-pve-firewall-vm-opts.pl

API_VIEWER_SOURCES=				\
	api-viewer/index.html			\
	api-viewer/apidoc.js

asciidoc-pve: asciidoc-pve.in link-refs.json
	cat asciidoc-pve.in link-refs.json >asciidoc-pve.tmp
	sed -e s/@RELEASE@/${DOCRELEASE}/ -i asciidoc-pve.tmp
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
	$(sort $(addsuffix .html, ${MANUAL_PAGES}) ${CHAPTER_LIST})

ADOC_STDARG=-b $(shell pwd)/asciidoc/pve-html -f asciidoc/asciidoc-pve.conf -a icons -a data-uri -a "date=$(shell date)" -a "revnumber=${DOCRELEASE}"

BROWSER?=xdg-open


%-nwdiag.svg: %.nwdiag
	nwdiag -T svg $*.nwdiag -o $@;

README.html: README.adoc
	asciidoc ${ADOC_STDARG} -o $@ $<

.PHONY: index
index: index.html
	$(BROWSER) index.html &

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

index.html: index.adoc ${API_VIEWER_SOURCES} ${INDEX_INCLUDES}
	asciidoc ${ADOC_STDARG} -o $@ index.adoc

pve-admin-guide.html: ${PVE_ADMIN_GUIDE_ADOCDEPENDS}
	asciidoc -a pvelogo ${ADOC_STDARG} -o $@ pve-admin-guide.adoc

pve-admin-guide.chunked: ${PVE_ADMIN_GUIDE_ADOCDEPENDS}
	rm -rf pve-admin-guide.chunked
	a2x -a docinfo -a docinfo1 -a icons -f chunked pve-admin-guide.adoc

PVE_DOCBOOK_CONF=-b $(shell pwd)/asciidoc/pve-docbook -f asciidoc/asciidoc-pve.conf

pve-admin-guide.pdf: ${PVE_ADMIN_GUIDE_ADOCDEPENDS} docinfo.xml pve-admin-guide-docinfo.xml
	inkscape -z -D --export-pdf=proxmox-logo.pdf images/proxmox-logo.svg
	inkscape -z -D --export-pdf=proxmox-ci-header.pdf images/proxmox-ci-header.svg
	grep ">Release ${DOCRELEASE}<" pve-admin-guide-docinfo.xml || (echo "wrong release in  pve-admin-guide-docinfo.xml" && false);
	a2x -a docinfo -a docinfo1 -f pdf -L --asciidoc-opts="${PVE_DOCBOOK_CONF}" --dblatex-opts "-p ./asciidoc/pve-dblatex.xsl -s asciidoc/dblatex-custom.sty" pve-admin-guide.adoc
	rm proxmox-logo.pdf proxmox-ci-header.pdf

pve-admin-guide.epub: ${PVE_ADMIN_GUIDE_ADOCDEPENDS}
	a2x -f epub --asciidoc-opts="${PVE_DOCBOOK_CONF}" pve-admin-guide.adoc

api-viewer/apidata.js: extractapi.pl
	./extractapi.pl >$@

api-viewer/apidoc.js: api-viewer/apidata.js api-viewer/PVEAPI.js
	cat api-viewer/apidata.js api-viewer/PVEAPI.js >$@

.PHONY: dinstall
dinstall: ${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB}
	dpkg -i ${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB}

.PHONY: deb
deb:
	rm -f ${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB};
	make ${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB};

${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB}: index.html ${INDEX_INCLUDES} ${WIKI_IMPORTS} ${API_VIEWER_SOURCES} ${GEN_DEB_SOURCES} asciidoc-pve pve-docs-mediawiki-import asciidoc/mediawiki.conf verify-images
	rm -rf build
	mkdir build
	rsync -a debian/ build/debian
	cp pve-docs-mediawiki-import build/debian/tree/pve-docs-mediawiki/pve-docs-mediawiki-import
	echo "git clone git://git.proxmox.com/git/pve-docs.git\\ngit checkout ${GITVERSION}" > build/debian/SOURCE
	# install files for pve-doc-generator package
	mkdir -p build/usr/share/${GEN_PACKAGE}
	mkdir -p build/usr/share/doc/${GEN_PACKAGE}
	mkdir -p build/usr/bin
	install -m 0644 ${GEN_DEB_SOURCES} build/usr/share/${GEN_PACKAGE}
	install -m 0755 ${GEN_SCRIPTS} build/usr/share/${GEN_PACKAGE}
	# install asciidoc-pve
	install -m 0755 asciidoc-pve build/usr/bin/
	install -D -m 0644 asciidoc/mediawiki.conf build/usr/share/${GEN_PACKAGE}/asciidoc/mediawiki.conf
	install -m 0644 asciidoc/asciidoc-pve.conf build/usr/share/${GEN_PACKAGE}/asciidoc/
	install -m 0644 asciidoc/pve-html.conf build/usr/share/${GEN_PACKAGE}/asciidoc/
	# install files for pvedocs package
	mkdir -p build/usr/share/${DOC_PACKAGE}
	mkdir -p build/usr/share/doc/${DOC_PACKAGE}
	install -m 0644 index.html ${INDEX_INCLUDES} build/usr/share/${DOC_PACKAGE}
	install -m 0644 ${WIKI_IMPORTS} build/usr/share/${DOC_PACKAGE}
	# install screenshot images
	mkdir -p build/usr/share/${DOC_PACKAGE}/images/screenshot
	install -m 0644 images/screenshot/*.png build/usr/share/${DOC_PACKAGE}/images/screenshot
	# install api doc viewer
	mkdir build/usr/share/${DOC_PACKAGE}/api-viewer
	install -m 0644 ${API_VIEWER_SOURCES} build/usr/share/${DOC_PACKAGE}/api-viewer
	# build Debian packages
	cd build; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${GEN_DEB}
	lintian ${DOC_DEB}
	lintian ${MEDIAWIKI_DEB}

.PHONY: upload
upload: ${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB}
	tar cf - ${GEN_DEB} ${DOC_DEB} ${MEDIAWIKI_DEB} | ssh repoman@repo.proxmox.com upload

.PHONY: update
update: clean
	find . -regex '.*-\(opts\|synopsis\)\.adoc' -not -name pmxcfs.8-synopsis.adoc -exec rm -f \{\} \;
	rm -f api-viewer/apidata.js
	rm -f pve-firewall-macros.adoc pct-network-opts.adoc pct-mountpoint-opts.adoc
	make all

clean: 
	rm -rf *.html *.pdf *.epub *.tmp *.1 *.5 *.8 *.deb *.changes build api-viewer/apidoc.js chapter-*.html *-plain.html chapter-*.html pve-admin-guide.chunked asciidoc-pve link-refs.json .asciidoc-pve-tmp_* pve-docs-mediawiki-import .pve-doc-depends pve-doc-generator.mk chapter-index-table.adoc man1-index-table.adoc man5-index-table.adoc man8-index-table.adoc
	find . -name '*~' -exec rm {} ';'
