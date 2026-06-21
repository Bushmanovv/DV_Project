// ============================================================
// bird_remote_sequence.sv  -  Student C
// Remote-traffic stimulus sequences for TP08-TP11.
//
// DUT fragment encoding (per the BIRD model):
//   - SEQ_NUM  = fragment index within the packet (1..N)
//   - FRAG_NUM = total number of fragments N in the packet
// A packet completes once every SEQ_NUM 1..N has been received.
// ============================================================
class bird_remote_base_sequence extends bird_base_sequence;

  function new(string name = "bird_remote_base_sequence");
    super.new(name);
  endfunction

  // Build a single remote fragment.
  //   seq         : SEQ_NUM (fragment index 1..N)
  //   n_total     : FRAG_NUM (total fragment count N)
  //   len         : payload length for this fragment
  //   corrupt_crc : drive a wrong input CRC (DUT must regenerate it anyway)
  function bird_transaction make_frag(int unsigned seq,
                                      int unsigned n_total,
                                      int unsigned len,
                                      bit          corrupt_crc = 1'b0);
    bird_transaction tr;
    tr = new($sformatf("remote_frag_seq%0d_of%0d", seq, n_total));

    tr.cfg_obj.traffic_type   = 1'b1;          // remote
    tr.cfg_obj.payload_len    = len[7:0];
    tr.cfg_obj.frag_num       = n_total[4:0];  // FRAG_NUM = N
    tr.cfg_obj.seq_num        = seq[4:0];      // SEQ_NUM  = index
    tr.cfg_obj.reserved_7_1   = 7'd0;
    tr.cfg_obj.reserved_23_21 = 3'd0;
    tr.cfg_obj.reserved_31_29 = 3'd0;

    tr.payload = new[len];
    foreach (tr.payload[i]) begin
      tr.payload[i] = byte'((seq * 8'h10) + i);  // distinct, predictable bytes
    end

    tr.crc16 = corrupt_crc ? 16'hDEAD
                           : bird_transaction::calc_crc16(tr.payload);
    return tr;
  endfunction

  // Drain fragment: a valid LOCAL packet appended after the remote stimulus.
  // The input monitor only emits a fragment once the NEXT fragment starts on
  // the bus, so without this the final remote fragment of the packet never
  // reaches the remote checker (it would never see a complete packet). The
  // local drain is ignored by the remote checker and adds no remote output.
  task send_drain(bird_env env);
    bird_transaction tr;
    tr = new("drain");
    tr.set_local_packet(4, 5'd1);
    env.input_agent.send(tr);
  endtask

endclass


// TP08 - remote single fragment (N = 1)
class bird_remote_single_sequence extends bird_remote_base_sequence;
  int unsigned len = 4;

  function new(string name = "bird_remote_single_sequence");
    super.new(name);
  endfunction

  virtual task body(bird_env env);
    env.input_agent.send(make_frag(1, 1, len));
    send_drain(env);
    $display("[%0t] SEQ %s: sent single remote fragment", $time, name);
  endtask
endclass


// TP09 / TP11 - remote multi-fragment, delivered IN ORDER (1..N)
class bird_remote_inorder_sequence extends bird_remote_base_sequence;
  int unsigned n           = 3;
  int unsigned len         = 4;
  bit          corrupt_crc = 1'b0;

  function new(string name = "bird_remote_inorder_sequence");
    super.new(name);
  endfunction

  virtual task body(bird_env env);
    for (int unsigned s = 1; s <= n; s++) begin
      env.input_agent.send(make_frag(s, n, len, corrupt_crc));
    end
    send_drain(env);
    $display("[%0t] SEQ %s: sent %0d in-order remote fragments", $time, name, n);
  endtask
endclass


// TP10 - remote multi-fragment, delivered OUT OF ORDER (3, 1, 2)
class bird_remote_reorder_sequence extends bird_remote_base_sequence;
  int unsigned len = 4;

  function new(string name = "bird_remote_reorder_sequence");
    super.new(name);
  endfunction

  virtual task body(bird_env env);
    env.input_agent.send(make_frag(3, 3, len));
    env.input_agent.send(make_frag(1, 3, len));
    env.input_agent.send(make_frag(2, 3, len));
    send_drain(env);
    $display("[%0t] SEQ %s: sent 3 remote fragments out of order (3,1,2)", $time, name);
  endtask
endclass
