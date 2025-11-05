module ALU_Control(input logic [2:0] funct3, input logic [6:0] funct7, input logic [1:0] ALU_Op, output logic [3:0] ALU_Sel);


    always_comb begin
        unique case(ALU_Op)
            
            //Load/Store
            2'b00: ALU_Sel = 4'd0; //ADD
            
            //Branch
            2'b01: ALU_Sel = 4'd1; //SUB
            
            //R-Type
            2'b10: begin
                unique case(funct3)
                    3'd0: ALU_Sel = (funct7 == 7'b0000000) ? 4'd0: 4'd1;
                    3'd1: ALU_Sel = 4'd7;
                    3'd2: ALU_Sel = 4'd5;
                    3'd3: ALU_Sel = 4'd6;
                    3'd4: ALU_Sel = 4'd4;
                    3'd5: ALU_Sel = (funct7 == 7'b0000000) ? 4'd8: 4'd9;
                    3'd6: ALU_Sel = 4'd3;
                    3'd7: ALU_Sel = 4'd2;
                    default: ALU_Sel = 4'd0;
                endcase
            end

            //I-Type
            2'b11: begin
                unique case(funct3)
                    3'd0: ALU_Sel = 4'd0;
                    3'd1: ALU_Sel = 4'd7;
                    3'd2: ALU_Sel = 4'd5;
                    3'd3: ALU_Sel = 4'd6;
                    3'd4: ALU_Sel = 4'd4;
                    3'd5: ALU_Sel = (funct7 == 7'b0000000) ? 4'd8: 4'd9;
                    3'd6: ALU_Sel = 4'd3;
                    3'd7: ALU_Sel = 4'd2;
                    default: ALU_Sel = 4'd0;
                endcase
            end
            default: ALU_Sel = 4'd0;
        endcase
    end

endmodule
