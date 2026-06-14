//------------------------------------------------------------------------------
// bird_input_agent.sv  -  active agent for the BIRD input interface
//
// Bundles sequencer + driver + monitor. UVM_ACTIVE by default (drives stimulus);
// set to UVM_PASSIVE to only monitor. Template for local/remote output agents.
//------------------------------------------------------------------------------
`ifndef BIRD_INPUT_AGENT_SV
`define BIRD_INPUT_AGENT_SV

typedef uvm_sequencer #(bird_seq_item) bird_input_sequencer;

class bird_input_agent extends uvm_agent;
  `uvm_component_utils(bird_input_agent)

  bird_input_sequencer sqr;
  bird_input_driver    drv;
  bird_input_monitor   mon;

  uvm_analysis_port #(bird_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = bird_input_monitor::type_id::create("mon", this);
    ap  = mon.ap;
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = bird_input_sequencer::type_id::create("sqr", this);
      drv = bird_input_driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass

`endif // BIRD_INPUT_AGENT_SV
