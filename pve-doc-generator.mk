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

PCT_CONF_MAN5_SOURCES=			\
	pct.conf.adoc 			\
	pct.conf.5-opts.adoc		\
	${PVE_COMMON_DOC_SOURCES}

DATACENTER_CONF_MAN5_SOURCES=		\
	datacenter.cfg.adoc 		\
	datacenter.cfg.5-opts.adoc	\
	${PVE_COMMON_DOC_SOURCES}

QM_MAN1_SOURCES=			\
	qm.adoc 			\
	qm.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

QM_CONF_MAN5_SOURCES=			\
	qm.conf.adoc 			\
	qm.conf.5-opts.adoc		\
	${PVE_COMMON_DOC_SOURCES}

QMRESTORE_MAN1_SOURCES=			\
	qmrestore.adoc 			\
	qmrestore.1-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVEUM_MAN1_SOURCES=			\
	pveum.adoc 			\
	pveum.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

HA_MANAGER_MAN1_SOURCES=			\
	ha-manager.adoc 			\
	ha-manager.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

PVE_HA_CRM_MAN8_SOURCES=			\
	pve-ha-crm.adoc				\
	pve-ha-crm.8-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

PVE_HA_LRM_MAN8_SOURCES=			\
	pve-ha-lrm.adoc				\
	pve-ha-lrm.8-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

PVESTATD_MAN8_SOURCES=			\
	pvestatd.adoc			\
	pvestatd.8-synopsis.adoc	\
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

A2X_MAN_COMMON_OPTIONS=-a docinfo1 -a "manversion=Release ${DOCRELEASE}" -f manpage
A2X_MAN1_OPTIONS=${A2X_MAN_COMMON_OPTIONS} -a "manvolnum=1"
A2X_MAN5_OPTIONS=${A2X_MAN_COMMON_OPTIONS} -a "manvolnum=5"
A2X_MAN8_OPTIONS=${A2X_MAN_COMMON_OPTIONS} -a "manvolnum=8"

pve-firewall.8: ${PVE_FIREWALL_MAN8_SOURCES}
	a2x ${A2X_MAN8_OPTIONS} pve-firewall.adoc
	test -n "$${NOVIEW}" || man -l $@

pvesm.1: ${PVESM_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} pvesm.adoc
	test -n "$${NOVIEW}" || man -l $@

pct.1: ${PCT_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} pct.adoc
	test -n "$${NOVIEW}" || man -l $@

qm.1: ${QM_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} qm.adoc
	test -n "$${NOVIEW}" || man -l $@

qmrestore.1: ${QMRESTORE_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} qmrestore.adoc
	test -n "$${NOVIEW}" || man -l $@

pvecm.1: ${PVECM_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} pvecm.adoc
	test -n "$${NOVIEW}" || man -l $@

pveum.1: ${PVEUM_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} pveum.adoc
	test -n "$${NOVIEW}" || man -l $@

ha-manager.1: ${HA_MANAGER_MAN1_SOURCES}
	a2x ${A2X_MAN1_OPTIONS} ha-manager.adoc
	test -n "$${NOVIEW}" || man -l $@

pve-ha-crm.8: ${PVE_HA_CRM_MAN8_SOURCES}
	a2x ${A2X_MAN8_OPTIONS} manpage pve-ha-crm.adoc
	test -n "$${NOVIEW}" || man -l $@

pve-ha-lrm.8: ${PVE_HA_LRM_MAN8_SOURCES}
	a2x ${A2X_MAN8_OPTIONS} pve-ha-lrm.adoc
	test -n "$${NOVIEW}" || man -l $@

pvestatd.8: ${PVESTATD_MAN8_SOURCES}
	a2x ${A2X_MAN8_OPTIONS} pvestatd.adoc
	test -n "$${NOVIEW}" || man -l $@

qm.conf.5: ${QM_CONF_MAN5_SOURCES}

pct.conf.5: ${PCT_CONF_MAN5_SOURCES}

datacenter.cfg.5: ${DATACENTER_CONF_MAN5_SOURCES}

%.5: %.adoc %.5-opts.adoc ${PVE_COMMON_DOC_SOURCES}
	a2x ${A2X_MAN5_OPTIONS} $*.adoc
	test -n "$${NOVIEW}" || man -l $@

.PHONY: cleanup-docgen
cleanup-docgen:
	rm -f *.1 *.5 *.8 *.adoc attributes.txt docinfo.xml
