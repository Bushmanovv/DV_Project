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
    $display("Starting %s", name);
    env.run();
  endtask

  virtual function void report();
    env.report();
  endfunction

endclass
