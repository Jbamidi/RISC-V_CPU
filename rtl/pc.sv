module pc_counter(input logic clk, input logic reset, output logic [31:0] pc, input logic [31:0] pc_next);
    always_ff @(posedge clk or posedge reset)begin
        //Reset makes PC go back to 0
        if (reset) begin
            pc <= 32'b0;
        end
        //Otherwise next pc is loaded in pc which will be determined elsewhere
        else begin
            pc <= pc_next;

        end
    end



endmodule