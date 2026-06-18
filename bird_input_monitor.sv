// ============================================================
// bird_input_monitor.sv  -  Student C
// Observes the input interface and reconstructs ONE bird_transaction
// per fragment (cfg + payload bytes + 2 CRC bytes), then broadcasts it
// to every subscriber mailbox (local checker, remote checker, coverage...).
// ============================================================
class bird_input_monitor;

  virtual bird_if vif;

  // Multiple consumers can subscribe to the observed input stream.
  mailbox #(bird_transaction) subscribers[$];

  function new(virtual bird_if vif, mailbox #(bird_transaction) obs_mbx = null);
    this.vif = vif;
    if (obs_mbx != null) begin
      subscribers.push_back(obs_mbx);
    end
  endfunction

  // Let the env attach extra consumers (e.g. the remote checker / coverage).
  function void add_subscriber(mailbox #(bird_transaction) mbx);
    subscribers.push_back(mbx);
  endfunction

  task run();
    bit [31:0]    frag_cfg;
    byte unsigned buffer[$];
    int unsigned  need;
    bit           in_frag;

    in_frag = 1'b0;
    buffer.delete();

    forever begin
      @(vif.mon_cb);

      // Drop any partial fragment on reset.
      if (vif.mon_cb.rst_n !== 1'b1) begin
        in_frag = 1'b0;
        buffer.delete();
        continue;
      end

      // A byte transfers only when in_vld && in_rdy.
      if (vif.mon_cb.in_vld === 1'b1 && vif.mon_cb.in_rdy === 1'b1) begin
        if (!in_frag) begin
          // First byte of a fragment: cfg is sampled on this same cycle.
          frag_cfg = vif.mon_cb.cfg;
          need     = frag_cfg[15:8] + 2;   // PAYLOAD_LEN + 2 CRC bytes
          buffer.delete();
          in_frag  = 1'b1;
        end

        buffer.push_back(vif.mon_cb.data_in);

        if (buffer.size() >= need) begin
          publish_fragment(frag_cfg, buffer);
          in_frag = 1'b0;
          buffer.delete();
        end
      end
    end
  endtask

  function void publish_fragment(bit [31:0] cfg_word, byte unsigned bytes[$]);
    bird_transaction tr;
    int unsigned     plen;

    tr   = new("observed_input");
    tr.cfg_obj.unpack(cfg_word);
    plen = cfg_word[15:8];

    tr.payload = new[plen];
    for (int unsigned i = 0; i < plen; i++) begin
      tr.payload[i] = bytes[i];
    end

    // Trailing 2 bytes are the (input) CRC, forwarded as-is on the local path.
    if (bytes.size() >= plen + 2) begin
      tr.crc16 = {bytes[plen], bytes[plen+1]};
    end

    foreach (subscribers[i]) begin
      subscribers[i].put(tr);
    end

    $display("[%0t] INPUT_MON observed: %s", $time, tr.sprint());
  endfunction

endclass
