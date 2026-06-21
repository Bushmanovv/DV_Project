// ============================================================
// remote_tests.sv  -  Student C
// Tests TP08-TP11 (remote traffic). Each test starts the env, runs its
// sequence, lets the outputs drain, prints the checker reports and finishes.
// ============================================================

// TP08 - remote single fragment
class remote_basic_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "remote_basic_test");
  endfunction

  virtual task run();
    bird_remote_single_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (300) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP09 - remote in-order fragments
class remote_inorder_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "remote_inorder_test");
  endfunction

  virtual task run();
    bird_remote_inorder_sequence seq;
    super.run();
    seq = new();
    seq.n = 3;
    seq.body(env);
    repeat (400) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP10 - remote out-of-order fragments
class remote_reorder_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "remote_reorder_test");
  endfunction

  virtual task run();
    bird_remote_reorder_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (400) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP11 - regenerated CRC: drive a multi-fragment packet with deliberately
// WRONG input CRCs; the DUT must still emit a CRC computed over the merged
// payload, which the remote checker verifies.
class remote_crc_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "remote_crc_test");
  endfunction

  virtual task run();
    bird_remote_inorder_sequence seq;
    super.run();
    seq = new();
    seq.n           = 3;
    seq.corrupt_crc = 1'b1;
    seq.body(env);
    repeat (400) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass
