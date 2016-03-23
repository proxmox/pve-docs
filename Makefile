RELEASE=4.1

PVESM_SOURCES=attributes.txt pvesm.adoc pvesm.1-synopsis.adoc $(shell ls pve-storage-*.adoc)
PVEUM_SOURCES=attributes.txt pveum.adoc pveum.1-synopsis.adoc
VZDUMP_SOURCES=attributes.txt vzdump.adoc vzdump.1-synopsis.adoc
PVEFW_SOURCES=attributes.txt pve-firewall.adoc pve-firewall.8-synopsis.adoc
QM_SOURCES=attributes.txt qm.adoc qm.1-synopsis.adoc
PCT_SOURCES=attributes.txt pct.adoc pct.1-synopsis.adoc
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
	${SYSADMIN_SOURCES}		\
	pve-admin-guide.adoc		\
	pve-intro.adoc			\
	pmxcfs.adoc 			\
	pve-faq.adoc			\
	${QM_SOURCES}			\
	${PCT_SOURCES}			\
	${PVEAM_SOURCES}		\
	${PVEFW_SOURCES}		\
	${PVEUM_SOURCES}		\
	${PVESM_SOURCES}		\
	${VZDUMP_SOURCES}		\
	${HA_SOURCES}			\
	images/cluster-nwdiag.svg	\
	images/node-nwdiag.svg		\
	pve-bibliography.adoc		\
	GFDL.adoc			\
	attributes.txt

ADOC_STDARG= -a icons -a data-uri -a "date=$(shell date)"
ADOC_MAN1_HTML_ARGS=-a "manvolnum=1" ${ADOC_STDARG} -a "revnumber=${RELEASE}"
ADOC_MAN5_HTML_ARGS=-a "manvolnum=5" ${ADOC_STDARG} -a "revnumber=${RELEASE}"
ADOC_MAN8_HTML_ARGS=-a "manvolnum=8" ${ADOC_STDARG} -a "revnumber=${RELEASE}"

BROWSER?=xdg-open

all: pve-admin-guide.html

%-nwdiag.svg: %.nwdiag
	nwdiag -T svg $*.nwdiag -o $@;

%.1-synopsis.adoc:
	perl -e "use PVE::CLI::$(subst -,_,$*);print PVE::CLI::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.1: %.adoc %.1-synopsis.adoc docinfo.xml
	a2x -a docinfo1 -a "manvolnum=1" -a "manversion=Release ${RELEASE}" -f manpage $*.adoc
	test -z "$${NOVIEW}" && man -l $@

%.1.html: %.adoc %.1-synopsis.adoc docinfo.xml
	asciidoc ${ADOC_MAN1_HTML_ARGS} -o $@ $*.adoc
	test -z "$${NOVIEW}" && $(BROWSER) $@ &


%.8-synopsis.adoc:
	perl -e "use PVE::Service::$(subst -,_,$*);print PVE::Service::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.8: %.adoc %.8-synopsis.adoc docinfo.xml
	a2x -a docinfo1 -a "manvolnum=8" -a "manversion=Release ${RELEASE}" -f manpage $*.adoc
	test -z "$${NOVIEW}" && man -l $@

%.8.html: %.adoc %.8-synopsis.adoc docinfo.xml
	asciidoc ${ADOC_MAN8_HTML_ARGS} -o $@ $*.adoc
	test -z "$${NOVIEW}" && $(BROWSER) $@ &

datacenter.cfg.5-opts.adoc:
	./gen-datacenter-cfg-opts-adoc.pl >$@.tmp
	mv $@.tmp $@

vm.conf.5-opts.adoc:
	./gen-vm-conf-opts-adoc.pl >$@.tmp
	mv $@.tmp $@

%.5: %.adoc %.5-opts.adoc docinfo.xml
	a2x -a docinfo1 -a "manvolnum=5" -a "manversion=Release ${RELEASE}" -f manpage $*.adoc
	test -z "$${NOVIEW}" && man -l $@

%.5.html: %.adoc %.5-opts.adoc docinfo.xml
	asciidoc ${ADOC_MAN5_HTML_ARGS} -o $@ $*.adoc
	test -z "$${NOVIEW}" && $(BROWSER) $@ &

index.html: index.adoc ${PVE_ADMIN_GUIDE_SOURCES}
	$(MAKE) NOVIEW=1 pve-admin-guide.pdf pve-admin-guide.html pve-admin-guide.epub
	$(MAKE) NOVIEW=1 qm.1.html pct.1.html pveam.1.html pvesm.1.html pveum.1.html vzdump.1.html pve-firewall.8.html ha-manager.1.html datacenter.cfg.5.html vm.conf.5.html
	asciidoc -a "date=$(shell date)" -a "revnumber=${RELEASE}" index.adoc
	$(BROWSER) index.html &

pve-admin-guide.html: ${PVE_ADMIN_GUIDE_SOURCES}
	asciidoc -a "revnumber=${RELEASE}" -a "date=$(shell date)" pve-admin-guide.adoc
	test -z "$${NOVIEW}" && $(BROWSER) $@ &

pve-admin-guide.pdf: ${PVE_ADMIN_GUIDE_SOURCES} docinfo.xml pve-admin-guide-docinfo.xml
	grep ">Release ${RELEASE}<" pve-admin-guide-docinfo.xml || (echo "wrong release in  pve-admin-guide-docinfo.xml" && false);
	a2x -a docinfo -a docinfo1 -f pdf -L --dblatex-opts "-P latex.output.revhistory=0" --dblatex-opts "-P latex.class.options=12pt" pve-admin-guide.adoc
	test -z "$${NOVIEW}" && $(BROWSER) $@ &

pve-admin-guide.epub: ${PVE_ADMIN_GUIDE_SOURCES}
	a2x -f epub pve-admin-guide.adoc
	test -z "$${NOVIEW}" && $(BROWSER) $@ &

update: clean
	rm -f *.5-opts.adoc .1-synopsis.adoc .8-synopsis.adoc
	make all

clean:
	rm -rf *~ *.html *.pdf *.epub *.tmp *.1 *.5 *.8
