

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



