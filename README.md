# 🧠 RISC-V Single-Cycle CPU Core (RV32I)

This repository contains a **32-bit single-cycle RISC-V CPU** implemented in **SystemVerilog**, designed and simulated from scratch.  
It executes the full **RV32I base instruction set**, featuring arithmetic, logic, load/store, branch, and jump instructions.

The design follows a clean, modular datapath-and-control architecture — easy to extend into a pipelined implementation.

---

## ⚙️ Overview

| Feature | Description |
|----------|-------------|
| **ISA** | RISC-V RV32I |
| **Architecture** | Single-cycle CPU core |
| **Language** | SystemVerilog |
| **Simulation Tool** | [EDA Playground](https://www.edaplayground.com/) or any Verilog simulator |
| **Memory** | 1 KB Instruction Memory (IMEM), 1 KB Data Memory (DMEM) |
| **Registers** | 32 × 32-bit general-purpose registers |
| **Clocking** | Positive-edge-triggered, single clock domain |
| **Endianness** | Little-endian (RV32 standard) |

---

## 🧩 Module Breakdown

| Module | Purpose |
|---------|----------|
| **`cpu_top.sv`** | Top-level integration of datapath and control logic |
| **`pc_counter.sv`** | Program Counter (holds current instruction address) |
| **`imem.sv`** | Instruction memory (read-only ROM, loads from `imem_data.hex`) |
| **`regfile.sv`** | 32 × 32-bit register file (x0 hardwired to 0) |
| **`ALU.sv`** | Arithmetic/logic operations (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU) |
| **`ALU_Control.sv`** | Decodes `funct3`, `funct7`, and `ALU_Op` to select ALU operation |
| **`control_unit.sv`** | Main control logic (sets `RegWrite`, `ALU_Src`, `MemRead`, etc.) |
| **`imm_gen.sv`** | Immediate generator for I, S, B, U, and J-type formats |
| **`dmem.sv`** | Data memory (combinational read, synchronous write) |
| **`pc_next.sv`** | Calculates next PC for sequential, branch, JAL, and JALR execution |

---

## 🧾 Example Program (`imem_data.hex`)

```text
00500093   // addi x1, x0, 5
00A00113   // addi x2, x0, 10
002081B3   // add  x3, x1, x2   -> x3 = 15
```

When simulated:
```text
pc: 0x00000000 → 0x00000004 → 0x00000008
x1 = 5, x2 = 10, x3 = 15
```

---

## 🧠 Supported Instructions

| Category | Example | Description |
|-----------|----------|-------------|
| **R-Type** | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU | Register arithmetic/logic |
| **I-Type** | ADDI, ANDI, ORI, XORI, SLTI | Immediate arithmetic |
| **Load/Store** | LW, SW | Data memory access |
| **Branch** | BEQ, BNE, BLT, BGE, BLTU, BGEU | Conditional branching |
| **Jump** | JAL, JALR | Unconditional jump and link |
| **U-Type** | LUI, AUIPC | Upper immediate operations |

---

## 🧪 Simulation Setup (EDA Playground)

1. Upload all `.sv` files and `imem_data.hex`
2. Set **Top module** → `cpu_top`
3. Use **SystemVerilog 2012** + **EPWave** waveform viewer
4. Add a simple clock and reset testbench:
   ```systemverilog
   always #5 clk = ~clk;
   initial begin
     reset = 1; #10; reset = 0;
     #200 $finish;
   end
   ```
5. Run simulation and watch `pc`, `instr`, `ALU_res`, and `reg_write_data`

---

## 📚 Design Highlights

- Clean, modular design → every functional block in its own file  
- One-hot style ALU control for faster synthesis  
- Safe combinational blocks (no latches)  
- Harvard-style architecture (separate IMEM & DMEM)  
- Easy path to pipelined and multi-cycle versions  

---

## 🧭 Future Extensions (To-Do Checklist)

- [x] Full single-cycle RV32I implementation  
- [ ] Add hazard detection and forwarding unit for pipelined version  
- [ ] Implement 5-stage pipeline (IF, ID, EX, MEM, WB)  
- [ ] Add branch predictor and pipeline flush logic  
- [ ] Add CSR and ECALL support for system instructions  
- [ ] Integrate UART I/O or GPIO memory-mapped peripheral  
- [ ] Synthesize to FPGA (e.g., Intel/Altera or Xilinx board)  
- [ ] Add unit tests for each instruction type  
- [ ] Optimize ALU with carry-lookahead adder / DSP inference  
- [ ] Add simple cache layer and prefetch buffer  
- [ ] Write detailed project documentation and block diagrams  

---

👤 **Author:** Jashwanth Bamidi 

