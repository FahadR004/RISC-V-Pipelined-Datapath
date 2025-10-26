module Memory #(
    parameter address_bits = 12,
    parameter data_width = 32
)(
    input clk,
    input mem_write,
    
    input [address_bits-1:0] address,
    
    input [data_width-1:0] write_data,
    
    output reg [data_width-1:0] read_data
);

localparam depth = 2**(address_bits-2); // 2^12/2^10 = 1024 words
reg [data_width-1:0] memory_block [0:depth-1]; 

always @ (posedge clk) 
    begin
        if (mem_write) // Byte-Word Conversion 
            memory_block[address[address_bits-1:2]] <= write_data; // Write Data
        else 
            read_data <= memory_block[address[address_bits-1:2]];  // Read Data      
    end
    
endmodule