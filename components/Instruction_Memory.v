module Instruction_Memory #(
    parameter address_width = 12, 
    parameter data_width = 32
)(    
    input [address_width-1:0] address,
        
    output reg [data_width-1:0] instruction
);

localparam depth = 2**(address_width-2); // 2^12 memory locations = 4096 Bytes = 4KB Memory
// Address is of 12 bits
// There are 2^12 memory locations or 2^12 bytes of memory or 4096 bytes
// I give byte addresses but my instruction is of 4 bytes or 1 word
// I have defined my memory word wise. Thus, 2^12/2^2 = 2^10 word addresses
reg [data_width-1:0] memory_block [0:depth-1]; 

// Byte-Word Conversion
assign instruction = memory_block[address[address_width-1:2]];

endmodule