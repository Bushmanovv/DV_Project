class bird_cfg;

  rand bit        traffic_type;
  rand bit [7:0]  payload_len;
  rand bit [4:0]  frag_num;
  rand bit [4:0]  seq_num;

  bit [6:0] reserved_7_1;
  bit [2:0] reserved_23_21;
  bit [2:0] reserved_31_29;

  constraint legal_c {
    payload_len inside {[1:255]};
    frag_num    inside {[1:31]};
    seq_num     inside {[1:31]};
    reserved_7_1 == 7'd0;
    reserved_23_21 == 3'd0;
    reserved_31_29 == 3'd0;
  }

  function new();
    traffic_type   = 1'b0;
    payload_len    = 8'd1;
    frag_num       = 5'd1;
    seq_num        = 5'd1;
    reserved_7_1   = 7'd0;
    reserved_23_21 = 3'd0;
    reserved_31_29 = 3'd0;
  endfunction

  function bit [31:0] pack();
    bit [31:0] value;

    value[0]     = traffic_type;
    value[7:1]   = reserved_7_1;
    value[15:8]  = payload_len;
    value[20:16] = frag_num;
    value[23:21] = reserved_23_21;
    value[28:24] = seq_num;
    value[31:29] = reserved_31_29;

    return value;
  endfunction

  function void unpack(bit [31:0] value);
    traffic_type   = value[0];
    reserved_7_1   = value[7:1];
    payload_len    = value[15:8];
    frag_num       = value[20:16];
    reserved_23_21 = value[23:21];
    seq_num        = value[28:24];
    reserved_31_29 = value[31:29];
  endfunction

  function bit is_legal();
    if (payload_len < 1) begin
      return 1'b0;
    end

    if (reserved_7_1 != 0 || reserved_23_21 != 0 || reserved_31_29 != 0) begin
      return 1'b0;
    end

    if (traffic_type == 1'b0) begin
      return (frag_num == 5'd1) && (seq_num == 5'd1);
    end

    return (frag_num >= 1) && (seq_num >= 1);
  endfunction

  function string sprint();
    return $sformatf(
      "cfg traffic_type=%0d payload_len=%0d frag_num=%0d seq_num=%0d rsv7_1=%0h rsv23_21=%0h rsv31_29=%0h packed=0x%08h",
      traffic_type,
      payload_len,
      frag_num,
      seq_num,
      reserved_7_1,
      reserved_23_21,
      reserved_31_29,
      pack()
    );
  endfunction

endclass
