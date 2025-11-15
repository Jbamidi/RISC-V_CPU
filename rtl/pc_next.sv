module pc_next(input logic [6:0] opcode, input logic [31:0] pc, input logic [31:0] rs1, input logic [31:0] rs2, input logic [31:0] imm_out, 
input logic [2:0] funct3, output logic [31:0] jal_data, output logic [31:0] pc_next, output logic branch_taken);

always_comb begin
    // defaults
    pc_next  = pc + 32'd4;
    jal_data = 32'b0;
    branch_taken = 1'b0;
    unique case(opcode)
        //Branch
        7'b1100011: begin
                    unique case(funct3)
                        //BEQ
                        3'h0: if (rs1 == rs2) begin
                                    pc_next = pc + imm_out;
                                    branch_taken = 1'b1;
                        end
                        //BNE
                        3'h1: if (rs1 != rs2) begin
                                   pc_next = pc + imm_out;
                                   branch_taken = 1'b1;
                        end
                        //BLT
                        3'h4:if ($signed(rs1) < $signed(rs2)) begin
                                    pc_next = pc + imm_out;
                                    branch_taken = 1'b1;
                        end
                        //BGE
                        3'h5:if ($signed(rs1) >= $signed(rs2)) begin
                                    pc_next = pc + imm_out;
                                    branch_taken = 1'b1;
                        end
                        //BLTU
                        3'h6:if (rs1 < rs2) begin
                                    pc_next = pc + imm_out;
                                    branch_taken = 1'b1;
                        end
                        //BGEU
                        3'h7:if (rs1 >= rs2) begin
                                    pc_next = pc + imm_out;
                                    branch_taken = 1'b1;
                        end

                        default: pc_next = pc + 32'd4;
                    endcase
                    
        end
        //JAL
        7'b1101111: begin
            jal_data = pc + 32'd4;
            pc_next = pc + imm_out;
            branch_taken = 1'b1;
        end
        //JALR
        7'b1100111: begin
            jal_data = pc + 32'd4;
            pc_next = (rs1 + imm_out) & ~32'd1;
            branch_taken = 1'b1;
        end

        //Normal pc increment
        default: pc_next = pc + 32'd4;
    endcase
end
endmodule
