class local_basic_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "local_basic_test");
  endfunction

  virtual task run();
    bird_local_basic_sequence seq;

    $display("Starting TP05 local_basic_test");

    super.run();

    seq = new();
    seq.packet_count = 2;
    seq.start(env.input_agent.gen);

    repeat (600) @(vif.drv_cb);

    report();

    if (env.local_checker.fails != 0) begin
      $display("ERROR TP05: local checker found %0d mismatches", env.local_checker.fails);
      $finish;
    end

    if (env.local_checker.checks == 0) begin
      $display("ERROR TP05: no local bytes were checked");
      $finish;
    end

    $display("PASSED TP05: local packet forwarded correctly");
  endtask

endclass
