module regfile(input logic clk, input logic wenable, input logic [4:0] rs1,input logic [4:0] rs2, 
input logic [4:0] rd, input logic [31:0] wdata, output logic [31:0] rd1, output logic [31:0] rd2);

    logic [31:0] regs [31:0]; // Making 32 Registers


    // Loading data registers
    // Reg 0 is always x0 in RISC-V
    assign rd1 = (rs1 == 0) ? 32'b0: regs[rs1]; 
    assign rd2 = (rs2 == 0) ? 32'b0: regs[rs2];
    
    // Writing to Register if Write Enable is 1
    always_ff @(posedge clk)begin
        if(wenable && (rd != 5'd0)) begin
            regs[rd] <= wdata;
        end
    end
endmodule