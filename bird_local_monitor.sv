class bird_local_monitor;

  virtual bird_if vif;
  mailbox #(byte unsigned) local_byte_mbx;

  function new(virtual bird_if vif, mailbox #(byte unsigned) local_byte_mbx);
    this.vif            = vif;
    this.local_byte_mbx = local_byte_mbx;
  endfunction

  task run();
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.rst_n !== 1'b1) continue;

      if (vif.mon_cb.local_vld === 1'b1 && vif.mon_cb.local_rdy === 1'b1) begin
        local_byte_mbx.put(vif.mon_cb.data_local);
        $display("[%0t] LOCAL_MON byte=%02h", $time, vif.mon_cb.data_local);
      end
    end
  endtask

endclass
