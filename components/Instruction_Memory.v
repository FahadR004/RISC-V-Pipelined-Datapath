module Instruction_Memory #(
    parameter address_width = 32, 
    parameter data_width = 32,
    parameter mem_size_kb = 4
)(    
    input [address_width-1:0] address, // 32-bit address
        
    output reg [data_width-1:0] instruction // 32-bit instruction
);
// We want memory to be in KB because of hardware limitations
localparam depth = (mem_size_kb*1024)/4;
// For 4KB:  
// Meaning we have 4 * 1024 = 4096 Bytes 
// Dividing 4096 by 4 gives us 1024 words. Thus, we have 1024 word addressable locations.
// As each instruction is actually word sized i.e. 4 bytes. 

// Now, we have the total words in our memory, we want to define how many address bits will be required
// to address all words. log2 will tell you the power that arrives at the answer
// 2^(?) = 1024, so we do:
localparam addr_bits_used = $clog2(depth); // c means ceiling function.
// Output is 10

// We only use as many words as defined for our memory size in KB which is 4
// We don't use 2^32 memory locations
reg [data_width-1:0] memory_block [0:depth-1]; // => reg [31:0] memory_block [0:9]

wire [addr_bits_used-1:0] word_addr;
assign word_addr = address[addr_bits_used+1:2];
// A word is 4 bytes. If I have 4096 Bytes, then 2^12 memory locations (bytes)
// But, for a word 2^12/4 or 2^12/2^2 which 2^10 word locations

// Byte-Word Conversion
assign instruction = memory_block[word_addr];
// Last 2 bits will not be needed for word addresses

endmodule


// OLD IMPLEMENTATION
// localparam depth = 2**(address_width-2); // 2^12 memory locations = 4096 Bytes = 4KB Memory
// // Address is of 12 bits
// // There are 2^12 memory locations or 2^12 bytes of memory or 4096 bytes
// // I give byte addresses but my instruction is of 4 bytes or 1 word
// // I have defined my memory word wise. Thus, 2^12/2^2 = 2^10 word addresses
// reg [data_width-1:0] memory_block [0:depth-1]; 
// // Byte-Word Conversion
// assign instruction = memory_block[address[address_width-1:2]];
