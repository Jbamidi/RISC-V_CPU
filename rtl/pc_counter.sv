module pc_counter(input logic clk, input logic reset, input logic [31:0] pc_next, input logic pc_en, output logic [31:0] pc);
    always_ff @(posedge clk or posedge reset)begin
        //Reset makes PC go back to 0
        if (reset) begin
            pc <= 32'b0;
        end
        else if (pc_en) begin
            pc <= pc_next;
    end



endmodule
