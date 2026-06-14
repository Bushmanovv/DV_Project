# BIRD Verification — Project Checklist

**Course:** ENCS5337 Chip Design Verification · **Deadline:** 20/6/2026 23:59
**DUT:** BIRD packet router (EDA Playground: https://www.edaplayground.com/x/UtWv)
> ⏰ ~6 days left. Late penalty = 10%/day. Prioritize a *working* end-to-end TB early, then grow coverage.

---

## 0. Setup & logistics
- [ ] Copy the DUT (`bird.sv`) from EDA Playground into [`rtl/`](rtl/) so the TB can compile.
- [ ] Confirm the EDA server account works; clone the GitHub repo there as the Git client.
- [ ] Server folder named `BIRD_<student_id>` (e.g. `BIRD_1210288`) — required by spec.
- [ ] Agree on tool/simulator (Questa/VCS/Xcelium on the server) and a single `sim/Makefile` flow.
- [ ] Split work across the 4 members and make **each member commit their own parts** (grading is per-student via commits).

## 1. Read & extract requirements (do this first)
- [ ] Re-read [`docs/BIRD_Specification.pdf`](docs/BIRD_Specification.pdf) and list every testable rule.
- [ ] Note the `cfg[31:0]` field map: `[0]`TRAFFIC_TYPE, `[15:8]`PAYLOAD_LEN(1–255), `[20:16]`FRAG_NUM(1–31), `[28:24]`SEQ_NUM(1–31), reserved `[7:1]`/`[23:21]`/`[31:29]` must be 0.
- [ ] Note all 7 drop conditions and the `drop_cnt` (mod-2¹⁶, +1 per *packet*, wrap-around) behavior.

## 2. Test plan (Deliverable #1 — `testplan/`)
- [ ] Create the test plan (Excel) with columns: ID, Feature, Description, Stimulus, Expected, Test name, Coverage link.
- [ ] **Map each test-plan item to a concrete test name** (Deliverable #2). One test may cover several items.
- [ ] Cover at minimum (from spec §10 "Notes for Verification"):
  - [ ] Local vs remote classification (`cfg[0]`)
  - [ ] Valid/ready handshake + **stability under backpressure** (data stable while `vld=1,rdy=0`)
  - [ ] FRAG_NUM / SEQ_NUM correct usage
  - [ ] Fragment **reordering** + merged-payload correctness
  - [ ] **CRC16 regeneration** on remote output (input CRC forwarded unchanged on local)
  - [ ] Silent drop for *each* of the 7 drop conditions
  - [ ] `drop_cnt` increment + **wrap-around**
  - [ ] Reset behavior (outputs deasserted, buffers cleared, in-progress packet discarded, `drop_cnt=0`)
  - [ ] Boundary payload lengths (1, 255) and fragment counts (1, 31)

## 3. UVM testbench (Deliverable #3 — `tb/`)
### Infrastructure
- [ ] `tb/top/` — `tb_top`, DUT instantiation, clock gen, reset, interface, **clocking blocks**.
- [ ] Interface(s) with modports for input / local-out / remote-out + status (`drop_cnt`).
### Sequence layer
- [ ] `tb/sequences/` — sequence item (payload bytes, CRC, full `cfg` fields) + sequences (local, remote multi-frag, out-of-order, malformed/drop, backpressure, reset-mid-packet).
### Agents (`tb/agents/`)
- [ ] `input_agent/` — driver (drives `data_in`, `in_vld`, `cfg`; honors `in_rdy`) + monitor + sequencer.
- [ ] `local_agent/` — monitor + ready driver (backpressure on `local_rdy`).
- [ ] `remote_agent/` — monitor + ready driver (backpressure on `remote_rdy`).
### Environment (`tb/env/`)
- [ ] Reference model: classify, accumulate/reorder fragments, merge payload, **recompute CRC16**, model drop rules + `drop_cnt`.
- [ ] **Scoreboard/checker** comparing DUT outputs vs reference model.
- [ ] Functional **coverage** model (covergroups on `cfg` fields, frag counts, drop reasons, backpressure, crosses).
- [ ] Assertions (SVA) for handshake transfer/stability rules.
- [ ] **End-of-test reporting** (pass/fail summary, counts, `UVM_ERROR`/`UVM_FATAL` tally).
### Tests (`tb/tests/`)
- [ ] `base_test` (build env, config, default sequences) + one test per major scenario from the test plan.

## 4. Coverage (Deliverable #4 — `coverage/`)
- [ ] Generate **code coverage** report (statement/branch/toggle/FSM) — aim high, explain any exclusions.
- [ ] Generate **functional coverage** report — close coverage holes by adding/constraining sequences.
- [ ] Save both reports into [`coverage/`](coverage/).

## 5. Run & debug
- [ ] `sim/` Makefile targets: compile, run single test, run regression, merge coverage.
- [ ] All tests pass with 0 `UVM_ERROR` / 0 `UVM_FATAL`.
- [ ] Waveform-debug at least the reorder + CRC + drop paths to confirm checker is real.

## 6. Submission & discussion prep
- [ ] Everything pushed to GitHub **and** mirrored to the EDA server git client folder.
- [ ] Repo contains: all TB code, test plan file, code-coverage report, functional-coverage report.
- [ ] Update the deliverables checkboxes in [`README.md`](README.md).
- [ ] Verify the commit history clearly shows each member's contribution.
- [ ] Each member can **explain their own code** in the discussion (grading is individual).
- [ ] Freeze the repo before the deadline — no edits after 20/6 23:59.
