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
  `include "local_basic_test.sv"

endpackage

