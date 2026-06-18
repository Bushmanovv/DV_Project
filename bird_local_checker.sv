
class bird_local_checker;

  mailbox #(bird_transaction) input_obs_mbx;
  mailbox #(byte unsigned)    local_byte_mbx;

  int unsigned checks;
  int unsigned passes;
  int unsigned fails;

  function new(mailbox #(bird_transaction) input_obs_mbx,
               mailbox #(byte unsigned)    local_byte_mbx);
    this.input_obs_mbx  = input_obs_mbx;
    this.local_byte_mbx = local_byte_mbx;
    checks = 0;
    passes = 0;
    fails  = 0;
  endfunction

  task run();
    bird_transaction tr;
    forever begin
      input_obs_mbx.get(tr);
      // Only legal LOCAL fragments produce local output.
      if (tr.is_local() && tr.cfg_obj.is_legal()) begin
        check_local(tr);
      end
    end
  endtask

  task check_local(bird_transaction tr);
    byte unsigned expected[$];
    byte unsigned actual;

    foreach (tr.payload[i]) expected.push_back(tr.payload[i]);
    expected.push_back(tr.crc16[15:8]);  // CRC high byte
    expected.push_back(tr.crc16[7:0]);   // CRC low byte

    foreach (expected[i]) begin
      local_byte_mbx.get(actual);
      checks++;
      if (actual === expected[i]) begin
        passes++;
      end
      else begin
        fails++;
        $display("[%0t] LOCAL_CHK MISMATCH idx=%0d exp=%02h act=%02h",
                 $time, i, expected[i], actual);
      end
    end

    $display("[%0t] LOCAL_CHK checked local packet (%0d bytes)", $time, expected.size());
  endtask

  function void report();
    $display("==== LOCAL CHECKER REPORT: checks=%0d passes=%0d fails=%0d -> %s ====",
             checks, passes, fails, (fails == 0) ? "PASS" : "FAIL");
  endfunction

endclass
