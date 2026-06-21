class bird_generator;

  mailbox #(bird_transaction) gen2drv_mbx;

  function new(mailbox #(bird_transaction) gen2drv_mbx);
    this.gen2drv_mbx = gen2drv_mbx;
  endfunction

  task transmit(bird_transaction tr);
    gen2drv_mbx.put(tr);
  endtask

endclass
