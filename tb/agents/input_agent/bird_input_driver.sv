//------------------------------------------------------------------------------
// bird_input_driver.sv  -  drives fragments onto the BIRD input interface
//
// Per fragment: assert in_vld, present cfg + first payload byte (cfg sampled with
// first byte, Spec 2.3), then stream remaining payload bytes and the 2 CRC bytes,
// honoring in_rdy back-pressure each cycle.
//------------------------------------------------------------------------------
`ifndef BIRD_INPUT_DRIVER_SV
`define BIRD_INPUT_DRIVER_SV

class bird_input_driver extends uvm_driver #(bird_seq_item);
  `uvm_component_utils(bird_input_driver)

  virtual bird_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bird_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "vif not set for input driver")
  endfunction

  task run_phase(uvm_phase phase);
    // idle defaults
    vif.in_drv_cb.in_vld  <= 1'b0;
    vif.in_drv_cb.data_in <= '0;
    vif.in_drv_cb.cfg     <= '0;
    wait (vif.rst_n === 1'b1);

    forever begin
      seq_item_port.get_next_item(req);
      drive_fragment(req);
      seq_item_port.item_done();
    end
  endtask

  // Stream one fragment: payload bytes followed by CRC16 (2 bytes, MSB first).
  task drive_fragment(bird_seq_item tr);
    bit [7:0] stream[$];

    // optional idle gap (back-pressure / pacing exercise)
    repeat (tr.pre_delay) @(vif.in_drv_cb);

    foreach (tr.payload[i]) stream.push_back(tr.payload[i]);
    stream.push_back(tr.crc16[15:8]);
    stream.push_back(tr.crc16[7:0]);

    foreach (stream[i]) begin
      vif.in_drv_cb.in_vld  <= 1'b1;
      vif.in_drv_cb.data_in <= stream[i];
      vif.in_drv_cb.cfg     <= tr.get_cfg(); // stable for whole fragment
      // wait for accept (vld & rdy)
      do @(vif.in_drv_cb); while (vif.in_drv_cb.in_rdy !== 1'b1);
    end

    // de-assert after fragment
    vif.in_drv_cb.in_vld  <= 1'b0;
    vif.in_drv_cb.data_in <= '0;
  endtask

endclass

`endif // BIRD_INPUT_DRIVER_SV
