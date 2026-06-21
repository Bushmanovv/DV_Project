// Smoke compile file list - compiles the full environment so the default
// (local_basic_test) can run as a quick sanity check.
+incdir+./verif/cfg
+incdir+./verif/env
+incdir+./verif/seq
+incdir+./verif/tests
+incdir+./verif/if

./design/bird.v

./verif/if/bird_if.sv
./verif/env/bird_pkg.sv
./verif/tb/bird_test.sv
./verif/tb/bird_tb.sv
