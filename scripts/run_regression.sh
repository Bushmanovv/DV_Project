#!/bin/sh
# ============================================================
# run_regression.sh  -  Student D
# Full BIRD regression with code + functional coverage.
# Run from the project root on a machine with Synopsys VCS.
# ============================================================
set -e

COV="-cm line+cond+fsm+tgl+branch+assert"
CMDIR="simv.cm"

TESTS="local_basic_test \
       remote_basic_test \
       remote_inorder_test \
       remote_reorder_test \
       remote_crc_test \
       invalid_cfg_test \
       remote_protocol_test \
       drop_count_test \
       drop_wrap_test"

mkdir -p coverage/code_coverage_report coverage/functional_coverage_report logs

echo "==== Compiling ===="
vcs -sverilog -full64 -debug_access+all $COV -cm_dir $CMDIR \
    -f vcs.f -l logs/compile.log

echo "==== Running tests ===="
for t in $TESTS; do
  echo "---- $t ----"
  ./simv +TEST=$t $COV -cm_dir $CMDIR -cm_name $t -l logs/sim_$t.log
done

echo "==== Generating merged coverage report ===="
urg -dir $CMDIR -format both \
    -report coverage/merged_report \
    -log logs/urg.log

echo ""
echo "==== Per-test PASS/FAIL summary ===="
grep -hE "REPORT:|MISMATCH" logs/sim_*.log || true

echo ""
echo "Coverage report: coverage/merged_report/dashboard.html"
