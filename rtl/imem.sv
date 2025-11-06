module imem(input logic [31:0] addr, output logic [31:0] instr);

/* Load program at sim start
        Test Instructions:
        addi x1, x0, 5
        addi x2, x0, 10
        add x3, x1, x2
*/

Initial begin
    $readmemh("imem_data.hex", memory);
end

logic [31:0] memory [0:255]; //1kb of space for tetsing
assign instr = memory[pc[9:2]];


endmodule