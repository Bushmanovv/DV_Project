class bird_base_sequence;

  string name;

  function new(string name = "bird_base_sequence");
    this.name = name;
  endfunction

  virtual task body(bird_env env);
    $display("[%0t] Running empty sequence: %s", $time, name);
  endtask

endclass

