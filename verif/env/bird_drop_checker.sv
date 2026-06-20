class bird_drop_checker;

  mailbox #(bird_transaction) drop_mbx;
  virtual bird_if vif;

  bit [15:0]   exp_drops;
  int unsigned invalid_seen;

  function new(mailbox #(bird_transaction) drop_mbx, virtual bird_if vif);
    this.drop_mbx = drop_mbx;
    this.vif      = vif;
    exp_drops     = 16'd0;
    invalid_seen  = 0;
  endfunction

  // Align the predicted counter with a forced DUT value (TP15).
  function void preload(bit [15:0] value);
    exp_drops = value;
  endfunction

  task run();
    bird_transaction tr;
    forever begin
      drop_mbx.get(tr);
      if (!tr.cfg_obj.is_legal()) begin
        exp_drops = exp_drops + 16'd1;   // natural 16-bit wrap, like the DUT
        invalid_seen++;
        $display("[%0t] DROP_CHK predicted drop -> exp_drops=0x%04h (%s)",
                 $time, exp_drops, tr.cfg_obj.sprint());
      end
    end
  endtask

  function void report();
    bit [15:0] actual;
    actual = vif.drop_cnt;
    $display("==== DROP CHECKER REPORT: invalid_fragments=%0d expected=0x%04h actual=0x%04h -> %s ====",
             invalid_seen, exp_drops, actual,
             (actual === exp_drops) ? "PASS" : "FAIL");
  endfunction

endclass
