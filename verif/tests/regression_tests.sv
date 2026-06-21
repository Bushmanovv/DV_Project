// ============================================================
// regression_tests.sv  -  Student D
// TP25 mixed traffic, TP26 constrained-random regression.
// Both run the full env (all checkers + coverage active) and rely on the
// self-checking checkers for pass/fail.
// ============================================================

// TP25 - mixed local + remote + drop traffic in one run
class mixed_traffic_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "mixed_traffic_test");
  endfunction

  virtual task run();
    bird_mixed_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (3000) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass


// TP26 - constrained-random soak regression
class random_regression_test extends bird_base_test;
  function new(virtual bird_if vif);
    super.new(vif, "random_regression_test");
  endfunction

  virtual task run();
    bird_random_regression_sequence seq;
    super.run();
    seq = new();
    seq.body(env);
    repeat (6000) @(posedge vif.clk);
    report();
    $finish;
  endtask
endclass
