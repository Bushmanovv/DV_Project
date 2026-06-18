// ============================================================
// bird_remote_checker.sv  -  Student C
// Reference model + checker for the REMOTE path.
//
// Mirrors the DUT's remote behavior:
//   - Fragments of a packet are indexed by SEQ_NUM (1..N).
//   - FRAG_NUM carries the total fragment count N for the packet.
//   - Fragments may arrive out of order; the model stores each at its
//     SEQ_NUM slot and, once all 1..N slots are filled, merges them in
//     order, REGENERATES a CRC16 over the merged payload, packs the
//     payload into little-endian 32-bit words, then appends one CRC word
//     {16'h0000, crc16}.
//
// It then compares the predicted output words against what the remote
// monitor actually observed on the remote output.
//
// NOTE: this implements the VALID remote path (TP08-TP11). Drop / protocol
// error prediction is Student D's extension.
// ============================================================
class bird_remote_checker;

  mailbox #(bird_transaction) input_obs_mbx;
  mailbox #(bit [31:0])       remote_word_mbx;

  // Reference accumulation state (mirrors the DUT).
  bit           ractive;
  int unsigned  amax;             // inferred N = max(FRAG_NUM, SEQ_NUM) seen
  bit           fseen[1:31];
  byte unsigned fpay [1:31][$];

  int unsigned  packets;
  int unsigned  words_checked;
  int unsigned  words_pass;
  int unsigned  words_fail;

  function new(mailbox #(bird_transaction) input_obs_mbx,
               mailbox #(bit [31:0])       remote_word_mbx);
    this.input_obs_mbx   = input_obs_mbx;
    this.remote_word_mbx = remote_word_mbx;
    packets       = 0;
    words_checked = 0;
    words_pass    = 0;
    words_fail    = 0;
    clear_state();
  endfunction

  function void clear_state();
    ractive = 1'b0;
    amax    = 0;
    for (int f = 1; f <= 31; f++) begin
      fseen[f] = 1'b0;
      fpay[f].delete();
    end
  endfunction

  function bit all_ready(int unsigned n);
    all_ready = 1'b1;
    for (int f = 1; f <= 31; f++) begin
      if (f <= n && !fseen[f]) all_ready = 1'b0;
    end
  endfunction

  task run();
    bird_transaction tr;
    forever begin
      input_obs_mbx.get(tr);
      if (!tr.is_remote())          continue;  // ignore local fragments
      if (!tr.cfg_obj.is_legal())   continue;  // dropped: no output (Student D extends)
      process(tr);
    end
  endtask

  task process(bird_transaction tr);
    int unsigned rx_seq;
    int unsigned rx_frag;

    rx_seq  = tr.cfg_obj.seq_num;
    rx_frag = tr.cfg_obj.frag_num;

    if (!ractive) begin
      if (rx_seq <= rx_frag) begin
        clear_state();
        ractive = 1'b1;
        store(rx_seq, rx_frag, tr);
      end
    end
    else begin
      if (rx_seq > rx_frag) begin
        // Inconsistent fragment -> drop current packet; restart only on SEQ==1.
        clear_state();
        if (rx_seq == 1) begin
          ractive = 1'b1;
          store(rx_seq, rx_frag, tr);
        end
      end
      else begin
        store(rx_seq, rx_frag, tr);
      end
    end
  endtask

  task store(int unsigned seq, int unsigned frag, bird_transaction tr);
    fseen[seq] = 1'b1;
    fpay[seq].delete();
    foreach (tr.payload[i]) fpay[seq].push_back(tr.payload[i]);

    if (frag > amax) amax = frag;
    if (seq  > amax) amax = seq;

    if (all_ready(amax)) build_and_check();
  endtask

  task build_and_check();
    byte unsigned merged[$];
    byte unsigned merged_arr[];
    bit [31:0]    exp_words[$];
    bit [15:0]    crc;
    bit [31:0]    actual;
    int unsigned  bi;

    // 1) Merge fragments 1..N in order.
    for (int f = 1; f <= amax; f++) begin
      foreach (fpay[f][i]) merged.push_back(fpay[f][i]);
    end

    // 2) Regenerate CRC16 over the merged payload (reuse the shared model).
    merged_arr = new[merged.size()];
    foreach (merged[i]) merged_arr[i] = merged[i];
    crc = bird_transaction::calc_crc16(merged_arr);

    // 3) Pack payload into little-endian 32-bit words, then append CRC word.
    bi = 0;
    while (bi < merged.size()) begin
      bit [31:0] w = 32'h0;
      for (int k = 0; k < 4; k++) begin
        if (bi < merged.size()) begin
          w[8*k +: 8] = merged[bi];
          bi++;
        end
      end
      exp_words.push_back(w);
    end
    exp_words.push_back({16'h0000, crc});

    // 4) Compare predicted words against the observed remote output.
    packets++;
    foreach (exp_words[i]) begin
      remote_word_mbx.get(actual);
      words_checked++;
      if (actual === exp_words[i]) begin
        words_pass++;
      end
      else begin
        words_fail++;
        $display("[%0t] REMOTE_CHK MISMATCH word idx=%0d exp=%08h act=%08h",
                 $time, i, exp_words[i], actual);
      end
    end

    $display("[%0t] REMOTE_CHK checked remote packet: %0d words (incl CRC word), crc=%04h",
             $time, exp_words.size(), crc);

    clear_state();
  endtask

  function void report();
    $display("==== REMOTE CHECKER REPORT: packets=%0d words=%0d pass=%0d fail=%0d -> %s ====",
             packets, words_checked, words_pass, words_fail,
             (words_fail == 0) ? "PASS" : "FAIL");
  endfunction

endclass
