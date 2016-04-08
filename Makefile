DGDIR=.

include ./pve-doc-generator.mk

PACKAGE=pve-doc-generator

# also update debian/changelog
PKGREL=1

GITVERSION:=$(shell cat .git/refs/heads/master)

DEB=${PACKAGE}_${DOCRELEASE}-${PKGREL}_amd64.deb


DEB_SOURCES=			\
	pve-doc-generator.mk	\
	attributes.txt		\
	pvesm.adoc		\
	pve-storage-dir.adoc 	\
	pve-storage-glusterfs.adoc	\
	pve-storage-iscsi.adoc		\
	pve-storage-iscsidirect.adoc	\
	pve-storage-lvm.adoc		\
	pve-storage-nfs.adoc		\
	pve-storage-rbd.adoc		\
	pve-storage-zfspool.adoc	\
	pvecm.adoc			\
	pveum.adoc		\
	vzdump.adoc		\
	pve-firewall.adoc	\
	qm.adoc			\
	vm.conf.adoc		\
	pct.adoc		\
	pct.conf.adoc		\
	datacenter.cfg.adoc	\
	pveam.adoc		\
	ha-manager.adoc		\
	pve-copyright.adoc	\
	docinfo.xml

GEN_SCRIPTS=					\
	gen-datacenter.cfg.5-opts.pl		\
	gen-pct.conf.5-opts.pl			\
	gen-vm.conf.5-opts.pl			\
	gen-pve-firewall-cluster-opts.pl	\
	gen-pve-firewall-host-opts.pl		\
	gen-pve-firewall-macros-adoc.pl		\
	gen-pve-firewall-rules-opts.pl		\
	gen-pve-firewall-vm-opts.pl

VZDUMP_SOURCES=attributes.txt vzdump.adoc vzdump.1-synopsis.adoc
PVEAM_SOURCES=attributes.txt pveam.adoc pveam.1-synopsis.adoc
HA_SOURCES=attributes.txt ha-manager.1-synopsis.adoc ha-manager.adoc

SYSADMIN_SOURCES=			\
	getting-help.adoc		\
	pve-package-repos.adoc		\
	pve-installation.adoc		\
	system-software-updates.adoc	\
	sysadmin.adoc

PVE_ADMIN_GUIDE_SOURCES=		\
	datacenter.cfg.adoc		\
	datacenter.cfg.5-opts.adoc	\
	vm.conf.adoc			\
	vm.conf.5-opts.adoc		\
	pct.conf.adoc			\
	pct.conf.5-opts.adoc		\
	${SYSADMIN_SOURCES}		\
	pve-admin-guide.adoc		\
	pve-intro.adoc			\
	pmxcfs.adoc 			\
	pve-faq.adoc			\
	${PVE_FIREWALL_MAN8_SOURCES}	\
	${PVESM_MAN1_SOURCES}		\
	${PCT_MAN1_SOURCES}		\
	${PVECM_MAN1_SOURCES}		\
	${PVEUM_MAN1_SOURCES}		\
	${QM_MAN1_SOURCES}		\
	${QMRESTORE_MAN1_SOURCES}	\
	${PVEAM_SOURCES}		\
	${VZDUMP_SOURCES}		\
	${HA_SOURCES}			\
	images/cluster-nwdiag.svg	\
	images/node-nwdiag.svg		\
	pve-bibliography.adoc		\
	GFDL.adoc			\
	attributes.txt

ADOC_STDARG= -a icons -a data-uri -a "date=$(shell date)"
ADOC_MAN1_HTML_ARGS=-a "manvolnum=1" ${ADOC_STDARG} -a "revnumber=${DOCRELEASE}"
ADOC_MAN5_HTML_ARGS=-a "manvolnum=5" ${ADOC_STDARG} -a "revnumber=${DOCRELEASE}"
ADOC_MAN8_HTML_ARGS=-a "manvolnum=8" ${ADOC_STDARG} -a "revnumber=${DOCRELEASE}"

BROWSER?=xdg-open

all: pve-admin-guide.html

%-nwdiag.svg: %.nwdiag
	nwdiag -T svg $*.nwdiag -o $@;

%.1: %.adoc %.1-synopsis.adoc docinfo.xml attributes.txt
	a2x -a docinfo1 -a "manvolnum=1" -a "manversion=Release ${DOCRELEASE}" -f manpage $*.adoc
	test -n "$${NOVIEW}" || man -l $@

