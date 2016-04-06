# also update debian/changelog
DOCRELEASE=4.1

DGDIR?=/usr/share/pve-doc-generator

all:

PVE_COMMON_DOC_SOURCES=			\
	attributes.txt 			\
	pve-copyright.adoc		\
	docinfo.xml

PVECM_MAN1_SOURCES=			\
	pvecm.adoc			\
	pvecm.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

PVE_FIREWALL_MAN8_SOURCES=		\
	pve-firewall.adoc 		\
	pve-firewall.8-synopsis.adoc 	\
	pve-firewall-cluster-opts.adoc 	\
	pve-firewall-host-opts.adoc 	\
	pve-firewall-vm-opts.adoc 	\
	pve-firewall-rules-opts.adoc	\
	pve-firewall-macros.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVESM_MAN1_SOURCES=			\
	pvesm.adoc			\
	pvesm.1-synopsis.adoc		\
	pve-storage-dir.adoc		\
	pve-storage-glusterfs.adoc	\
	pve-storage-iscsi.adoc		\
	pve-storage-iscsidirect.adoc	\
	pve-storage-lvm.adoc		\
	pve-storage-nfs.adoc		\
	pve-storage-rbd.adoc		\
	pve-storage-zfspool.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PCT_MAN1_SOURCES=			\
	pct.adoc 			\
	pct.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

attributes.txt docinfo.xml:
	cp ${DGDIR}/$@ $@.tmp
	mv $@.tmp $@

%-opts.adoc: ${DGDIR}/gen-%-opts.pl
	${DGDIR}/gen-$*-opts.pl >$@.tmp
	mv $@.tmp $@

%.adoc: ${DGDIR}/gen-%-adoc.pl
	${DGDIR}/gen-$*-adoc.pl >$@.tmp
	mv $@.tmp $@

%.1-synopsis.adoc:
	perl -I. -e "use PVE::CLI::$(subst -,_,$*);print PVE::CLI::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

%.8-synopsis.adoc:
	perl -I. -e "use PVE::Service::$(subst -,_,$*);print PVE::Service::$(subst -,_,$*)->generate_asciidoc_synopsys();" > $@.tmp
	mv $@.tmp $@

ifneq (${DGDIR},.)
%.adoc: ${DGDIR}/%.adoc
	cp $< $@.tmp
	mv $@.tmp $@
endif

pve-firewall.8: ${PVE_FIREWALL_MAN8_SOURCES}
	a2x -a docinfo1 -a "manvolnum=8" -a "manversion=Release ${DOCRELEASE}" -f manpage pve-firewall.adoc
	test -n "$${NOVIEW}" || man -l $@

pvesm.1: ${PVESM_MAN1_SOURCES}
	a2x -a docinfo1 -a "manvolnum=1" -a "manversion=Release ${DOCRELEASE}" -f manpage pvesm.adoc
	test -n "$${NOVIEW}" || man -l $@

pct.1: ${PCT_MAN1_SOURCES}
	a2x -a docinfo1 -a "manvolnum=1" -a "manversion=Release ${DOCRELEASE}" -f manpage pct.adoc
	test -n "$${NOVIEW}" || man -l $@

pvecm.1: ${PVECM_MAN1_SOURCES}
	a2x -a docinfo1 -a "manvolnum=1" -a "manversion=Release ${DOCRELEASE}" -f manpage pvecm.adoc
	test -n "$${NOVIEW}" || man -l $@

%.5: %.adoc %.5-opts.adoc ${PVE_COMMON_DOC_SOURCES}
	a2x -a docinfo1 -a "manvolnum=5" -a "manversion=Release ${DOCRELEASE}" -f manpage $*.adoc
	test -n "$${NOVIEW}" || man -l $@

.PHONY: cleanup-docgen
cleanup-docgen:
	rm -f *.1 *.8 *.adoc attributes.txt docinfo.xml
