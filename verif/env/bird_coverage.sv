// ============================================================
// bird_coverage.sv  -  Student D
// Functional coverage of the input stimulus. Samples every observed input
// fragment (via the input monitor broadcast) and records cfg field bins.
//
// Code coverage (line/toggle/fsm/branch/cond) is collected separately by
// VCS through the -cm flags in scripts/run_regression.sh.
// ============================================================
class bird_coverage;

  mailbox #(bird_transaction) cov_mbx;

  // Sampled fields (covergroup coverpoints reference these).
  bit       s_traffic;
  bit [7:0] s_len;
  bit [4:0] s_frag;
  bit [4:0] s_seq;
  bit       s_legal;

  covergroup cg_input;
    option.per_instance = 1;

    cp_traffic: coverpoint s_traffic {
      bins local_t  = {1'b0};
      bins remote_t = {1'b1};
    }

    cp_len: coverpoint s_len {
      bins len_min  = {1};
      bins len_max  = {255};
      bins len_mid  = {[2:254]};
      bins len_zero = {0};        // illegal boundary
    }

    cp_frag: coverpoint s_frag {
      bins frag_one  = {1};
      bins frag_many = {[2:31]};
      bins frag_zero = {0};       // illegal for remote
    }

    cp_seq: coverpoint s_seq {
      bins seq_one  = {1};
      bins seq_many = {[2:31]};
      bins seq_zero = {0};        // illegal for remote
    }

    cp_legal: coverpoint s_legal {
      bins legal   = {1'b1};
      bins illegal = {1'b0};
    }

    x_traffic_len   : cross cp_traffic, cp_len;
    x_traffic_legal : cross cp_traffic, cp_legal;
  endgroup

  function new(mailbox #(bird_transaction) cov_mbx);
    this.cov_mbx = cov_mbx;
    cg_input = new();
  endfunction

  task run();
    bird_transaction tr;
    forever begin
      cov_mbx.get(tr);
      s_traffic = tr.cfg_obj.traffic_type;
      s_len     = tr.cfg_obj.payload_len;
      s_frag    = tr.cfg_obj.frag_num;
      s_seq     = tr.cfg_obj.seq_num;
      s_legal   = tr.cfg_obj.is_legal();
      cg_input.sample();
    end
  endtask

  function void report();
    $display("==== COVERAGE REPORT: cg_input = %0.2f%% ====", cg_input.get_coverage());
  endfunction

endclass
