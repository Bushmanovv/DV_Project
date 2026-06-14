//------------------------------------------------------------------------------
// bird_scoreboard.sv  -  reference model + checker (SKELETON)
//
// Receives observed input fragments, local outputs and remote outputs, runs a
// reference model of BIRD, and compares predicted vs actual outputs.
//
// >>> THIS IS THE MAIN PIECE OF REMAINING WORK (the ~80%). <<<
// The reference-model TODOs below implement Spec 6-9 behavior.
//------------------------------------------------------------------------------
`ifndef BIRD_SCOREBOARD_SV
`define BIRD_SCOREBOARD_SV

`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_local)
`uvm_analysis_imp_decl(_remote)

class bird_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(bird_scoreboard)

  uvm_analysis_imp_in     #(bird_seq_item, bird_scoreboard) in_imp;
  uvm_analysis_imp_local  #(bird_seq_item, bird_scoreboard) local_imp;
  uvm_analysis_imp_remote #(bird_seq_item, bird_scoreboard) remote_imp;

  // running tallies for end-of-test report
  int unsigned n_local_ok, n_remote_ok, n_drops_pred, n_mismatch;

  // ---- reference-model state (remote accumulation) ----
  // TODO: model "one packet accumulated at a time", indexed by frag_num.
  protected bit [7:0] frag_buf[int][$];   // frag_num -> payload bytes
  protected bit [4:0] cur_seq;            // SEQ_NUM being accumulated (0 = idle)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    in_imp     = new("in_imp", this);
    local_imp  = new("local_imp", this);
    remote_imp = new("remote_imp", this);
  endfunction

  // ---- Observed INPUT fragment -> drive the reference model ----
  function void write_in(bird_seq_item tr);
    // TODO (Spec 8.1): drop checks
    //   seq_num==0, frag_num==0, payload_len out of range, reserved!=0,
    //   mismatched seq during accumulation, missing fragment, restart while
    //   incomplete  => predict drop (n_drops_pred++, drop_cnt += 1) and flush.
    // TODO (Spec 6): if local -> expect data_local == payload, CRC unchanged.
    // TODO (Spec 7): if remote -> buffer by frag_num; when complete, reorder,
    //   concatenate, recompute CRC16 -> push to expected-remote queue.
    `uvm_info(get_type_name(),
      $sformatf("ref model saw input seq=%0d frag=%0d", tr.seq_num, tr.frag_num),
      UVM_HIGH)
  endfunction

  // ---- Observed LOCAL output -> compare against prediction ----
  function void write_local(bird_seq_item tr);
    // TODO: pop expected-local queue, compare payload + CRC; count ok/mismatch.
  endfunction

  // ---- Observed REMOTE output -> compare against prediction ----
  function void write_remote(bird_seq_item tr);
    // TODO: pop expected-remote queue, compare merged payload + regenerated CRC.
  endfunction

  // ---- End-of-test reporting ----
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf(
      "\n==== BIRD SCOREBOARD SUMMARY ====\n  local OK   : %0d\n  remote OK  : %0d\n  drops pred : %0d\n  MISMATCHES : %0d\n=================================",
      n_local_ok, n_remote_ok, n_drops_pred, n_mismatch), UVM_NONE)
    if (n_mismatch != 0)
      `uvm_error(get_type_name(), $sformatf("%0d output mismatch(es)", n_mismatch))
  endfunction

endclass

`endif // BIRD_SCOREBOARD_SV
