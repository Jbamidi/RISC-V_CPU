module cpu_top_pipeline(input logic clk, input logic reset,
output logic [31:0] pc, output logic [31:0] op_instr,output logic [31:0] ALU_res, output logic [31:0] reg_write_data,output logic [4:0] reg_write_addr,
output logic reg_debug);

//Instruction bits
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;

//PC
logic [31:0] pc_next;
logic [31:0] jal_data_link;

//Control Signals
logic RegWrite, ALU_Src, MemRead,MemWrite,MemToReg,Branch;
logic [1:0] ALU_Op;
logic [3:0] ALU_Sel;

//ALU
logic [31:0] imm_out;
logic [31:0] ALU_b;
logic [31:0] dmem_data;
logic [31:0] rd1;
logic [31:0] rd2;

//Pipeline Signals
logic stall;
logic flush;

assign stall = 1'b0;
assign flush = 1'b0;

//IF/ID signals
logic [31:0] pc_plus_4_in_if;
logic [31:0] pc_plus_4_out_if;
logic [31:0] instr_in;
logic [31:0] instr_out;

//ID/EX signals
logic [31:0] rd1_ex;
logic [31:0] rd2_ex;
logic [31:0] imm_ex;
logic [31:0] pc_plus_4_ex;
logic [4:0]  rs1_ex;
logic [4:0]  rs2_ex;
logic [4:0]  rd_ex;
logic [2:0]  funct3_ex;
logic [6:0]  funct7_ex;
logic [6:0]  opcode_ex;
logic        RegWrite_ex, ALU_Src_ex, MemRead_ex, MemWrite_ex, MemToReg_ex, Branch_ex;
logic [1:0]  ALU_Op_ex;
logic [31:0] instr_ex;

//EX/MEM signals
logic [31:0] ALU_res_mem;
logic [31:0] store_data_mem;
logic [4:0]  rd_mem;
logic        RegWrite_mem, MemRead_mem, MemWrite_mem, MemToReg_mem;
logic [6:0]  opcode_mem;
logic [31:0] pc_plus_4_mem;
logic [31:0] instr_mem;

//MEM/WB signals
logic [31:0] read_data_wb;
logic [31:0] ALU_res_wb;
logic [4:0]  rd_wb;
logic        RegWrite_wb, MemToReg_wb;
logic [6:0]  opcode_wb;
logic [31:0] pc_plus_4_wb;
logic [31:0] instr_wb;

//Hazard Detection
logic pc_en;
logic id_ex_flush;
logic if_id_en;




//Stage 1 - Instruction Fetch

//PC Counter
pc_counter pc_counter(
    .clk(clk),
    .reset(reset),
    .pc(pc),
    .pc_en(pc_en),
    .pc_next(pc_next)
);

//Getting correct instructions based on PC
imem imem_instruction(
    .addr(pc),
    .instr(instr_in)
);

// IF/ID pipeline Register
assign pc_plus_4_in_if = pc + 32'd4;

if_id_reg if_id(
    .clk(clk),
    .reset(reset),
    .pc_plus_4_in(pc_plus_4_in_if),
    .instr_in(instr_in),
    .flush(flush),
    .stall(stall),
    .if_id_en(if_id_en),
    .pc_plus_4_out(pc_plus_4_out_if),
    .instr_out(instr_out)
);

assign op_instr = instr_out;

//Assigning logic based on ISA
assign opcode = instr_out[6:0];
assign funct3 = instr_out[14:12];
assign funct7 =  instr_out[31:25];
assign rs1 = instr_out[19:15];
assign rs2 = instr_out[24:20];
assign rd = instr_out[11:7];

//Stage 2 - Instruction Decode

//Control signals for all datapaths
control_unit datapath_signals(
    .opcode(opcode),
    .RegWrite(RegWrite), 
    .ALU_Src(ALU_Src), 
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemToReg(MemToReg),
    .Branch(Branch),
    .ALU_Op(ALU_Op)
);

//ALU operators- immediate or from register file
regfile register_file(
    .clk(clk), 
    .wenable(RegWrite_wb),
    .rs1(rs1),.rs2(rs2),
    .rd(rd_wb),
    .wdata(reg_write_data), 
    .rd1(rd1),
    .rd2(rd2)
);

imm_gen immediate_number(
    .instr(instr_out),
    .imm_out(imm_out)
);

