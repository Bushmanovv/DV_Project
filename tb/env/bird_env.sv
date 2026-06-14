//------------------------------------------------------------------------------
// bird_env.sv  -  top-level UVM environment
//
// Instantiates the input agent, scoreboard and coverage, and wires the analysis
// connections. Add local_agent / remote_agent (passive monitors) here once their
// monitors exist, and connect them to the scoreboard's local/remote imps.
//------------------------------------------------------------------------------
`ifndef BIRD_ENV_SV
`define BIRD_ENV_SV

class bird_env extends uvm_env;
  `uvm_component_utils(bird_env)

  bird_input_agent in_agent;
  bird_scoreboard  sb;
  bird_coverage    cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_agent = bird_input_agent::type_id::create("in_agent", this);
    sb       = bird_scoreboard ::type_id::create("sb", this);
    cov      = bird_coverage   ::type_id::create("cov", this);
    // TODO: create local_agent + remote_agent (UVM_PASSIVE) monitors here.
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    in_agent.ap.connect(sb.in_imp);
    in_agent.ap.connect(cov.analysis_export);
    // TODO: local_agent.ap.connect(sb.local_imp);
    // TODO: remote_agent.ap.connect(sb.remote_imp);
  endfunction

endclass

`endif // BIRD_ENV_SV
