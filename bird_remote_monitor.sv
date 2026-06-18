// ============================================================
// bird_remote_monitor.sv  -  Student C
// Captures every 32-bit word accepted on the REMOTE output handshake
// and forwards it to the remote checker / reference model.
// ============================================================
class bird_remote_monitor;

  virtual bird_if vif;
  mailbox #(bit [31:0]) remote_word_mbx;

  function new(virtual bird_if vif, mailbox #(bit [31:0]) remote_word_mbx);
    this.vif             = vif;
    this.remote_word_mbx = remote_word_mbx;
  endfunction

  task run();
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.rst_n !== 1'b1) continue;

      if (vif.mon_cb.remote_vld === 1'b1 && vif.mon_cb.remote_rdy === 1'b1) begin
        remote_word_mbx.put(vif.mon_cb.data_remote);
        $display("[%0t] REMOTE_MON word=%08h", $time, vif.mon_cb.data_remote);
      end
    end
  endtask

endclass
