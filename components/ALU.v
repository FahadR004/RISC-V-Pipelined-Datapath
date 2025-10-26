module ALU #(
    parameter data_width = 32
) (
    input [2:0] funct3. 
    output [6:0] funct7,
    input [data_width-1:0] operand_A, 
    input [data_width-1:0] operand_B,
    input [data_width-1:0] immediate,
    output reg [data_width-1: 0] result
    output zero_flag, 
);
    
endmodule