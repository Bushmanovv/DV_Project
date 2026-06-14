//------------------------------------------------------------------------------
// bird_seq_item.sv  -  BIRD fragment/packet transaction
//
// One item == one fragment driven on the input interface (payload bytes + CRC16),
// described by the 32-bit cfg sideband word (Spec Section 5).
//------------------------------------------------------------------------------
`ifndef BIRD_SEQ_ITEM_SV
`define BIRD_SEQ_ITEM_SV

class bird_seq_item extends uvm_sequence_item;

  // ---- cfg fields (Spec 5) ----
  rand bit        traffic_type;        // cfg[0]    0=local, 1=remote
  rand bit [7:0]  payload_len;         // cfg[15:8] 1..255
  rand bit [4:0]  frag_num;            // cfg[20:16] 1..31
  rand bit [4:0]  seq_num;             // cfg[28:24] 1..31 (0 invalid)
  rand bit [6:0]  rsvd_7_1;            // cfg[7:1]   must be 0 (rand for drop tests)
  rand bit [2:0]  rsvd_23_21;          // cfg[23:21] must be 0
  rand bit [2:0]  rsvd_31_29;          // cfg[31:29] must be 0

  // ---- payload + crc ----
  rand bit [7:0]  payload[];           // payload_len bytes
  rand bit [15:0] crc16;               // CRC16 over payload (input side)

  // ---- back-pressure pacing (driver hint, not driven onto bus) ----
  rand int unsigned pre_delay;         // idle cycles before this fragment

  // ---- expected disposition (filled by reference model, for debug) ----
  bit             expect_drop;

  `uvm_object_utils_begin(bird_seq_item)
    `uvm_field_int(traffic_type, UVM_ALL_ON)
    `uvm_field_int(payload_len,  UVM_ALL_ON)
    `uvm_field_int(frag_num,     UVM_ALL_ON)
    `uvm_field_int(seq_num,      UVM_ALL_ON)
    `uvm_field_int(rsvd_7_1,     UVM_ALL_ON)
    `uvm_field_int(rsvd_23_21,   UVM_ALL_ON)
    `uvm_field_int(rsvd_31_29,   UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(crc16,        UVM_ALL_ON)
    `uvm_field_int(pre_delay,    UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(expect_drop,  UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "bird_seq_item");
    super.new(name);
  endfunction

  // ---- Default = legal, well-formed fragment ----
  constraint c_len_valid    { payload_len inside {[1:255]}; }
  constraint c_frag_valid   { frag_num inside {[1:31]}; }
  constraint c_seq_valid    { seq_num inside {[1:31]}; }
  constraint c_rsvd_zero    { rsvd_7_1 == 0; rsvd_23_21 == 0; rsvd_31_29 == 0; }
  constraint c_payload_size { payload.size() == payload_len; }
  constraint c_local_frag   { (traffic_type == 0) -> frag_num == 1; } // Spec 6
  constraint c_delay        { pre_delay inside {[0:5]}; }

  // ---- Pack the 32-bit cfg word ----
  function bit [31:0] get_cfg();
    bit [31:0] c = '0;
    c[0]      = traffic_type;
    c[7:1]    = rsvd_7_1;
    c[15:8]   = payload_len;
    c[20:16]  = frag_num;
    c[23:21]  = rsvd_23_21;
    c[28:24]  = seq_num;
    c[31:29]  = rsvd_31_29;
    return c;
  endfunction

  // ---- Unpack a cfg word into fields (monitor side) ----
  function void set_cfg(bit [31:0] c);
    traffic_type = c[0];
    rsvd_7_1     = c[7:1];
    payload_len  = c[15:8];
    frag_num     = c[20:16];
    rsvd_23_21   = c[23:21];
    seq_num      = c[28:24];
    rsvd_31_29   = c[31:29];
  endfunction

  // ---- CRC16 over payload bytes ----
  // NOTE: polynomial/init/refin/refout are NOT given in the spec excerpt.
  //       Match this to the actual rtl/bird.sv implementation before relying on
  //       it in the scoreboard. Placeholder below = CRC-16-CCITT (0x1021, init 0xFFFF).
  function bit [15:0] compute_crc16(bit [7:0] data[]);
    bit [15:0] crc = 16'hFFFF;
    foreach (data[i]) begin
      crc ^= (data[i] << 8);
      for (int b = 0; b < 8; b++)
        crc = crc[15] ? (crc << 1) ^ 16'h1021 : (crc << 1);
    end
    return crc;
  endfunction

  // ---- Convenience: is this fragment malformed per Spec 8.1 (self-contained checks)? ----
  function bit is_self_invalid();
    return (seq_num == 0) || (frag_num == 0) ||
           (payload_len == 0) ||
           (rsvd_7_1 != 0) || (rsvd_23_21 != 0) || (rsvd_31_29 != 0);
  endfunction

endclass

`endif // BIRD_SEQ_ITEM_SV
