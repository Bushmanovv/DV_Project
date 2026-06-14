//------------------------------------------------------------------------------
// bird_if.sv  -  BIRD DUT interface + clocking blocks
//
// Signal names/widths follow docs/BIRD_Specification.pdf (Section 4).
// NOTE: verify these against the actual rtl/bird.sv from EDA Playground and
//       rename here if the DUT differs.
//------------------------------------------------------------------------------
`ifndef BIRD_IF_SV
`define BIRD_IF_SV

interface bird_if (input logic clk, input logic rst_n);

  // ---- Input interface (Producer -> BIRD) ----
  logic        in_vld;
  logic        in_rdy;
  logic [7:0]  data_in;
  logic [31:0] cfg;

  // ---- Local output interface ----
  logic        local_vld;
  logic        local_rdy;
  logic [7:0]  data_local;

  // ---- Remote output interface ----
  logic        remote_vld;
  logic        remote_rdy;
  logic [31:0] data_remote;

  // ---- Status output ----
  logic [15:0] drop_cnt;

  // ---------------------------------------------------------------------------
  // Clocking blocks (sample/drive 1 step before posedge to avoid races)
  // ---------------------------------------------------------------------------

  // Input driver: drives stimulus, samples back-pressure (in_rdy)
  clocking in_drv_cb @(posedge clk);
    default input #1step output #1ns;
    output in_vld, data_in, cfg;
    input  in_rdy;
  endclocking

  // Input monitor: samples everything on the input handshake
  clocking in_mon_cb @(posedge clk);
    default input #1step;
    input in_vld, in_rdy, data_in, cfg;
  endclocking

  // Local consumer: drives local_rdy back-pressure, samples local output
  clocking local_cb @(posedge clk);
    default input #1step output #1ns;
    output local_rdy;
    input  local_vld, data_local;
  endclocking

  // Remote consumer: drives remote_rdy back-pressure, samples remote output
  clocking remote_cb @(posedge clk);
    default input #1step output #1ns;
    output remote_rdy;
    input  remote_vld, data_remote;
  endclocking

  // Status monitor
  clocking status_cb @(posedge clk);
    default input #1step;
    input drop_cnt;
  endclocking

  // ---------------------------------------------------------------------------
  // Modports
  // ---------------------------------------------------------------------------
  modport in_drv    (clocking in_drv_cb,  input clk, rst_n);
  modport in_mon    (clocking in_mon_cb,  input clk, rst_n);
  modport local_mp  (clocking local_cb,   input clk, rst_n);
  modport remote_mp (clocking remote_cb,  input clk, rst_n);
  modport status_mp (clocking status_cb,  input clk, rst_n);

  // ---------------------------------------------------------------------------
  // Protocol assertions (Spec 3.1 transfer, 3.2 stability)
  // ---------------------------------------------------------------------------
  // Stability: while in_vld=1 and in_rdy=0, data_in & cfg must hold steady.
  property p_input_stable;
    @(posedge clk) disable iff (!rst_n)
      (in_vld && !in_rdy) |=> $stable(data_in) && $stable(cfg) && in_vld;
  endproperty
  assert_input_stable : assert property (p_input_stable)
    else $error("BIRD: input data/cfg not stable under back-pressure");

endinterface

`endif // BIRD_IF_SV
