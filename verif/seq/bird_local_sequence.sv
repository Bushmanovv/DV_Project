class bird_local_basic_sequence extends bird_base_sequence;

  int unsigned packet_count;

  function new(string name = "bird_local_basic_sequence");
    super.new(name);
    packet_count = 1;
  endfunction

  virtual task body();
    bird_transaction tr;

    for (int unsigned i = 0; i < packet_count; i++) begin
      tr = new($sformatf("local_packet_%0d", i));
      if (!tr.randomize() with {
        cfg_obj.traffic_type == 1'b0;
        cfg_obj.frag_num     == 5'd1;
        cfg_obj.seq_num      == 5'd1;
      }) $fatal(1, "[%s] randomize failed", name);
      gen.transmit(tr);
      $display("[%0t] SEQ sent: %s", $time, tr.sprint());
    end
  endtask

endclass
