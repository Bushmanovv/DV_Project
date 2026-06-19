class bird_env;

  virtual bird_if vif;

  bird_input_agent   input_agent;
  bird_local_monitor local_mon;
  bird_remote_monitor remote_mon;
  bird_local_checker local_checker;

  mailbox #(bird_transaction) input_obs_mbx;
  mailbox #(byte unsigned)    local_byte_mbx;
  mailbox #(bit [31:0])       remote_word_mbx;

  function new(virtual bird_if vif);
    this.vif = vif;

    input_obs_mbx  = new();
    local_byte_mbx = new();
    remote_word_mbx = new();

    input_agent = new(vif, input_obs_mbx);
    local_mon = new(vif, local_byte_mbx);
    remote_mon = new(vif, remote_word_mbx);
    local_checker = new(input_obs_mbx, local_byte_mbx);
  endfunction

  task run();
    fork
      input_agent.run();
      local_mon.run();
      remote_mon.run();
      local_checker.run();
    join_none
  endtask

  function void report();
    local_checker.report();
  endfunction

endclass