%.1.html: %.adoc %.1-synopsis.adoc docinfo.xml attributes.txt
	asciidoc ${ADOC_MAN1_HTML_ARGS} -o $@ $*.adoc
	test -n "$${NOVIEW}" || $(BROWSER) $@ &


%.8-synopsis.adoc:
	perl -e "use PVE::Service::$(subst -,_,$*);print PVE::Service::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.8: %.adoc %.8-synopsis.adoc docinfo.xml
	a2x -a docinfo1 -a "manvolnum=8" -a "manversion=Release ${DOCRELEASE}" -f manpage $*.adoc
	test -n "$${NOVIEW}" || man -l $@

%.8.html: %.adoc %.8-synopsis.adoc docinfo.xml
	asciidoc ${ADOC_MAN8_HTML_ARGS} -o $@ $*.adoc
	test -n "$${NOVIEW}" || $(BROWSER) $@ &

%.5.html: %.adoc %.5-opts.adoc docinfo.xml
	asciidoc ${ADOC_MAN5_HTML_ARGS} -o $@ $*.adoc
	test -n "$${NOVIEW}" || $(BROWSER) $@ &

index.html: index.adoc ${PVE_ADMIN_GUIDE_SOURCES}
	$(MAKE) NOVIEW=1 pve-admin-guide.pdf pve-admin-guide.html pve-admin-guide.epub
	$(MAKE) NOVIEW=1 pvecm.1.html qm.1.html qmrestore.1.html pct.1.html pveam.1.html pvesm.1.html pveum.1.html vzdump.1.html pve-firewall.8.html ha-manager.1.html datacenter.cfg.5.html vm.conf.5.html pct.conf.5.html
	asciidoc -a "date=$(shell date)" -a "revnumber=${DOCRELEASE}" index.adoc
	test -n "$${NOVIEW}" || $(BROWSER) index.html &

pve-admin-guide.html: ${PVE_ADMIN_GUIDE_SOURCES}
	asciidoc -a "revnumber=${DOCRELEASE}" -a "date=$(shell date)" pve-admin-guide.adoc
	test -n "$${NOVIEW}" || $(BROWSER) $@ &

pve-admin-guide.pdf: ${PVE_ADMIN_GUIDE_SOURCES} docinfo.xml pve-admin-guide-docinfo.xml
	grep ">Release ${DOCRELEASE}<" pve-admin-guide-docinfo.xml || (echo "wrong release in  pve-admin-guide-docinfo.xml" && false);
	a2x -a docinfo -a docinfo1 -f pdf -L --dblatex-opts "-P latex.output.revhistory=0" --dblatex-opts "-P latex.class.options=12pt" --dblatex-opts "-P doc.section.depth=2 -P toc.section.depth=2" pve-admin-guide.adoc
	test -n "$${NOVIEW}" || $(BROWSER) $@ &

pve-admin-guide.epub: ${PVE_ADMIN_GUIDE_SOURCES}
	a2x -f epub pve-admin-guide.adoc
	test -n "$${NOVIEW}" || $(BROWSER) $@ &

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}

.PHONY: deb
${DEB} deb:
	rm -rf build
	mkdir build
	rsync -a debian/ build/debian
	mkdir -p build/usr/share/${PACKAGE}
	mkdir -p build/usr/share/doc/${PACKAGE}
	echo "git clone git://git.proxmox.com/git/pve-docs.git\\ngit checkout ${GITVERSION}" > build/usr/share/doc/${PACKAGE}/SOURCE
	install -m 0644 ${DEB_SOURCES} build/usr/share/${PACKAGE}
	install -m 0755 ${GEN_SCRIPTS} build/usr/share/${PACKAGE}
	cd build; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

.PHONY: upload
upload: ${DEB}
	umount /pve/${DOCRELEASE}; mount /pve/${DOCRELEASE} -o rw
	mkdir -p /pve/${DOCRELEASE}/extra
	rm -f /pve/${DOCRELEASE}/extra/${PACKAGE}_*.deb
	rm -f /pve/${DOCRELEASE}/extra/Packages*
	cp ${DEB} /pve/${DOCRELEASE}/extra
	cd /pve/${DOCRELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${DOCRELEASE}; mount /pve/${DOCRELEASE} -o ro

update: clean
	rm -f *.5-opts.adoc .1-synopsis.adoc .8-synopsis.adoc
	make all

clean:
	rm -rf *~ *.html *.pdf *.epub *.tmp *.1 *.5 *.8 *.deb *.changes build

