module Data_Memory #(
    parameter address_width = 12,
    parameter data_width = 32,
    parameter mem_size_kb = 4 
)(
    input clk,
    input mem_write,
    
    input [address_width-1:0] address,
    
    input [data_width-1:0] write_data,
    
    output reg [data_width-1:0] read_data
);

// Explained in Instruction Memory
localparam depth = (mem_size_kb * 1024) / 4;
localparam addr_bits_used = $clog2(depth);

// Byte-to-Word Conversion
wire [addr_bits_used-1:0] word_addr;
assign word_addr = mem_address[addr_bits_used+1:2];

always @ (posedge clk) 
    begin
        if (mem_write) // Byte-Word Conversion 
            memory_block[word_addr] <= write_data; // Write Data
        else 
            read_data <= memory_block[word_addr];  // Read Data      
    end
    
endmodule