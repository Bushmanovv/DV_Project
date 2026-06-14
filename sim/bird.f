// -----------------------------------------------------------------------------
// bird.f  -  compile filelist for the BIRD verification environment
// Usage (Questa): vlog -f sim/bird.f
// Paths are relative to the repo root.
// -----------------------------------------------------------------------------

// include dirs
+incdir+tb
+incdir+tb/sequences
+incdir+tb/agents/input_agent
+incdir+tb/env
+incdir+tb/tests

// DUT (copy bird.sv from EDA Playground into rtl/)
rtl/bird.sv

// interface
tb/top/bird_if.sv

// UVM package (pulls in all components via `include)
tb/bird_pkg.sv

// testbench top
tb/top/tb_top.sv
