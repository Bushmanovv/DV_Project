class bird_generator;

  mailbox #(bird_transaction) gen2drv_mbx;
  int unsigned num_transactions;

  function new(mailbox #(bird_transaction) gen2drv_mbx);
    this.gen2drv_mbx = gen2drv_mbx;
    num_transactions = 1;
  endfunction

  task run();
    bird_transaction tr;

    repeat (num_transactions) begin
      tr = new("generated_local_transaction");
      tr.set_local_packet(4, 5'd1);
      gen2drv_mbx.put(tr);
      $display("[%0t] GEN sent: %s", $time, tr.sprint());
    end
  endtask

endclass

