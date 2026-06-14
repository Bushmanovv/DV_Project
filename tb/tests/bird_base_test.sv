//------------------------------------------------------------------------------
// bird_base_test.sv  -  base test + starter tests
//
// Base builds the env and provides a drain-time. Concrete tests select a
// sequence to run on the input sequencer. Select with +UVM_TESTNAME=<name>.
//------------------------------------------------------------------------------
`ifndef BIRD_BASE_TEST_SV
`define BIRD_BASE_TEST_SV

class bird_base_test extends uvm_test;
  `uvm_component_utils(bird_base_test)

  bird_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = bird_env::type_id::create("env", this);
  endfunction

  // Give outputs time to drain after the last fragment.
  task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 200ns);
  endtask

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass

// ---- A single local packet ----
class bird_local_basic_test extends bird_base_test;
  `uvm_component_utils(bird_local_basic_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  task run_phase(uvm_phase phase);
    bird_local_seq seq;
    super.run_phase(phase);
    phase.raise_objection(this);
    seq = bird_local_seq::type_id::create("seq");
    seq.start(env.in_agent.sqr);
    phase.drop_objection(this);
  endtask
endclass

// ---- A remote multi-fragment, out-of-order packet ----
class bird_remote_reorder_test extends bird_base_test;
  `uvm_component_utils(bird_remote_reorder_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  task run_phase(uvm_phase phase);
    bird_remote_seq seq;
    super.run_phase(phase);
    phase.raise_objection(this);
    seq = bird_remote_seq::type_id::create("seq");
    if (!seq.randomize() with { n_frags == 4; shuffle == 1; })
      `uvm_error(get_type_name(), "randomize failed")
    seq.start(env.in_agent.sqr);
    phase.drop_objection(this);
  endtask
endclass

`endif // BIRD_BASE_TEST_SV
