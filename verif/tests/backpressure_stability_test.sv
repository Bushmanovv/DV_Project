class backpressure_stability_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "backpressure_stability_test");
  endfunction

  function bit [31:0] local_cfg();
    bit [31:0] c;
    c = 32'h0;
    c[0]     = 1'b0;
    c[15:8]  = 8'd1;
    c[20:16] = 5'd1;
    c[28:24] = 5'd1;
    return c;
  endfunction

  task send_byte(input bit [7:0] data, input bit [31:0] cfg_value);
    vif.drv_cb.in_vld  <= 1'b1;
    vif.drv_cb.data_in <= data;
    vif.drv_cb.cfg     <= cfg_value;
    do begin
      @(vif.drv_cb);
    end while (vif.drv_cb.in_rdy !== 1'b1);
  endtask

  virtual task run();
    bit [31:0]    cfg_value;
    bit [7:0]     payload;
    bit [15:0]    crc;
    bit [7:0]     held_data;
    byte unsigned data_array[];
    int           timeout;

    $display("Starting TP03 backpressure_stability_test");

    wait (vif.rst_n == 1'b1);
    repeat (2) @(vif.drv_cb);

    cfg_value     = local_cfg();
    payload       = 8'hA5;
    data_array    = new[1];
    data_array[0] = payload;
    crc = bird_transaction::calc_crc16(data_array);

    vif.drv_cb.local_rdy <= 1'b0;
    @(vif.drv_cb);

    send_byte(payload,   cfg_value);
    send_byte(crc[15:8], cfg_value);
    send_byte(crc[7:0],  cfg_value);

    vif.drv_cb.in_vld  <= 1'b0;
    vif.drv_cb.data_in <= 8'h00;
    vif.drv_cb.cfg     <= 32'h0;
    @(vif.drv_cb);

    timeout = 0;
    do begin
      @(vif.drv_cb);
      timeout++;
      if (timeout > 200) begin
        $display("ERROR TP03: timeout waiting for local_vld");
        $finish;
      end
    end while (vif.drv_cb.local_vld !== 1'b1);

    held_data = vif.drv_cb.data_local;

    repeat (5) @(vif.drv_cb);

    if (vif.drv_cb.local_vld !== 1'b1) begin
      $display("ERROR TP03: local_vld changed while local_rdy was 0");
      $finish;
    end

    if (vif.drv_cb.data_local !== held_data) begin
      $display("ERROR TP03: data_local changed while local_rdy was 0");
      $finish;
    end

    vif.drv_cb.local_rdy <= 1'b1;
    repeat (5) @(vif.drv_cb);

    $display("PASSED TP03: output data stable under backpressure");
  endtask

endclass
