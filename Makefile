RELEASE=4.1

PVESM_SOURCES=attributes.txt pvesm.adoc pvesm.1-synopsis.adoc $(shell ls pve-storage-*.adoc)
PVEUM_SOURCES=attributes.txt pveum.adoc pveum.1-synopsis.adoc
VZDUMP_SOURCES=attributes.txt vzdump.adoc vzdump.1-synopsis.adoc
PVEFW_SOURCES=attributes.txt pve-firewall.adoc pve-firewall.8-synopsis.adoc
QM_SOURCES=attributes.txt qm.adoc qm.1-synopsis.adoc
PCT_SOURCES=attributes.txt pct.adoc pct.1-synopsis.adoc

PVE_ADMIN_GUIDE_SOURCES=		\
	sysadmin.adoc			\
	pve-admin-guide.adoc		\
	pve-intro.adoc			\
	pmxcfs.adoc 			\
	pve-faq.adoc			\
	${QM_SOURCES}			\
	${PCT_SOURCES}			\
	${PVEFW_SOURCES}		\
	${PVEUM_SOURCES}		\
	${PVESM_SOURCES}		\
	${VZDUMP_SOURCES}		\
	images/cluster-nwdiag.svg	\
	images/node-nwdiag.svg		\
	pve-bibliography.adoc		\
	GFDL.adoc			\
	attributes.txt

ADOC_STDARG= -a icons -a data-uri -a "date=$(shell date)"
ADOC_MAN1_HTML_ARGS=-a "manvolnum=1" ${ADOC_STDARG}
ADOC_MAN8_HTML_ARGS=-a "manvolnum=8" ${ADOC_STDARG}

%-nwdiag.svg: %.nwdiag
	nwdiag -T svg $*.nwdiag -o $@;

%.1-synopsis.adoc:
	perl -e "use PVE::CLI::$(subst -,_,$*);print PVE::CLI::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.1: %.adoc %.1-synopsis.adoc docinfo.xml
	a2x -a docinfo1 -a "manvolnum=1" -f manpage $*.adoc
	test -z "$${NOVIEW}" && man -l $@ 

%.1.html: %.adoc %.1-synopsis.adoc docinfo.xml
	asciidoc ${ADOC_MAN1_HTML_ARGS} -o $@ $*.adoc
	test -z "$${NOVIEW}" && iceweasel $@ &


%.8-synopsis.adoc:
	perl -e "use PVE::Service::$(subst -,_,$*);print PVE::Service::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.8: %.adoc %.8-synopsis.adoc docinfo.xml
	a2x -a docinfo1 -a "manvolnum=1" -f manpage $*.adoc
	test -z "$${NOVIEW}" && man -l $@ 

%.8.html: %.adoc %.8-synopsis.adoc docinfo.xml
	asciidoc ${ADOC_MAN8_HTML_ARGS} -o $@ $*.adoc
	test -z "$${NOVIEW}" && iceweasel $@ &


all: pve-admin-guide.html

index.html: index.adoc ${PVE_ADMIN_GUIDE_SOURCES}
	$(MAKE) NOVIEW=1 pve-admin-guide.pdf pve-admin-guide.html pve-admin-guide.epub
	$(MAKE) NOVIEW=1 qm.1.html pct.1.html pvesm.1.html pveum.1.html vzdump.1.html pve-firewall.8.html
	asciidoc -a "date=$(shell date)" index.adoc 
	iceweasel index.html &

pve-admin-guide.html: ${PVE_ADMIN_GUIDE_SOURCES}
	asciidoc -a "revnumber=${RELEASE}" -a "date=$(shell date)" pve-admin-guide.adoc 
	test -z "$${NOVIEW}" && iceweasel $@ &

pve-admin-guide.pdf: ${PVE_ADMIN_GUIDE_SOURCES} docinfo.xml pve-admin-guide-docinfo.xml
	a2x -a docinfo -a docinfo1 -f pdf -L --dblatex-opts "-P latex.output.revhistory=0" pve-admin-guide.adoc
	test -z "$${NOVIEW}" && iceweasel $@ &

pve-admin-guide.epub: ${PVE_ADMIN_GUIDE_SOURCES}
	a2x -f epub pve-admin-guide.adoc
	test -z "$${NOVIEW}" && iceweasel $@ &


clean:
	rm -rf *~ *.html *.pdf *.epub *.1 *.8
