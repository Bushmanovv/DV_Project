module bird_test(bird_if vif);

  import bird_pkg::*;

  bird_base_test test;
  string test_name;

  initial begin
    if (!$value$plusargs("TEST=%s", test_name)) begin
      test_name = "reset_clears_all_outputs_test";
    end

    case (test_name)

      "reset_clears_all_outputs_test": begin
        reset_clears_all_outputs_test t;
        t = new(vif);
        test = t;
      end

      "valid_ready_basic_transfer_test": begin
        valid_ready_basic_transfer_test t;
        t = new(vif);
        test = t;
      end

      "backpressure_stability_test": begin
        backpressure_stability_test t;
        t = new(vif);
        test = t;
      end

      "cfg_sampled_on_first_payload_byte_test": begin
        cfg_sampled_on_first_payload_byte_test t;
        t = new(vif);
        test = t;
      end

      // ---- Student B: local traffic tests (TP05-TP06) ----
      "local_basic_test": begin
        local_basic_test t;
        t = new(vif);
        test = t;
      end

      "local_payload_boundary_test": begin
        local_payload_boundary_test t;
        t = new(vif);
        test = t;
      end

      // ---- Student C: remote traffic tests (TP08-TP11) ----
      "remote_basic_test": begin
        remote_basic_test t;
        t = new(vif);
        test = t;
      end

      "remote_inorder_test": begin
        remote_inorder_test t;
        t = new(vif);
        test = t;
      end

      "remote_reorder_test": begin
        remote_reorder_test t;
        t = new(vif);
        test = t;
      end

      "remote_crc_test": begin
        remote_crc_test t;
        t = new(vif);
        test = t;
      end

      // ---- Student D: negative / drop tests (TP12-TP15) ----
      "invalid_cfg_test": begin
        invalid_cfg_test t;
        t = new(vif);
        test = t;
      end

      "remote_protocol_test": begin
        remote_protocol_test t;
        t = new(vif);
        test = t;
      end

      "drop_count_test": begin
        drop_count_test t;
        t = new(vif);
        test = t;
      end

      "drop_wrap_test": begin
        drop_wrap_test t;
        t = new(vif);
        test = t;
      end

      // ---- Student D: TP25 mixed + TP26 random regression ----
      "mixed_traffic_test": begin
        mixed_traffic_test t;
        t = new(vif);
        test = t;
      end

      "random_regression_test": begin
        random_regression_test t;
        t = new(vif);
        test = t;
      end

      default: begin
        $display("ERROR: Unknown TEST=%s", test_name);
        $finish;
      end

    endcase

    test.run();
    $finish;
  end

endmodule
