class bird_negative_base_sequence extends bird_base_sequence;

  function new(string name = "bird_negative_base_sequence");
    super.new(name);
  endfunction

  function bird_transaction make_frag_raw(string       nm,
                                          bit          traffic,
                                          int unsigned len,
                                          int unsigned frag,
                                          int unsigned seq,
                                          bit [6:0]    rsv1 = 7'd0,
                                          bit [2:0]    rsv2 = 3'd0,
                                          bit [2:0]    rsv3 = 3'd0);
    bird_transaction tr;
    tr = new(nm);
    tr.cfg_obj.traffic_type   = traffic;
    tr.cfg_obj.payload_len    = len[7:0];
    tr.cfg_obj.frag_num       = frag[4:0];
    tr.cfg_obj.seq_num        = seq[4:0];
    tr.cfg_obj.reserved_7_1   = rsv1;
    tr.cfg_obj.reserved_23_21 = rsv2;
    tr.cfg_obj.reserved_31_29 = rsv3;

    tr.payload = new[len];
    foreach (tr.payload[i]) tr.payload[i] = byte'(8'hA0 + i);
    tr.crc16 = bird_transaction::calc_crc16(tr.payload);
    return tr;
  endfunction
endclass


// TP12 - invalid cfg (each fragment => one drop)
class bird_invalid_cfg_sequence extends bird_negative_base_sequence;
  function new(string name = "bird_invalid_cfg_sequence"); super.new(name); endfunction

  virtual task body(bird_env env);
    // reserved bits [7:1] != 0 on an otherwise-valid local packet
    env.input_agent.send(make_frag_raw("inv_rsv",  1'b0, 4, 1, 1, 7'h1));
    // PAYLOAD_LEN == 0
    env.input_agent.send(make_frag_raw("inv_len0", 1'b0, 0, 1, 1));
    // local with SEQ_NUM != 1
    env.input_agent.send(make_frag_raw("inv_seq",  1'b0, 4, 1, 2));
    // local with FRAG_NUM != 1
    env.input_agent.send(make_frag_raw("inv_frag", 1'b0, 4, 2, 1));
    $display("[%0t] SEQ %s: sent 4 invalid-cfg fragments (expect drop_cnt += 4)", $time, name);
  endtask
endclass


// TP13 - remote protocol errors (SEQ_NUM==0, FRAG_NUM==0 => drops)
class bird_remote_protocol_sequence extends bird_negative_base_sequence;
  function new(string name = "bird_remote_protocol_sequence"); super.new(name); endfunction

  virtual task body(bird_env env);
    env.input_agent.send(make_frag_raw("rem_seq0",  1'b1, 4, 3, 0)); // SEQ_NUM == 0
    env.input_agent.send(make_frag_raw("rem_frag0", 1'b1, 4, 0, 3)); // FRAG_NUM == 0
    $display("[%0t] SEQ %s: sent 2 remote protocol-error fragments (expect drop_cnt += 2)", $time, name);
  endtask
endclass


// TP14 - one increment per dropped packet, valid traffic must NOT increment
class bird_drop_count_sequence extends bird_negative_base_sequence;
  function new(string name = "bird_drop_count_sequence"); super.new(name); endfunction

  virtual task body(bird_env env);
    bird_transaction good;

    env.input_agent.send(make_frag_raw("bad1", 1'b0, 4, 1, 2));  // invalid -> +1

    good = new("good_local");
    good.set_local_packet(4, 5'd1);                              // valid   -> +0
    env.input_agent.send(good);

    env.input_agent.send(make_frag_raw("bad2", 1'b0, 0, 1, 1));  // invalid -> +1
    $display("[%0t] SEQ %s: 2 invalid + 1 valid (expect drop_cnt += 2)", $time, name);
  endtask
endclass


// TP15 - wrap-around: a single drop on a counter preloaded to 0xFFFF
class bird_drop_wrap_sequence extends bird_negative_base_sequence;
  function new(string name = "bird_drop_wrap_sequence"); super.new(name); endfunction

  virtual task body(bird_env env);
    env.input_agent.send(make_frag_raw("wrap", 1'b0, 0, 1, 1));  // 1 invalid -> wraps to 0
    $display("[%0t] SEQ %s: sent 1 invalid fragment to trigger wrap", $time, name);
  endtask
endclass
