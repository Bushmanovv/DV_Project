class reset_clears_all_outputs_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "reset_clears_all_outputs_test");
  endfunction

  task wait_cycles(input int n);
    repeat (n) begin
      @(posedge vif.clk);
    end
  endtask

  virtual task run();
    $display("Starting TP01 reset_clears_all_outputs_test");

    wait (vif.rst_n == 1'b1);
    wait_cycles(2);

    vif.local_rdy  = 1'b1;
    vif.remote_rdy = 1'b1;
    vif.in_vld     = 1'b0;
    vif.data_in    = 8'h00;
    vif.cfg        = 32'h0000_0000;

    wait_cycles(2);

    vif.rst_n = 1'b0;
    wait_cycles(2);

    if (vif.drop_cnt !== 16'd0) begin
      $display("ERROR TP01: drop_cnt was not cleared");
      $finish;
    end

    if (vif.local_vld !== 1'b0) begin
      $display("ERROR TP01: local_vld was not cleared");
      $finish;
    end

    if (vif.remote_vld !== 1'b0) begin
      $display("ERROR TP01: remote_vld was not cleared");
      $finish;
    end

    if (vif.data_local !== 8'h00) begin
      $display("ERROR TP01: data_local was not cleared");
      $finish;
    end

    if (vif.data_remote !== 32'h0000_0000) begin
      $display("ERROR TP01: data_remote was not cleared");
      $finish;
    end

    vif.rst_n = 1'b1;
    wait_cycles(2);

    $display("PASSED TP01: reset clears outputs and drop counter");
  endtask

endclass
