module forwarding_unit(input logic [4:0] rd_mem,input logic [4:0] rd_wb, input logic [4:0] rs1_ex, input logic [4:0] rs2_ex, input logic RegWrite_mem, input logic RegWrite_wb,
output logic [1:0] forwardA, output logic [1:0] forwardB);

    always_comb begin
        
        if (RegWrite_mem && (rd_mem != 5'd0) && (rs1_ex != 5'd0) && (rd_mem == rs1_ex))begin
            forwardA = 2'b10;
        end
        else if (RegWrite_wb && (rd_wb != 5'd0) && (rs1_ex != 5'd0) && (rd_wb == rs1_ex))begin
            forwardA = 2'b01;
        end
        else begin
            forwardA = 2'b00;
        end

        if (RegWrite_mem && (rd_mem != 5'd0) && (rs2_ex != 5'd0) && (rd_mem == rs2_ex))begin
            forwardB = 2'b10;
        end
        else if (RegWrite_wb && (rd_wb != 5'd0) && (rs2_ex != 5'd0) && (rd_wb == rs2_ex))begin
            forwardB = 2'b01;
        end
        else begin
            forwardB = 2'b00;
        end

    
    end

endmodule
