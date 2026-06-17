class bird_driver;

  virtual bird_if vif;
  mailbox #(bird_transaction) gen2drv_mbx;

  function new(virtual bird_if vif, mailbox #(bird_transaction) gen2drv_mbx);
    this.vif = vif;
    this.gen2drv_mbx = gen2drv_mbx;
  endfunction

  task reset_signals();
    vif.drv_cb.in_vld     <= 1'b0;
    vif.drv_cb.data_in    <= 8'h00;
    vif.drv_cb.cfg        <= 32'h0000_0000;
    vif.drv_cb.local_rdy  <= 1'b1;
    vif.drv_cb.remote_rdy <= 1'b1;
  endtask

  task run();
    bird_transaction tr;

    reset_signals();
    wait (vif.rst_n == 1'b1);

    forever begin
      gen2drv_mbx.get(tr);
      drive_item(tr);
    end
  endtask

  task drive_item(bird_transaction tr);
    bit [31:0] packed_cfg;

    packed_cfg = tr.cfg();

    for (int unsigned i = 0; i < tr.stream_size(); i++) begin
      vif.drv_cb.in_vld  <= 1'b1;
      vif.drv_cb.data_in <= tr.stream_byte(i);
      vif.drv_cb.cfg     <= packed_cfg;

      do begin
        @(vif.drv_cb);
      end while (vif.drv_cb.in_rdy !== 1'b1);
    end

    vif.drv_cb.in_vld  <= 1'b0;
    vif.drv_cb.data_in <= 8'h00;
    vif.drv_cb.cfg     <= 32'h0000_0000;

    @(vif.drv_cb);
  endtask

endclass

