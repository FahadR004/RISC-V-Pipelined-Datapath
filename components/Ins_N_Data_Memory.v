module Memory #(
    parameter address_bits = 32,
    parameter data_width = 32;
    parameter depth = 4294967296
)(
    input clk,
    input mem_write,
    
    input [address_bits-1:0] address,
    
    input [data_width-1:0] write_data,
    
    output reg [data_width-1:0] read_data
);

reg [data_width-1:0] memory_block [0:depth-1] // 4GB Memory - 32-bit wide and 2^32 memory locations

always @ (posedge clk) 
    begin
        if (mem_write) 
            memory_block[address] <= write_data; // Write Data
        else 
            read_data <= memory_block[address];  // Read Data      
    end
    
endmodule