
PPMS= 			\
pve-grub-menu		\
pve-installation	\
pve-select-location	\
pve-select-target-disk	\
pve-set-password	\
pve-setup-network

all: $(addsuffix .png, ${PPMS})

%.png: %.ppm
	convert $< -bordercolor black -border 10x10 $@

update:
	rm -f $(addsuffix .png, ${PPMS})
	$(MAKE)
