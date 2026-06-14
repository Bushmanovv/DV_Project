//------------------------------------------------------------------------------
// bird_base_seq.sv  -  sequences for the BIRD input interface
//
// Provides a base sequence plus a couple of starter sequences. Extend these for
// the remaining test-plan items (reorder, drops, backpressure, reset, ...).
//------------------------------------------------------------------------------
`ifndef BIRD_BASE_SEQ_SV
`define BIRD_BASE_SEQ_SV

// Base: nothing on its own, just a common parent.
class bird_base_seq extends uvm_sequence #(bird_seq_item);
  `uvm_object_utils(bird_base_seq)
  function new(string name = "bird_base_seq"); super.new(name); endfunction
endclass

// A single well-formed LOCAL packet.
class bird_local_seq extends bird_base_seq;
  `uvm_object_utils(bird_local_seq)
  function new(string name = "bird_local_seq"); super.new(name); endfunction

  task body();
    `uvm_do_with(req, { traffic_type == 0; frag_num == 1; })
  endtask
endclass

// A REMOTE packet of `n_frags` fragments, same SEQ_NUM, optionally shuffled.
class bird_remote_seq extends bird_base_seq;
  `uvm_object_utils(bird_remote_seq)

  rand int unsigned n_frags;
  rand bit          shuffle;
  constraint c_nfrags { n_frags inside {[1:8]}; }

  function new(string name = "bird_remote_seq"); super.new(name); endfunction

  task body();
    int order[$];
    bit [4:0] seq;
    seq = $urandom_range(1, 31);
    for (int i = 1; i <= n_frags; i++) order.push_back(i);
    if (shuffle) order.shuffle();

    foreach (order[i]) begin
      `uvm_do_with(req, { traffic_type == 1;
                          seq_num == seq;
                          frag_num == order[i]; })
    end
  endtask
endclass

`endif // BIRD_BASE_SEQ_SV
