class local_payload_boundary_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "local_payload_boundary_test");
  endfunction

  task send_local_packet(input int length);
    bird_transaction tr;
    tr = new("boundary_local_packet");
    tr.set_local_packet(length, 5'd1);
    env.input_agent.gen.transmit(tr);
    $display("TP06 sent local packet with length = %0d", length);
  endtask

  virtual task run();
    $display("Starting TP06 local_payload_boundary_test");

    super.run();

    send_local_packet(1);
    send_local_packet(255);

    repeat (3000) @(vif.drv_cb);

    report();

    if (env.local_checker.fails != 0) begin
      $display("ERROR TP06: local checker found %0d mismatches", env.local_checker.fails);
      $finish;
    end

    if (env.local_checker.checks == 0) begin
      $display("ERROR TP06: no boundary bytes were checked");
      $finish;
    end

    $display("PASSED TP06: local payload boundary test completed");
  endtask

endclass
