class bird_base_test;

  virtual bird_if vif;
  bird_env env;
  string name;

  function new(virtual bird_if vif, string name = "bird_base_test");
    this.vif = vif;
    this.name = name;
    env = new(vif);
  endfunction

  virtual task run();
    $display("[%0t] TEST starting: %s", $time, name);
    env.run();
    wait (vif.rst_n == 1'b1);
    repeat (2) @(posedge vif.clk);
  endtask

  virtual function void report();
    env.report();
  endfunction

endclass

