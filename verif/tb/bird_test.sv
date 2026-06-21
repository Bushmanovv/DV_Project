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

      "local_backpressure_test": begin
        local_backpressure_test t;
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
