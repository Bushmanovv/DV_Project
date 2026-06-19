class backpressure_stability_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "backpressure_stability_test");
  endfunction

  task wait_cycles(input int n);
    repeat (n) begin
      @(posedge vif.clk);
    end
  endtask

  function bit [31:0] local_cfg();
    bit [31:0] c;

    c = 32'h0000_0000;
    c[0]     = 1'b0;
    c[15:8]  = 8'd1;
    c[20:16] = 5'd1;
    c[28:24] = 5'd1;

    return c;
  endfunction

  task send_byte(input bit [7:0] data, input bit [31:0] cfg_value);
    vif.in_vld  = 1'b1;
    vif.data_in = data;
    vif.cfg     = cfg_value;

    @(posedge vif.clk);

    while (vif.in_rdy !== 1'b1) begin
      @(posedge vif.clk);
    end
  endtask

  virtual task run();
    bit [31:0] cfg_value;
    bit [7:0] payload;
    bit [15:0] crc;
    bit [7:0] held_data;
    byte unsigned data_array[];

    $display("Starting TP03 backpressure_stability_test");

    wait (vif.rst_n == 1'b1);
    wait_cycles(2);

    cfg_value = local_cfg();
    payload = 8'hA5;

    data_array = new[1];
    data_array[0] = payload;
    crc = bird_transaction::calc_crc16(data_array);

    vif.local_rdy = 1'b0;

    send_byte(payload, cfg_value);
    send_byte(crc[15:8], cfg_value);
    send_byte(crc[7:0], cfg_value);

    vif.in_vld  = 1'b0;
    vif.data_in = 8'h00;
    vif.cfg     = 32'h0000_0000;

    wait (vif.local_vld == 1'b1);

    held_data = vif.data_local;

    wait_cycles(5);

    if (vif.local_vld !== 1'b1) begin
      $display("ERROR TP03: local_vld changed while local_rdy was 0");
      $finish;
    end

    if (vif.data_local !== held_data) begin
      $display("ERROR TP03: data_local changed while local_rdy was 0");
      $finish;
    end

    vif.local_rdy = 1'b1;
    wait_cycles(5);

    $display("PASSED TP03: output data stable under backpressure");
  endtask

endclass
