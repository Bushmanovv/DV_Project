//------------------------------------------------------------------------------
// bird_pkg.sv  -  compiles all BIRD UVM components in dependency order
//------------------------------------------------------------------------------
`ifndef BIRD_PKG_SV
`define BIRD_PKG_SV

package bird_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // transaction + sequences
  `include "sequences/bird_seq_item.sv"
  `include "sequences/bird_base_seq.sv"

  // input agent
  `include "agents/input_agent/bird_input_driver.sv"
  `include "agents/input_agent/bird_input_monitor.sv"
  `include "agents/input_agent/bird_input_agent.sv"

  // env
  `include "env/bird_coverage.sv"
  `include "env/bird_scoreboard.sv"
  `include "env/bird_env.sv"

  // tests
  `include "tests/bird_base_test.sv"

endpackage

`endif // BIRD_PKG_SV
