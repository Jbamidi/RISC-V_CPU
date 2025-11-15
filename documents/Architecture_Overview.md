# 🧠 CPU Architecture Overview (Single-Cycle + Pipelined RV32I)

This document describes the **datapath**, **control flow**, and **pipeline structure** of the RISC-V CPU.  
It now includes both the **single-cycle** implementation and the full **5-stage pipelined RV32I core** with hazard detection, forwarding, and branch flushing.

---

## 🧩 Core Design Philosophy
The CPU implements the **RISC-V RV32I** base instruction set.

### Single-Cycle Version
- All instructions complete in **one clock cycle**
- Simple: ideal for understanding instruction flow
- Harvard architecture (separate IMEM + DMEM)

### Pipelined Version (5-Stage)
- Fully overlapped instruction execution
- Implements:
  - **Forwarding unit** (EX→EX, MEM→EX)
  - **Load-use hazard stall**
  - **Branch + JAL/JALR flush logic**
- Pipeline registers between all stages (IF/ID, ID/EX, EX/MEM, MEM/WB)

---

## ⚙️ Main Components

| Module | Function |
|--------|----------|
| `pc_counter` | Program Counter register, gated by hazard logic |
| `imem` | Instruction memory, initialized from `imem_data.hex` |
| `control_unit` | Decodes the opcode and sets control signals |
| `ALU_Control` | Selects ALU operation (funct3, funct7, ALU_Op) |
| `regfile` | 32×32 register file, x0 = 0 |
| `imm_gen` | Immediate generator for I/S/B/U/J formats |
| `ALU` | Arithmetic, logic, shift, and comparison operations |
| `dmem` | Data memory (LW, SW) |
| `pc_next` | Calculates next PC (PC+4, branch target, JAL, JALR) |
| `hazard_detection` | Detects load-use hazards and stalls IF/ID, flushes ID/EX |
| `forwarding_unit` | Resolves RAW hazards between EX/MEM and MEM/WB |
| `if_id_reg` | Pipeline register for fetched instruction and PC+4 |
| `id_ex_reg` | Pipeline register for decode → execute |
| `ex_mem_reg` | Pipeline register for execute → memory |
| `mem_wb_reg` | Pipeline register for memory → writeback |
| `cpu_top_singlecycle` | Top module for the single-cycle CPU |
| `cpu_top_pipeline` | Top module for the pipelined CPU |

---

## 🧠 Datapath Overview

### 📍 Single-Cycle Datapath
All five classic stages execute **in one clock**:

1. **IF — Instruction Fetch**  
   - IMEM[PC] → instruction
2. **ID — Instruction Decode**  
   - Control unit + register file + immediate generator
3. **EX — Execute**  
   - ALU operation  
   - Branch decision made here
4. **MEM — Memory Access**  
   - LW/SW operations
5. **WB — Writeback**  
   - ALU result or load data written to registers

The single-cycle design is pure combinational logic feeding into one large rising-edge PC update.

---

## 🧠 5-Stage Pipelined Datapath

### Stages run **simultaneously**:
1. **IF** — Fetch new instruction  
2. **ID** — Decode previous instruction  
3. **EX** — Execute even earlier instruction  
4. **MEM** — Read/write data  
5. **WB** — Write back result to regfile  

Pipeline registers separate each stage:
- `IF/ID`  
- `ID/EX`  
- `EX/MEM`  
- `MEM/WB`  

---

## 🛡️ Hazard Resolution

### ✔️ Data Hazards
- **Forwarding Unit** handles EX→EX and MEM→EX RAW hazards
- **Load-Use Stall**  
  If EX instruction is a load and ID needs its result →  
  → stall PC + IF/ID for one cycle and flush ID/EX

### ✔️ Control Hazards
- Branch, JAL, JALR are resolved in **EX stage**
- Upon branch_taken = 1:
  - Flush IF/ID and ID/EX
  - Redirect PC to target

---

## 🔗 Next Step
With forwarding, stalls, and flush logic complete, this CPU is now ready for:
- Branch predictor integration  
- Cache subsystem  
- FPGA synthesis  
- Superscalar or out-of-order experiments

The pipelined design is now a **stable backbone** for more advanced microarchitecture projects.
