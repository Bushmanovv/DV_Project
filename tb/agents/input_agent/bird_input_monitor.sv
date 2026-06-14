//------------------------------------------------------------------------------
// bird_input_monitor.sv  -  observes accepted input fragments
//
// Reconstructs a bird_seq_item per fragment from the bus (cfg sampled with the
// first accepted byte) and broadcasts it on analysis_port for the scoreboard
// reference model + coverage.
//------------------------------------------------------------------------------
`ifndef BIRD_INPUT_MONITOR_SV
`define BIRD_INPUT_MONITOR_SV

class bird_input_monitor extends uvm_monitor;
  `uvm_component_utils(bird_input_monitor)

  virtual bird_if vif;
  uvm_analysis_port #(bird_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bird_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "vif not set for input monitor")
  endfunction

  task run_phase(uvm_phase phase);
    wait (vif.rst_n === 1'b1);
    forever collect_fragment();
  endtask

  // A fragment = PAYLOAD_LEN payload bytes + 2 CRC bytes, all on accepted beats.
  task collect_fragment();
    bird_seq_item tr;
    bit [31:0]    cfg_s;
    bit [7:0]     bytes[$];
    int           total;

    // wait for first accepted beat
    do @(vif.in_mon_cb); while (!(vif.in_mon_cb.in_vld && vif.in_mon_cb.in_rdy));

    cfg_s = vif.in_mon_cb.cfg;             // cfg sampled with first byte (Spec 2.3)
    tr = bird_seq_item::type_id::create("mon_tr");
    tr.set_cfg(cfg_s);
    bytes.push_back(vif.in_mon_cb.data_in);

    total = tr.payload_len + 2;            // payload + CRC16; len from cfg
    while (bytes.size() < total) begin
      do @(vif.in_mon_cb); while (!(vif.in_mon_cb.in_vld && vif.in_mon_cb.in_rdy));
      bytes.push_back(vif.in_mon_cb.data_in);
    end

    tr.payload = new[tr.payload_len];
    foreach (tr.payload[i]) tr.payload[i] = bytes[i];
    tr.crc16 = {bytes[total-2], bytes[total-1]};

    `uvm_info(get_type_name(),
      $sformatf("INPUT frag seq=%0d frag=%0d len=%0d %s",
                tr.seq_num, tr.frag_num, tr.payload_len,
                tr.traffic_type ? "REMOTE" : "LOCAL"), UVM_HIGH)
    ap.write(tr);
  endtask

endclass

`endif // BIRD_INPUT_MONITOR_SV
