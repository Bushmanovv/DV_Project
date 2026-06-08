# BIRD — Birzeit Integrated Router Design (Verification)

Verification environment for **BIRD**, a packet-based routing block, built for
**ENCS5337 – Chip Design Verification** at Birzeit University (Spring 2025/2026).

## About the DUT

BIRD receives traffic on a single input interface and routes it to one of two
outputs based on a 32-bit sideband configuration word (`cfg`):

- **Local traffic** (`cfg[0]=0`) — a single fragment forwarded directly to the local output.
- **Remote traffic** (`cfg[0]=1`) — multiple fragments accumulated, reordered by
  `FRAG_NUM`, merged, and re-emitted as one packet with a regenerated CRC16.

Invalid/malformed packets are **silently dropped** and counted in `drop_cnt`.
Full details are in [`docs/BIRD_Specification.pdf`](docs/BIRD_Specification.pdf).

The DUT and a basic smoke test are on EDA Playground: https://www.edaplayground.com/x/UtWv

## Repository structure

```
.
├── docs/        # Project specification & requirements (PDF)
├── rtl/         # Design Under Test (DUT) — copied from EDA Playground
├── tb/          # SystemVerilog/UVM testbench
│   ├── top/         # tb_top, interface, clocking blocks
│   ├── env/         # environment, scoreboard/checker, coverage
│   ├── agents/      # driver + monitor + sequencer per interface
│   │   ├── input_agent/
│   │   ├── local_agent/
│   │   └── remote_agent/
│   ├── sequences/   # sequence items & sequences
│   └── tests/       # base test + individual tests
├── sim/         # Makefile / run scripts / compile filelists
├── testplan/    # test plan (Excel) + test-name mapping
└── coverage/    # code & functional coverage reports
```

## Deliverables (per project spec)

- [ ] Test plan (Excel) — `testplan/`
- [ ] Test-name mapping for each test plan item
- [ ] Full UVM testbench: interface/clocking, env, agents, drivers, monitors,
      checkers, sequences, end-of-test reporting, tests — `tb/`
- [ ] Code coverage report — `coverage/`
- [ ] Functional coverage report — `coverage/`

**Deadline:** 20/6/2026 23:59 · Collaboration is graded via individual GitHub commits.

## Team

| Name | Student ID |
| ---- | ---------- |
| Abdalkarim Dwikat | 1210288 |
| Qussai Assi | 1211204 |
| Ibrahim Ardah | 1220874 |
| Maen Foqaha | 1220847 |
