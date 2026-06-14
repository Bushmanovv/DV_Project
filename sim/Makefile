# ==============================================================================
# BIRD verification - Questa/ModelSim simulation Makefile
# Run from repo root:  make -C sim <target>   (or cd sim && make <target>)
# Override the test:    make run TEST=bird_remote_reorder_test
# ==============================================================================

# --- config ---------------------------------------------------------------
TOP        ?= tb_top
TEST       ?= bird_local_basic_test
SEED       ?= random
UVM_VERBOSITY ?= UVM_MEDIUM

FILELIST   = bird.f
WORK       = work
ROOT       = ..

VLOG_FLAGS = -sv +acc -timescale 1ns/1ps
VSIM_FLAGS = -c -do "run -all; quit -f"
UVM_FLAGS  = +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(UVM_VERBOSITY)

# --- targets --------------------------------------------------------------
.PHONY: all comp run clean dut-check cov regress help

all: run

## comp : compile DUT + TB
comp: dut-check
	cd $(ROOT) && vlib sim/$(WORK) && vmap work sim/$(WORK)
	cd $(ROOT) && vlog $(VLOG_FLAGS) -f sim/$(FILELIST)

## run : compile then simulate TEST
run: comp
	cd $(ROOT) && vsim $(VSIM_FLAGS) $(VLOG_LIB) $(TOP) $(UVM_FLAGS) -sv_seed $(SEED)

## cov : run with coverage collection (code + functional)
cov: dut-check
	cd $(ROOT) && vlib sim/$(WORK) && vmap work sim/$(WORK)
	cd $(ROOT) && vlog $(VLOG_FLAGS) -cover bcefsx -f sim/$(FILELIST)
	cd $(ROOT) && vsim $(VSIM_FLAGS) -coverage $(TOP) $(UVM_FLAGS) -sv_seed $(SEED) \
		-do "coverage save -onexit coverage/$(TEST).ucdb; run -all; quit -f"

## regress : run the core directed tests back to back
regress:
	@for t in bird_local_basic_test bird_remote_reorder_test ; do \
		$(MAKE) run TEST=$$t SEED=$$RANDOM || exit 1 ; \
	done

## dut-check : fail early if the DUT was not copied in
dut-check:
	@test -f $(ROOT)/rtl/bird.sv || \
	 (echo "ERROR: rtl/bird.sv missing - copy the DUT from EDA Playground (https://www.edaplayground.com/x/UtWv)"; exit 1)

## clean : remove build artifacts
clean:
	rm -rf $(WORK) transcript vsim.wlf *.vcd *.ucdb $(ROOT)/bird.vcd

help:
	@grep -E '^## ' Makefile | sed 's/## //'
