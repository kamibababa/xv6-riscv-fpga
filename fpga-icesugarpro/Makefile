OBJS =  clint.v plic.v rv32.v soc.v spi.v uart.v vma.v sdram.v

TOOLPREFIX = /opt/oss-cad-suite/bin/

PNRFLAGS = --25k --package CABGA256 --speed 6 --lpf ice_sugar_pro.lpf --freq 100

all:	build upload run

sim:	soc_tb.vcd

build:	soc.bit
pll.v:	
	$(TOOLPREFIX)ecppll -i 25 -o 32 -f pll.v

soc.json: $(OBJS) top.v pll.v firmware.hex
	$(TOOLPREFIX)yosys -p "synth_ecp5 -top top -json $@" $(OBJS) top.v  pll.v

soc_tb.vcd:	$(OBJS) firmware.hex
	$(TOOLPREFIX)iverilog -o soc_tb.out $(OBJS) soc_tb.v
	./soc_tb.out
	$(TOOLPREFIX)gtkwave soc_tb.vcd soc_tb.gtkw

soc_out.config: soc.json
	$(TOOLPREFIX)nextpnr-ecp5 $(PNRFLAGS) --json $< --textcfg $@

soc.bit: soc_out.config
	$(TOOLPREFIX)ecppack --svf soc.svf $< $@

upload:	soc.bit
	cp soc.bit /media/micha/iCELink/

run:	
	tio -b 115200 -m INLCRNL /dev/ttyACM0

clean:
	rm -f *.asc *.bin *.json *.vcd *.out *.svf *.config *.bit

.PHONY: all clean



