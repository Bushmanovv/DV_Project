//------------------------------------------------------------------------------
// bird_coverage.sv  -  functional coverage collector
//
// Subscribes to observed input fragments. Extend covergroups + add output-side
// coverage to close the test plan's "Coverage" column.
//------------------------------------------------------------------------------
`ifndef BIRD_COVERAGE_SV
`define BIRD_COVERAGE_SV

class bird_coverage extends uvm_subscriber #(bird_seq_item);
  `uvm_component_utils(bird_coverage)

  bird_seq_item tr;

  covergroup cg_cfg;
    option.per_instance = 1;

    cp_traffic : coverpoint tr.traffic_type { bins local = {0}; bins remote = {1}; }

    cp_len : coverpoint tr.payload_len {
      bins min   = {1};
      bins max   = {255};
      bins small = {[2:16]};
      bins mid   = {[17:254]};
      bins zero  = {0};            // illegal (drop) value
    }

    cp_frag : coverpoint tr.frag_num {
      bins one  = {1};
      bins mid  = {[2:30]};
      bins max  = {31};
      bins zero = {0};             // illegal (drop)
    }

    cp_seq : coverpoint tr.seq_num {
      bins valid[] = {[1:31]};
      bins zero    = {0};          // illegal (drop)
    }

    cp_reserved : coverpoint (tr.rsvd_7_1 != 0 || tr.rsvd_23_21 != 0 || tr.rsvd_31_29 != 0) {
      bins clean    = {0};
      bins violated = {1};         // illegal (drop)
    }

    x_type_len : cross cp_traffic, cp_len;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_cfg = new();
  endfunction

  function void write(bird_seq_item t);
    tr = t;
    cg_cfg.sample();
  endfunction

endclass

`endif // BIRD_COVERAGE_SV
