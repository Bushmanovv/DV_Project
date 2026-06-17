class bird_transaction;

  rand bird_cfg cfg_obj;
  rand byte unsigned payload[];

  bit [15:0] crc16;
  string     name;

  constraint payload_size_c {
    payload.size() == cfg_obj.payload_len;
  }

  function new(string name = "bird_transaction");
    this.name = name;
    cfg_obj = new();
  endfunction

  function void post_randomize();
    crc16 = calc_crc16(payload);
  endfunction

  function bit is_local();
    return cfg_obj.traffic_type == 1'b0;
  endfunction

  function bit is_remote();
    return cfg_obj.traffic_type == 1'b1;
  endfunction

  function bit [31:0] cfg();
    return cfg_obj.pack();
  endfunction

  function int unsigned stream_size();
    return payload.size() + 2;
  endfunction

  function byte unsigned stream_byte(int unsigned index);
    if (index < payload.size()) begin
      return payload[index];
    end
    else if (index == payload.size()) begin
      return crc16[15:8];
    end
    else begin
      return crc16[7:0];
    end
  endfunction

  function void set_local_packet(int unsigned length = 4, bit [4:0] seq_num = 5'd1);
    cfg_obj.traffic_type = 1'b0;
    cfg_obj.payload_len = byte'(length);
    cfg_obj.frag_num = 5'd1;
    cfg_obj.seq_num = seq_num;
    cfg_obj.reserved_7_1 = 7'd0;
    cfg_obj.reserved_23_21 = 3'd0;
    cfg_obj.reserved_31_29 = 3'd0;

    payload = new[length];
    foreach (payload[i]) begin
      payload[i] = byte'(8'h10 + i);
    end

    crc16 = calc_crc16(payload);
  endfunction

  function string sprint();
    string text;

    text = $sformatf("%s %s crc16=0x%04h payload=", name, cfg_obj.sprint(), crc16);
    foreach (payload[i]) begin
      text = {text, $sformatf("%02h ", payload[i])};
    end

    return text;
  endfunction

  static function bit [15:0] calc_crc16(input byte unsigned data[]);
    bit [15:0] crc;

    crc = 16'hffff;
    foreach (data[i]) begin
      crc ^= {data[i], 8'h00};
      repeat (8) begin
        if (crc[15]) begin
          crc = (crc << 1) ^ 16'h1021;
        end
        else begin
          crc = crc << 1;
        end
      end
    end

    return crc;
  endfunction

endclass
