module cpu_top(input logic clk, input logic reset,
output logic [31:0] pc, output logic [31:0] instr,output logic [31:0] ALU_res, output logic [31:0] reg_write_data,output logic [4:0] reg_write_addr,
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



//PC Counter
pc_counter pc_counter(.clk(clk),.reset(reset),.pc(pc),.pc_next(pc_next));

//Incrementing PC
assign pc_next = pc + 32'd4;

//Getting correct instructions based on PC
imem imem_instruction(.addr(pc),.instr(instr));

//Assigning logic based on ISA
assign opcode = instr[6:0];
assign funct3 = instr[14:12];
assign funct7 =  instr[31:25];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd = instr[11:7];

//Control signals for all datapaths
control_unit datapath_signals(.opcode(opcode), .RegWrite(RegWrite), .ALU_Src(ALU_Src), .MemRead(MemRead),.MemWrite(MemWrite),.MemToReg(MemToReg),.Branch(Branch),.ALU_Op(ALU_Op));
ALU_Control ALU_signals(.funct3(funct3),.funct7(funct7),.ALU_Op(ALU_Op),.ALU_Sel(ALU_Sel));


//Testing Purposes
assign reg_write_addr = rd;
assign reg_debug = RegWrite;

//ALU operators- immediate or from register file
regfile register_file(.clk(clk), .wenable(RegWrite),.rs1(rs1),.rs2(rs2),.rd(rd),.wdata(reg_write_data), .rd1(rd1),.rd2(rd2));
imm_gen immediate_number(.instr(instr),.imm_out(imm_out));

//Decide what b data is going to be for ALU
assign ALU_b = (ALU_Src) ? imm_out : rd2;

//ALU Operation
ALU ALU_result(.a(rd1),.b(ALU_b),.ALU_Sel(ALU_Sel), .ALU_Out(ALU_res));


//DMEM - still need to complete
dmem data_memory(.clk(clk), .MemRead(MemRead),.MemWrite(MemWrite),.addr(ALU_res),.wdata(rd2),.rdata(dmem_data));

//Choose what data to store back into register file
assign reg_write_data = (MemToReg) ? dmem_data : ALU_res;







endmodule