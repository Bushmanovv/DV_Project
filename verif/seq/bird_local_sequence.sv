class bird_local_basic_sequence extends bird_base_sequence;

  int unsigned packet_count;

  function new(string name = "bird_local_basic_sequence");
    super.new(name);
    packet_count = 1;
  endfunction

  virtual task body(bird_env env);
    bird_transaction tr;

    for (int unsigned i = 0; i < packet_count; i++) begin
      tr = new($sformatf("local_packet_%0d", i));
      tr.set_local_packet(1, 5'd1);
      env.input_agent.send(tr);
      $display("[%0t] SEQ sent: %s", $time, tr.sprint());
    end
  endtask

endclass
