// ============================================================
// bird_regression_sequence.sv  -  Student D
// TP25 mixed-traffic and TP26 constrained-random regression.
//
// Stimulus is constrained to the verified, byte-synced feature space:
//   - valid LOCAL packets        (FRAG_NUM=1, SEQ_NUM=1, len 1..255)
//   - valid single-fragment REMOTE packets (N=1)
//   - cfg-invalid fragments with a NON-zero length (SEQ/FRAG/reserved
//     violations, or remote SEQ_NUM==0 / FRAG_NUM==0)
// so the self-checking checkers (local / remote / drop) stay golden.
// (PAYLOAD_LEN==0 drops are deliberately exercised by the TP12-16 tests,
//  not here, to keep the long random stream byte-aligned.)
// ============================================================

// TP25 - mixed traffic in a single run: local + remote + drops
class bird_mixed_sequence extends bird_negative_base_sequence;
  function new(string name = "bird_mixed_sequence"); super.new(name); endfunction

  virtual task body(bird_env env);
    bird_transaction t;

    // valid local (len 4)
    t = new("mix_local_a"); t.set_local_packet(4, 5'd1); env.input_agent.send(t);
    // invalid local: SEQ_NUM != 1 -> drop
    env.input_agent.send(make_frag_raw("mix_bad_local", 1'b0, 4, 1, 2));
    // valid single-fragment remote packet (N=1)
    env.input_agent.send(make_frag_raw("mix_remote", 1'b1, 4, 1, 1));
    // valid local at min length
    t = new("mix_local_b"); t.set_local_packet(1, 5'd1); env.input_agent.send(t);
    // invalid remote: SEQ_NUM == 0 -> drop
    env.input_agent.send(make_frag_raw("mix_bad_remote", 1'b1, 4, 2, 0));
    // valid local at max length
    t = new("mix_local_c"); t.set_local_packet(255, 5'd1); env.input_agent.send(t);

    send_drain(env);
    $display("[%0t] SEQ %s: mixed local+remote+drop stream sent (expect drop_cnt += 2)",
             $time, name);
  endtask
endclass


// TP26 - constrained-random regression
class bird_random_regression_sequence extends bird_negative_base_sequence;
  int unsigned num_frags = 24;

  function new(string name = "bird_random_regression_sequence"); super.new(name); endfunction

  // Pick a length that exercises the min / max / mid coverage bins.
  function int unsigned pick_len();
    case ($urandom_range(0, 4))
      0:       return 1;
      1:       return 255;
      default: return $urandom_range(2, 32);
    endcase
  endfunction

  virtual task body(bird_env env);
    bird_transaction t;
    int unsigned kind;
    int unsigned len;

    for (int unsigned i = 0; i < num_frags; i++) begin
      kind = $urandom_range(0, 9);
      len  = pick_len();

      if (kind < 4) begin
        // 40% valid local
        t = new($sformatf("rnd_vlocal_%0d", i));
        t.set_local_packet(len, 5'd1);
        env.input_agent.send(t);
      end
      else if (kind < 6) begin
        // 20% valid single-fragment remote (N=1, small payload)
        env.input_agent.send(make_frag_raw($sformatf("rnd_vremote_%0d", i),
                                           1'b1, $urandom_range(1, 8), 1, 1));
      end
      else if (kind < 8) begin
        // 20% invalid local (one non-zero-length violation each)
        case ($urandom_range(0, 2))
          0: env.input_agent.send(make_frag_raw($sformatf("rnd_iloc_seq_%0d",  i), 1'b0, len, 1, 2));        // SEQ != 1
          1: env.input_agent.send(make_frag_raw($sformatf("rnd_iloc_frag_%0d", i), 1'b0, len, 2, 1));        // FRAG != 1
          2: env.input_agent.send(make_frag_raw($sformatf("rnd_iloc_rsv_%0d",  i), 1'b0, len, 1, 1, 7'h1));  // reserved != 0
        endcase
      end
      else begin
        // 20% invalid remote (SEQ_NUM==0 or FRAG_NUM==0)
        if ($urandom_range(0, 1))
          env.input_agent.send(make_frag_raw($sformatf("rnd_irem_seq0_%0d",  i), 1'b1, len, 3, 0));
        else
          env.input_agent.send(make_frag_raw($sformatf("rnd_irem_frag0_%0d", i), 1'b1, len, 0, 3));
      end
    end

    send_drain(env);
    $display("[%0t] SEQ %s: sent %0d constrained-random fragments", $time, name, num_frags);
  endtask
endclass
