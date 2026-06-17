module bird_test(bird_if vif);

  import bird_pkg::*;

  bird_base_test test;
  string test_name;

  initial begin
    local_basic_test local_test;

    if (!$value$plusargs("TEST=%s", test_name)) begin
      test_name = "local_basic_test";
    end

    case (test_name)
      "local_basic_test": begin
        local_test = new(vif);
        test = local_test;
      end

      default: begin
        $fatal(1, "Unknown TEST=%s", test_name);
      end
    endcase

    test.run();
  end

endmodule