// IF/EX pipeline Register
id_ex_reg id_ex(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(id_ex_flush),

    // Inputs from ID
    .rd1_in(rd1),
    .rd2_in(rd2),
    .imm_in(imm_out),
    .pc_plus_4_in(pc_plus_4_out_if),
    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    .funct3_in(funct3),
    .funct7_in(funct7),
    .opcode_in(opcode),

    .RegWrite_in(RegWrite),
    .MemRead_in(MemRead),
    .MemWrite_in(MemWrite),
    .MemToReg_in(MemToReg),
    .ALU_Src_in(ALU_Src),
    .Branch_in(Branch),
    .ALU_Op_in(ALU_Op),

    .instr_in(instr_out),

    // Outputs to EX
    .rd1_out(rd1_ex),
    .rd2_out(rd2_ex),
    .imm_out(imm_ex),
    .pc_plus_4_out(pc_plus_4_ex),
    .rs1_out(rs1_ex),
    .rs2_out(rs2_ex),
    .rd_out(rd_ex),
    .funct3_out(funct3_ex),
    .funct7_out(funct7_ex),
    .opcode_out(opcode_ex),

    .RegWrite_out(RegWrite_ex),
    .MemRead_out(MemRead_ex),
    .MemWrite_out(MemWrite_ex),
    .MemToReg_out(MemToReg_ex),
    .ALU_Src_out(ALU_Src_ex),
    .Branch_out(Branch_ex),
    .ALU_Op_out(ALU_Op_ex),

    .instr_out(instr_ex)
);

//Hazard Detection
hazard_detection hazard_det(
    .Mem_Read(MemRead_ex),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd_ex),
    .pc_en(pc_en),
    .if_id_en(if_id_en),
    .id_ex_flush(id_ex_flush)
);



//Stage 3 - Execute

//Control Signal for ALU
ALU_Control ALU_signals(
    .funct3(funct3_ex),
    .funct7(funct7_ex),
    .ALU_Op(ALU_Op_ex),
    .ALU_Sel(ALU_Sel)
);

//Change PC based on Branch and Jump
pc_next nextpc (
    .opcode(opcode_ex),
    .pc(pc),
    .rs1(rd1_ex),
    .rs2(rd2_ex),
    .imm_out(imm_ex),
    .funct3(funct3_ex),
    .jal_data(jal_data_link),
    .pc_next(pc_next)
);

//Decide what b data is going to be for ALU
assign ALU_b = (ALU_Src_ex) ? imm_ex : rd2_ex;

//ALU Operation
ALU ALU_result(
    .a(rd1_ex), 
    .b(ALU_b),
    .ALU_Sel(ALU_Sel), 
    .ALU_Out(ALU_res)
);

// EX/MEM pipeline Register
ex_mem_reg ex_mem(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(1'b0),

    .ALU_res_in(ALU_res),
    .store_data_in(rd2_ex),
    .rd_in(rd_ex),

    .RegWrite_in(RegWrite_ex),
    .MemRead_in(MemRead_ex),
    .MemWrite_in(MemWrite_ex),
    .MemToReg_in(MemToReg_ex),

    .opcode_in(opcode_ex),
    .pc_plus_4_in(pc_plus_4_ex),
    .instr_in(instr_ex),

    .ALU_res_out(ALU_res_mem),
    .store_data_out(store_data_mem),
    .rd_out(rd_mem),

    .RegWrite_out(RegWrite_mem),
    .MemRead_out(MemRead_mem),
    .MemWrite_out(MemWrite_mem),
    .MemToReg_out(MemToReg_mem),

    .opcode_out(opcode_mem),
    .pc_plus_4_out(pc_plus_4_mem),
    .instr_out(instr_mem)
);

//Stage 4 - Memory

//DMEM - still need to complete
dmem data_memory(
    .clk(clk), 
    .MemRead(MemRead_mem),
    .MemWrite(MemWrite_mem),
    .addr(ALU_res_mem),
    .wdata(store_data_mem),
    .rdata(dmem_data)
);

// MEM/WB pipeline Register
mem_wb_reg mem_wb(
    .clk(clk),
    .reset(reset),
    .stall(1'b0),
    .flush(1'b0),

    .read_data_in(dmem_data),
    .ALU_res_in(ALU_res_mem),
    .rd_in(rd_mem),

    .RegWrite_in(RegWrite_mem),
    .MemToReg_in(MemToReg_mem),

    .opcode_in(opcode_mem),
    .pc_plus_4_in(pc_plus_4_mem),
    .instr_in(instr_mem),

    .read_data_out(read_data_wb),
    .ALU_res_out(ALU_res_wb),
    .rd_out(rd_wb),

    .RegWrite_out(RegWrite_wb),
    .MemToReg_out(MemToReg_wb),

    .opcode_out(opcode_wb),
    .pc_plus_4_out(pc_plus_4_wb),
    .instr_out(instr_wb)
);

//Stage 5 - Write Back

//Choose what data to store back into register file
logic is_jal, is_jalr;
assign is_jal  = (opcode_wb == 7'b1101111); // JAL
assign is_jalr = (opcode_wb == 7'b1100111); // JALR

assign reg_write_data =
    (is_jal | is_jalr) ? pc_plus_4_wb: (MemToReg_wb ? read_data_wb: ALU_res_wb);


//Testing Purposes
assign reg_write_addr = rd_wb;
assign reg_debug = RegWrite_wb;

endmodule
