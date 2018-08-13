
all:

%.tmp.dot: %.tt pve_network_templates.tt
	tpage $*.tt >$*.tmp.dot

%.svg: %.tmp.dot
	dot $*.tmp.dot -T svg -o $*.svg


clean:
	rm -f *.tmp.dot
