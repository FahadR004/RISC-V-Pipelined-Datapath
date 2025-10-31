module Register_File #(
    parameter data_width = 32,
    parameter reg_width = 5,
    parameter total_regs = 32

) (
    // Signals
    input clk,
    input write_enable,
    // Addresses
    input [reg_width-1:0] read_addr_1,
    input [reg_width-1:0] read_addr_2,
    input [reg_width-1:0] write_addr,
    // Data
    input [data_width-1:0] write_reg_data,
    
    // Output
    output reg [data_width-1:0] read_data_1,
    output reg [data_width-1:0] read_data_2
);

// Register File Array
reg [data_width-1:0] registers [total_regs]; // registers is the name of register file array
// reg [31:0] registers [32] => 32-bit wide 32 registers

always @ (posedge clk)
    begin
        if (write_enable)
            registers[write_addr] <= write_reg_data; 
    end

assign read_data_1 = registers[read_addr_1];
assign read_data_2 = registers[read_addr_2];
    
endmodule