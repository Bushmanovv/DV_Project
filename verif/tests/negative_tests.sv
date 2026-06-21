
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

    // The DUT drop counter is preloaded to 0xFFFF by the testbench top
    // (bird_tb) for this test - a package class may not force a module
    // hierarchy. Here we only align the reference model to that value.
    env.drop_checker.preload(16'hFFFF);

    seq = new();
    seq.body(env);
    repeat (200) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass