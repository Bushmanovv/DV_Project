class bird_env;

  virtual bird_if vif;

  bird_input_agent   input_agent;
  bird_local_monitor local_mon;
  bird_remote_monitor remote_mon;
  bird_local_checker local_checker;
  bird_drop_checker  drop_checker;   // Student D (TP12-TP15)
  bird_coverage      coverage;       // Student D functional coverage

  mailbox #(bird_transaction) input_obs_mbx;
  mailbox #(byte unsigned)    local_byte_mbx;
  mailbox #(bit [31:0])       remote_word_mbx;
  mailbox #(bird_transaction) drop_mbx;   // every observed input fragment -> drop checker
  mailbox #(bird_transaction) cov_mbx;    // every observed input fragment -> coverage

  function new(virtual bird_if vif);
    this.vif = vif;

    input_obs_mbx  = new();
    local_byte_mbx = new();
    remote_word_mbx = new();
    drop_mbx = new();
    cov_mbx  = new();

    input_agent = new(vif, input_obs_mbx);
    local_mon = new(vif, local_byte_mbx);
    remote_mon = new(vif, remote_word_mbx);
    local_checker = new(input_obs_mbx, local_byte_mbx);

    // The drop checker and coverage observe the full input fragment stream
    // (legal and illegal). The input monitor fans out to every subscriber.
    input_agent.mon.add_subscriber(drop_mbx);
    input_agent.mon.add_subscriber(cov_mbx);
    drop_checker = new(drop_mbx, vif);
    coverage     = new(cov_mbx);
  endfunction

  task run();
    fork
      input_agent.run();
      local_mon.run();
      remote_mon.run();
      local_checker.run();
      drop_checker.run();
      coverage.run();
    join_none
  endtask

  function void report();
    local_checker.report();
    drop_checker.report();
    coverage.report();
  endfunction

endclass
