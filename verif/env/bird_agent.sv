class bird_input_agent;

  bird_generator     gen;
  bird_driver        drv;
  bird_input_monitor mon;

  mailbox #(bird_transaction) gen2drv_mbx;
  mailbox #(bird_transaction) input_obs_mbx;

  function new(
    virtual bird_if vif,
    mailbox #(bird_transaction) input_obs_mbx
  );
    gen2drv_mbx = new();
    this.input_obs_mbx = input_obs_mbx;

    gen = new(gen2drv_mbx);
    drv = new(vif, gen2drv_mbx);
    mon = new(vif, input_obs_mbx);
  endfunction

  task run();
    fork
      drv.run();
      mon.run();
    join_none
  endtask

endclass
