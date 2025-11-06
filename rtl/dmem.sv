module dmem(input logic clk, input logic MemRead, input logic MemWrite, input logic [31:0] addr, input logic [31:0] wdata, output logic [31:0] rdata);

    logic [31:0] memory [0:255]; //1kb of space for tetsing

    always_ff @(posedge clk)begin
        if (MemWrite)begin
            memory[addr[9:2]] <= wdata;
        end
    end

    always_comb begin
        if(MemRead)begin
            rdata <=memory[addr[9:2]];
        end
    end
            





endmodule

