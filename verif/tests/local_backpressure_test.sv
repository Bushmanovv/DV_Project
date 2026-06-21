class local_backpressure_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "local_backpressure_test");
  endfunction

  virtual task run();
    bird_transaction tr;
    bit [7:0] first_data;
    int timeout;

    $display("Starting TP07 local_backpressure_test");

    super.run();

    vif.drv_cb.local_rdy <= 1'b0;
    @(vif.drv_cb);

    tr = new("backpressure_local_packet");
    if (!tr.randomize() with {
      cfg_obj.traffic_type == 1'b0;
      cfg_obj.frag_num     == 5'd1;
      cfg_obj.seq_num      == 5'd1;
    }) $fatal(1, "TP07 randomize failed");
    env.input_agent.gen.transmit(tr);

    timeout = 0;
    do begin
      @(vif.drv_cb);
      timeout++;
      if (timeout > 500) begin
        $display("ERROR TP07: timeout waiting for local_vld");
        $finish;
      end
    end while (vif.drv_cb.local_vld !== 1'b1);

    first_data = vif.drv_cb.data_local;

    repeat (5) @(vif.drv_cb);

    if (vif.drv_cb.local_vld !== 1'b1) begin
      $display("ERROR TP07: local_vld did not stay high during backpressure");
      $finish;
    end

    if (vif.drv_cb.data_local !== first_data) begin
      $display("ERROR TP07: data_local changed during backpressure");
      $finish;
    end

    vif.drv_cb.local_rdy <= 1'b1;

    repeat (50) @(vif.drv_cb);

    report();

    if (env.local_checker.fails != 0) begin
      $display("ERROR TP07: local checker found %0d mismatches", env.local_checker.fails);
      $finish;
    end

    $display("PASSED TP07: local output holds data stable under backpressure");
  endtask

endclass
