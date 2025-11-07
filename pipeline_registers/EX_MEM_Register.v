module EX_MEM_Register #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5
) (
    input clk,
    input reset,
    input flush,
    
    // Control signals from Execute
    input EX_mem_read,
    input EX_mem_write,
    input EX_mem_to_reg,
    input EX_reg_write,
    
    // Data from Execute
    input [data_width-1:0] EX_alu_result,
    input [data_width-1:0] EX_write_data,       // For stores
    input [reg_addr_width-1:0] EX_rd,
    input [address_width-1:0] EX_pc_plus_4,
    input EX_rs2,
    input EX_zero_flag,
    
    // Control signals to Memory
    output reg MEM_mem_read,
    output reg MEM_mem_write,
    output reg MEM_mem_to_reg,
    output reg MEM_reg_write,
    
    // Data to Memory
    output reg [data_width-1:0] MEM_alu_result,
    output reg [data_width-1:0] MEM_write_data,
    output reg [reg_addr_width-1:0] MEM_rd,
    output reg [address_width-1:0] MEM_pc_plus_4,
    output reg [reg_addr_width-1:0] MEM_rs2,   
    output reg MEM_zero_flag
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Insert bubble
            MEM_mem_read <= 1'b0;
            MEM_mem_write <= 1'b0;
            MEM_mem_to_reg <= 1'b0;
            MEM_reg_write <= 1'b0;
            MEM_alu_result <= {data_width{1'b0}};
            MEM_write_data <= {data_width{1'b0}};
            MEM_rd <= {reg_addr_width{1'b0}};
            MEM_pc_plus_4 <= {address_width{1'b0}};
            MEM_rs2 <= {reg_addr_width{1'b0}};     
            MEM_zero_flag <= 1'b0;
        end
        else begin
            // Normal operation
            MEM_mem_read <= EX_mem_read;
            MEM_mem_write <= EX_mem_write;
            MEM_mem_to_reg <= EX_mem_to_reg;
            MEM_reg_write <= EX_reg_write;
            MEM_alu_result <= EX_alu_result;
            MEM_write_data <= EX_write_data;
            MEM_rd <= EX_rd;
            MEM_pc_plus_4 <= EX_pc_plus_4;
            MEM_rs2 <= EX_rs2;
            MEM_zero_flag <= EX_zero_flag;
        end
    end

endmodule