
TT_SOURCES=					\
	default-network-setup-bond.tt		\
	default-network-setup-routed.tt		\
	default-network-setup-bridge.tt

all: $(TT_SOURCES:.tt=.svg)

%.tmp.dot: %.tt pve_network_templates.tt
	tpage $*.tt >$*.tmp.dot

%.svg: %.tmp.dot
	dot $*.tmp.dot -T svg -o $*.svg

update:
	rm -f $(TT_SOURCES:.tt=.svg)
	make $(TT_SOURCES:.tt=.svg)

install: $(TT_SOURCES:.tt=.svg)
	install -d -m 0755 $(DESTDIR)/usr/share/pve-docs/images
	install -m 0644 $(TT_SOURCES:.tt=.svg) $(DESTDIR)/usr/share/pve-docs/images

clean:
	rm -f *.tmp.dot
