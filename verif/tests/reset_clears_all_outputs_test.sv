class reset_clears_all_outputs_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "reset_clears_all_outputs_test");
  endfunction

  virtual task run();
    $display("Starting TP01 reset_clears_all_outputs_test");

    wait (vif.rst_n == 1'b1);
    repeat (2) @(vif.drv_cb);

    vif.rst_n = 1'b0;
    repeat (2) @(vif.drv_cb);

    if (vif.drv_cb.local_vld !== 1'b0) begin
      $display("ERROR TP01: local_vld was not deasserted during reset");
      $finish;
    end

    if (vif.drv_cb.remote_vld !== 1'b0) begin
      $display("ERROR TP01: remote_vld was not deasserted during reset");
      $finish;
    end

    if (vif.drv_cb.drop_cnt !== 16'd0) begin
      $display("ERROR TP01: drop_cnt was not cleared during reset");
      $finish;
    end

    vif.rst_n = 1'b1;
    repeat (2) @(vif.drv_cb);

    $display("PASSED TP01: reset deasserts valid outputs and clears drop counter");
  endtask

endclass
