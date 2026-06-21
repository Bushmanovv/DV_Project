class cfg_sampled_on_first_payload_byte_test extends bird_base_test;

  function new(virtual bird_if vif);
    super.new(vif, "cfg_sampled_on_first_payload_byte_test");
  endfunction

  function bit [31:0] good_local_cfg();
    bit [31:0] c;
    c = 32'h0;
    c[0]     = 1'b0;
    c[15:8]  = 8'd1;
    c[20:16] = 5'd1;
    c[28:24] = 5'd1;
    return c;
  endfunction

  function bit [31:0] bad_cfg();
    bit [31:0] c;
    c = 32'h0;
    c[0]     = 1'b0;
    c[15:8]  = 8'd0;
    c[20:16] = 5'd0;
    c[28:24] = 5'd0;
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
    bit [31:0]    cfg_good;
    bit [31:0]    cfg_bad;
    bit [7:0]     payload;
    bit [15:0]    crc;
    bit [15:0]    drop_before;
    byte unsigned data_array[];

    $display("Starting TP04 cfg_sampled_on_first_payload_byte_test");

    wait (vif.rst_n == 1'b1);
    repeat (2) @(vif.drv_cb);

    cfg_good      = good_local_cfg();
    cfg_bad       = bad_cfg();
    payload       = 8'h33;
    data_array    = new[1];
    data_array[0] = payload;
    crc = bird_transaction::calc_crc16(data_array);

    drop_before = vif.drv_cb.drop_cnt;

    vif.drv_cb.local_rdy <= 1'b1;
    @(vif.drv_cb);

    send_byte(payload,   cfg_good);
    send_byte(crc[15:8], cfg_bad);
    send_byte(crc[7:0],  cfg_bad);

    vif.drv_cb.in_vld  <= 1'b0;
    vif.drv_cb.data_in <= 8'h00;
    vif.drv_cb.cfg     <= 32'h0;

    repeat (20) @(vif.drv_cb);

    if (vif.drv_cb.drop_cnt !== drop_before) begin
      $display("ERROR TP04: drop_cnt changed — cfg was re-sampled after first byte");
      $finish;
    end

    $display("PASSED TP04: cfg correctly sampled only on first payload byte");
  endtask

endclass
