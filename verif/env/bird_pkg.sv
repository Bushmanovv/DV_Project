package bird_pkg;

  typedef enum bit {
    BIRD_LOCAL  = 1'b0,
    BIRD_REMOTE = 1'b1
  } bird_traffic_type_e;

  `include "bird_cfg.sv"
  `include "bird_transaction.sv"
  `include "bird_generator.sv"
  `include "bird_driver.sv"
  `include "bird_input_monitor.sv"
  `include "bird_local_monitor.sv"
  `include "bird_remote_monitor.sv"
  `include "bird_local_checker.sv"
  `include "bird_agent.sv"
  `include "bird_env.sv"
  `include "bird_base_sequence.sv"
  `include "bird_local_sequence.sv"
  `include "bird_base_test.sv"
  `include "reset_clears_all_outputs_test.sv"
  `include "valid_ready_basic_transfer_test.sv"
  `include "backpressure_stability_test.sv"
  `include "cfg_sampled_on_first_payload_byte_test.sv"

endpackage

