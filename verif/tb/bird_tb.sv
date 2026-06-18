module bird_tb;

  bit clk;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  bird_if bus_if(clk);

  bird dut (
    .clk         (bus_if.clk),
    .rst_n       (bus_if.rst_n),
    .drop_cnt    (bus_if.drop_cnt),
    .in_vld      (bus_if.in_vld),
    .in_rdy      (bus_if.in_rdy),
    .data_in     (bus_if.data_in),
    .cfg         (bus_if.cfg),
    .local_vld   (bus_if.local_vld),
    .local_rdy   (bus_if.local_rdy),
    .data_local  (bus_if.data_local),
    .remote_vld  (bus_if.remote_vld),
    .remote_rdy  (bus_if.remote_rdy),
    .data_remote (bus_if.data_remote)
  );

  bird_test test_harness(bus_if);

  initial begin
    bus_if.rst_n = 1'b0;
    bus_if.in_vld = 1'b0;
    bus_if.data_in = 8'h00;
    bus_if.cfg = 32'h0000_0000;
    bus_if.local_rdy = 1'b1;
    bus_if.remote_rdy = 1'b1;

    repeat (5) @(posedge clk);
    bus_if.rst_n = 1'b1;
  end

  initial begin
    #100000;
    $fatal(1, "Simulation timeout");
  end

  initial begin
    $dumpfile("bird_tb.vcd");
    $dumpvars(0, bird_tb);
  end

endmodule

