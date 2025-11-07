module MEM_WB_Register #(
    parameter data_width = 32,
    parameter address_width = 32,
    parameter reg_addr_width = 5
) (
    input clk,
    input reset,
    
    // Control signals from Memory
    input MEM_mem_to_reg,
    input MEM_reg_write,
    
    // Data from Memory
    input [data_width-1:0] MEM_alu_result,
    input [data_width-1:0] MEM_mem_data,        // Data read from memory
    input [reg_addr_width-1:0] MEM_rd,
    input [address_width-1:0] MEM_pc_plus_4,
    
    // Control signals to WriteBack
    output reg WB_mem_to_reg,
    output reg WB_reg_write,
    
    // Data to WriteBack
    output reg [data_width-1:0] WB_alu_result,
    output reg [data_width-1:0] WB_mem_data,
    output reg [reg_addr_width-1:0] WB_rd,
    output reg [address_width-1:0] WB_pc_plus_4
);

    always @(posedge clk or posedge reset) begin
        if (reset) 
            begin
                WB_mem_to_reg <= 1'b0;
                WB_reg_write <= 1'b0;
                WB_alu_result <= {data_width{1'b0}};
                WB_mem_data <= {data_width{1'b0}};
                WB_rd <= {reg_addr_width{1'b0}};
                WB_pc_plus_4 <= {address_width{1'b0}};
            end
        else 
            begin
                // Normal operation
                WB_mem_to_reg <= MEM_mem_to_reg;
                WB_reg_write <= MEM_reg_write;
                WB_alu_result <= MEM_alu_result;
                WB_mem_data <= MEM_mem_data;
                WB_rd <= MEM_rd;
                WB_pc_plus_4 <= MEM_pc_plus_4;
            end
    end

endmodule