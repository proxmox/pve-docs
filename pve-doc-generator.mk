# also update debian/changelog
DOCRELEASE=4.1

DGDIR?=/usr/share/pve-doc-generator

all:

PVE_FIREWALL_MAN8_SOURCES=		\
	pve-firewall.adoc 		\
	pve-firewall.8-synopsis.adoc 	\
	pve-firewall-cluster-opts.adoc 	\
	pve-firewall-host-opts.adoc 	\
	pve-firewall-vm-opts.adoc 	\
	pve-firewall-rules-opts.adoc	\
	pve-firewall-macros.adoc	\
	attributes.txt 			\
	docinfo.xml

attributes.txt docinfo.xml:
	cp ${DGDIR}/$@ $@.tmp
	mv $@.tmp $@

%-opts.adoc: ${DGDIR}/gen-%-opts.pl
	$< >$@.tmp
	mv $@.tmp $@

%.adoc: ${DGDIR}/gen-%-adoc.pl
	$< >$@.tmp
	mv $@.tmp $@

%.1-synopsis.adoc:
	perl -I. -e "use PVE::CLI::$(subst -,_,$*);print PVE::CLI::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.8-synopsis.adoc:
	perl -I. -e "use PVE::Service::$(subst -,_,$*);print PVE::Service::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.adoc: ${DGDIR}/%.adoc
	cp $< $@.tmp
	mv $@.tmp $@

pve-firewall.8: ${PVE_FIREWALL_MAN8_SOURCES}
	a2x -a docinfo1 -a "manvolnum=8" -a "manversion=Release ${DOCRELEASE}" -f manpage pve-firewall.adoc
	test -n "$${NOVIEW}" || man -l $@


.PHONY: cleanup-docgen
cleanup-docgen:
	rm -f *.1 *.8 *.adoc attributes.txt docinfo.xml
