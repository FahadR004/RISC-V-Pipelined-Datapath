module Memory_Stage #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5
) (
    // Input
    input clk,
    input mem_write,
    input WB_reg_write,
    input [address_width-1:0] mem_address, 
    input [data_width-1:0] MEM_write_data,
    input [reg_addr_width-1:0] MEM_rs2,
    input [reg_addr_width-1:0] WB_rd,
    input [data_width-1:0] WB_write_data,
    // Output
    output wire [data_width-1:0] mem_read_data
);

wire [data_width-1:0] write_data;
wire mem_hazard;
wire forward_C;

// Forwarding Logic

// MEM Hazard Detector (WB → EX forwarding)
MEM_WB_MEM_FU #(
    .reg_addr_width(reg_addr_width)
) mem_hazard_detector (
    // Input
    .WB_rd(WB_rd),
    .WB_reg_write(WB_reg_write),
    .mem_write(mem_write),
    .mem_rs2(MEM_rs2),
    // Outputs
    .mem_hazard(mem_hazard)
);
    
// Forwarding Control Unit
Forwarding_Control_MEM forward_ctrl (
    .mem_hazard(mem_hazard),
    .forward_C(forward_C),
);

// MULTIPLEXER FOR WRITE DATA  
assign write_data = forward_C ? WB_write_data : MEM_write_data;

Data_Memory #(
    .data_width(data_width),
    .address_width(address_width)
) data_mem(
    .clk(clk),
    .mem_write(mem_write),
    .mem_address(mem_address),
    .mem_write_data(write_data),

    .read_data(mem_read_data)
);
    
endmodule