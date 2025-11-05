module control_unit(input logic [6:0] opcode, output logic RegWrite,output logic ALU_src,output logic MemRead,output logic MemWrite,
output logic MemToReg,output logic Branch,output logic [1:0]ALU_Op );

/*
    ALUSrc    – Selects the second ALU input.

    RegWrite  – Enables writing to the register file.

    MemRead   – Enables reading data from data memory.

    MemWrite  – Enables writing data to data memory.

    MemToReg  – Selects what gets written back to the register file.

    Branch    – Indicates a branch instruction.

    ALUOp[1:0] – Tells the ALU Control what kind of instruction family this is.
        00 = Load/Store  
        01 = Branch      
        10 = R-type      
        11 = I-type   
*/



always_comb begin
    //To prevent latching
    RegWrite = 1'b0;
    ALU_src  = 1'b0;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    MemToReg = 1'b0;
    Branch   = 1'b0;
    ALU_Op   = 2'b00;
    case(opcode)
        //R-Type
        7'b0110011:begin
            ALU_src = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            MemToReg = 0;
            Branch = 0;
            ALU_Op = 2'b10;
        end
        //I-Type
        7'b0010011:begin
            ALU_src = 1;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            MemToReg = 0;
            Branch = 0;
            ALU_Op = 2'b11;
        end
    
        //Load
        7'b0000011:begin
            ALU_src = 1;
            RegWrite = 1;
            MemRead = 1;
            MemWrite = 0;
            MemToReg = 1;
            Branch = 0;
            ALU_Op = 2'b00;
        end
        //Store
        7'b0100011:begin
            ALU_src = 1;
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 1;
            MemToReg = 0;
            Branch = 0;
            ALU_Op = 2'b00;
        end
        //Branch
        7'b1100011:begin
            ALU_src = 0;
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 0;
            MemToReg = 0;
            Branch = 1;
            ALU_Op = 2'b01;
        end
    endcase






endmodule