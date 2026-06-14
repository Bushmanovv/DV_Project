//------------------------------------------------------------------------------
// tb_top.sv  -  Top-level testbench module for BIRD
//
// Generates clock + reset, instantiates the DUT and the interface, hands the
// virtual interface to UVM config_db, and starts the test selected via +UVM_TESTNAME.
//------------------------------------------------------------------------------
`ifndef TB_TOP_SV
`define TB_TOP_SV

`timescale 1ns/1ps

module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import bird_pkg::*;

  // ---- Clock & reset ----
  logic clk;
  logic rst_n;

  localparam time CLK_PERIOD = 10ns;

  initial clk = 1'b0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // ---- Interface ----
  bird_if vif (.clk(clk), .rst_n(rst_n));

  // ---- Reset generation (active-low) ----
  initial begin
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
  end

  // ---- DUT instantiation ----
  // NOTE: confirm module name + ports against rtl/bird.sv (EDA Playground).
  bird dut (
    .clk         (clk),
    .rst_n       (rst_n),
    // input interface
    .in_vld      (vif.in_vld),
    .in_rdy      (vif.in_rdy),
    .data_in     (vif.data_in),
    .cfg         (vif.cfg),
    // local output
    .local_vld   (vif.local_vld),
    .local_rdy   (vif.local_rdy),
    .data_local  (vif.data_local),
    // remote output
    .remote_vld  (vif.remote_vld),
    .remote_rdy  (vif.remote_rdy),
    .data_remote (vif.data_remote),
    // status
    .drop_cnt    (vif.drop_cnt)
  );

  // ---- UVM run ----
  initial begin
    uvm_config_db#(virtual bird_if)::set(null, "*", "vif", vif);
    run_test();
  end

  // ---- Waveform dump ----
  initial begin
    $dumpfile("bird.vcd");
    $dumpvars(0, tb_top);
  end

endmodule

`endif // TB_TOP_SV
