# also update debian/changelog
DOCRELEASE=4.2

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

VZDUMP_MAN1_SOURCES=			\
	vzdump.adoc 			\
	vzdump.1-synopsis.adoc		\
	vzdump.conf.5-opts.adoc		\
	${PVE_COMMON_DOC_SOURCES}

PVESUBSCRIPTION_MAN1_SOURCES=		\
	pvesubscription.adoc		\
	pvesubscription.1-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVECEPH_MAN1_SOURCES=			\
	pveceph.adoc 			\
	pveceph.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

PCT_MAN1_SOURCES=			\
	pct.adoc 			\
	pct.1-synopsis.adoc		\
	pct.conf.5-opts.adoc		\
	pct-network-opts.adoc		\
	pct-mountpoint-opts.adoc	\
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
	qm.conf.5-opts.adoc		\
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

PVEAM_MAN1_SOURCES=			\
	pveam.adoc 			\
	pveam.1-synopsis.adoc		\
	${PVE_COMMON_DOC_SOURCES}

HA_MANAGER_MAN1_SOURCES=		\
	ha-manager.adoc 		\
	ha-manager.1-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVE_HA_CRM_MAN8_SOURCES=		\
	pve-ha-crm.adoc			\
	pve-ha-crm.8-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVE_HA_LRM_MAN8_SOURCES=		\
	pve-ha-lrm.adoc			\
	pve-ha-lrm.8-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVESTATD_MAN8_SOURCES=			\
	pvestatd.adoc			\
	pvestatd.8-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVEDAEMON_MAN8_SOURCES=			\
	pvedaemon.adoc			\
	pvedaemon.8-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PVEPROXY_MAN8_SOURCES=			\
	pveproxy.adoc			\
	pveproxy.8-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

SPICEPROXY_MAN8_SOURCES=		\
	spiceproxy.adoc			\
	spiceproxy.8-synopsis.adoc	\
	${PVE_COMMON_DOC_SOURCES}

PMXCFS_MAN8_SOURCES=			\
	pmxcfs.adoc			\
	pmxcfs.8-cli.adoc		\
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

# asciidoc /etc/asciidoc/docbook-xsl/manpage.xsl skip REFERENCES section
# like footnotes, so we cannot use a2x. We use xmlto instead.
#A2MAN_COMMON=a2x -v -k -a docinfo1 -a "manversion=Release ${DOCRELEASE}" -f manpage
#A2MAN1=${A2MAN_COMMON} -a "manvolnum=1"
#A2MAN5=${A2MAN_COMMON} -a "manvolnum=5"
#A2MAN8=${A2MAN_COMMON} -a "manvolnum=8"

A2MAN_COMMON=asciidoc -dmanpage -bdocbook -a docinfo1

define A2MAN1
${A2MAN_COMMON} -a "manvolnum=1" -o $1.tmp.xml $1.adoc
xmlto -v man $1.tmp.xml
@rm -f $1.tmp.xml
endef

define A2MAN5
${A2MAN_COMMON} -a "manvolnum=5" -o $1.tmp.xml $1.adoc
xmlto -v man $1.tmp.xml 
@rm -f $1.tmp.xml
endef

define A2MAN8
${A2MAN_COMMON} -a "manvolnum=8" -o $1.tmp.xml $1.adoc
xmlto -v man $1.tmp.xml
@rm -f $1.tmp.xml
endef

pve-firewall.8: ${PVE_FIREWALL_MAN8_SOURCES}
	$(call A2MAN8,pve-firewall)
	test -n "$${NOVIEW}" || man -l $@

pvesm.1: ${PVESM_MAN1_SOURCES}
	$(call A2MAN1,pvesm)
	test -n "$${NOVIEW}" || man -l $@

pveceph.1: ${PVECEPH_MAN1_SOURCES}
	$(call A2MAN1,pveceph)
	test -n "$${NOVIEW}" || man -l $@

pct.1: ${PCT_MAN1_SOURCES}
	$(call A2MAN1,pct)
	test -n "$${NOVIEW}" || man -l $@

vzdump.1: ${VZDUMP_MAN1_SOURCES}
	$(call A2MAN1,vzdump)
	test -n "$${NOVIEW}" || man -l $@

pvesubscription.1: ${PVESUBSCRIPTION_MAN1_SOURCES}
	$(call A2MAN1,pvesubscription)
	test -n "$${NOVIEW}" || man -l $@

qm.1: ${QM_MAN1_SOURCES}
	$(call A2MAN1,qm)
	test -n "$${NOVIEW}" || man -l $@

qmrestore.1: ${QMRESTORE_MAN1_SOURCES}
	$(call A2MAN1,qmrestore)
	test -n "$${NOVIEW}" || man -l $@

pvecm.1: ${PVECM_MAN1_SOURCES}
	$(call A2MAN1,pvecm)
	test -n "$${NOVIEW}" || man -l $@

pveum.1: ${PVEUM_MAN1_SOURCES}
	$(call A2MAN1,pveum)
	test -n "$${NOVIEW}" || man -l $@

pveam.1: ${PVEAM_MAN1_SOURCES}
	$(call A2MAN1,pveam)
	test -n "$${NOVIEW}" || man -l $@

ha-manager.1: ${HA_MANAGER_MAN1_SOURCES}
	$(call A2MAN1,ha-manager)
	test -n "$${NOVIEW}" || man -l $@

pve-ha-crm.8: ${PVE_HA_CRM_MAN8_SOURCES}
	$(call A2MAN8,pve-ha-crm)
	test -n "$${NOVIEW}" || man -l $@

pve-ha-lrm.8: ${PVE_HA_LRM_MAN8_SOURCES}
	$(call A2MAN8,pve-ha-lrm)
	test -n "$${NOVIEW}" || man -l $@

pvestatd.8: ${PVESTATD_MAN8_SOURCES}
	$(call A2MAN8,pvestatd)
	test -n "$${NOVIEW}" || man -l $@

pvedaemon.8: ${PVEDAEMON_MAN8_SOURCES}
	$(call A2MAN8,pvedaemon)
	test -n "$${NOVIEW}" || man -l $@

pveproxy.8: ${PVEPROXY_MAN8_SOURCES}
	$(call A2MAN8,pveproxy)
	test -n "$${NOVIEW}" || man -l $@

spiceproxy.8: ${SPICEPROXY_MAN8_SOURCES}
	$(call A2MAN8,spiceproxy)
	test -n "$${NOVIEW}" || man -l $@

pmxcfs.8: ${PMXCFS_MAN8_SOURCES}
	$(call A2MAN8,pmxcfs)
	test -n "$${NOVIEW}" || man -l $@

qm.conf.5: ${QM_CONF_MAN5_SOURCES}

pct.conf.5: ${PCT_CONF_MAN5_SOURCES}

datacenter.cfg.5: ${DATACENTER_CONF_MAN5_SOURCES}

%.5: %.adoc %.5-opts.adoc ${PVE_COMMON_DOC_SOURCES}
	$(call A2MAN5,$*)
	test -n "$${NOVIEW}" || man -l $@

.PHONY: cleanup-docgen
cleanup-docgen:
	rm -f *.tmp.xml *.1 *.5 *.8 *.adoc attributes.txt docinfo.xml
