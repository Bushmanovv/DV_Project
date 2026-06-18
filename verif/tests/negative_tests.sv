

// TP12 - invalid cfg drops
class invalid_cfg_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "invalid_cfg_test");
  endfunction

  virtual task run();
    bird_invalid_cfg_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (200) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP13 - remote protocol error drops
class remote_protocol_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "remote_protocol_test");
  endfunction

  virtual task run();
    bird_remote_protocol_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (200) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP14 - drop counter increments once per dropped packet
class drop_count_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "drop_count_test");
  endfunction

  virtual task run();
    bird_drop_count_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (200) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP15 - drop counter wrap-around (0xFFFF -> 0x0000)
// Preload the DUT counter via force/release and align the predictor, then
// drive one more dropped packet so the counter wraps to 0.
class drop_wrap_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "drop_wrap_test");
  endfunction

  virtual task run();
    bird_drop_wrap_sequence seq;
    super.run();

    // Preload DUT counter to max, then let it free-run again.
    force bird_tb.dut.drop_cnt = 16'hFFFF;
    repeat (2) @(posedge vif.clk);
    release bird_tb.dut.drop_cnt;

    // Keep the reference model in step with the forced value.
    env.drop_checker.preload(16'hFFFF);

    seq = new();
    seq.body(env);
    repeat (200) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass
