module ID_EX_Register #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5
) (
    input clk,
    input reset,
    input stall,
    input flush,
    
    // Control Signals from Decode
    input ID_alu_src,
    input [1:0] ID_alu_op,
    input ID_branch,
    input ID_mem_read,
    input ID_mem_write,
    input ID_mem_to_reg,
    input ID_reg_write,
    
    // Data from Decode
    input [data_width-1:0] ID_read_data_1,
    input [data_width-1:0] ID_read_data_2,
    input [reg_addr_width-1:0] ID_rs1,
    input [reg_addr_width-1:0] ID_rs2,
    input [reg_addr_width-1:0] ID_rd,
    input [data_width-1:0] ID_immediate,
    input [address_width-1:0] ID_pc_plus_4,
    input [address_width-1:0] ID_pc_current,
    input [6:0] ID_funct7,
    input [2:0] ID_funct3,
    
    // Control Signals to Execute
    output reg EX_alu_src,
    output reg [1:0] EX_alu_op,
    output reg EX_branch,
    output reg EX_mem_read,
    output reg EX_mem_write,
    output reg EX_mem_to_reg,
    output reg EX_reg_write,
    
    // Data to Execute
    output reg [data_width-1:0] EX_read_data_1,
    output reg [data_width-1:0] EX_read_data_2,
    output reg [reg_addr_width-1:0] EX_rs1,
    output reg [reg_addr_width-1:0] EX_rs2,
    output reg [reg_addr_width-1:0] EX_rd,
    output reg [data_width-1:0] EX_immediate,
    output reg [address_width-1:0] EX_pc_plus_4,
    output reg [address_width-1:0] EX_pc_current,
    output reg [6:0] EX_funct7,
    output reg [2:0] EX_funct3
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Insert bubble (NOP) - zero out all control signals
            EX_alu_src <= 1'b0;
            EX_alu_op <= 2'b00;
            EX_branch <= 1'b0;
            EX_mem_read <= 1'b0;
            EX_mem_write <= 1'b0;
            EX_mem_to_reg <= 1'b0;
            EX_reg_write <= 1'b0;
            
            EX_read_data_1 <= {data_width{1'b0}};
            EX_read_data_2 <= {data_width{1'b0}};
            EX_rs1 <= {reg_addr_width{1'b0}};
            EX_rs2 <= {reg_addr_width{1'b0}};
            EX_rd <= {reg_addr_width{1'b0}};
            EX_immediate <= {data_width{1'b0}};
            EX_pc_plus_4 <= {address_width{1'b0}};
            EX_pc_current <= {address_width{1'b0}};
            EX_funct7 <= 7'b0;
            EX_funct3 <= 3'b0;
        end
        else if (stall) begin
            // Hold current values - do nothing
            EX_alu_src <= EX_alu_src;
            EX_alu_op <= EX_alu_op;
            EX_branch <= EX_branch;
            EX_mem_read <= EX_mem_read;
            EX_mem_write <= EX_mem_write;
            EX_mem_to_reg <= EX_mem_to_reg;
            EX_reg_write <= EX_reg_write;
            
            EX_read_data_1 <= EX_read_data_1;
            EX_read_data_2 <= EX_read_data_2;
            EX_rs1 <= EX_rs1;
            EX_rs2 <= EX_rs2;
            EX_rd <= EX_rd;
            EX_immediate <= EX_immediate;
            EX_pc_plus_4 <= EX_pc_plus_4;
            EX_pc_current <= EX_pc_current;
            EX_funct7 <= EX_funct7;
            EX_funct3 <= EX_funct3;
        end
        else begin
            // Normal operation - latch new values
            EX_alu_src <= ID_alu_src;
            EX_alu_op <= ID_alu_op;
            EX_branch <= ID_branch;
            EX_mem_read <= ID_mem_read;
            EX_mem_write <= ID_mem_write;
            EX_mem_to_reg <= ID_mem_to_reg;
            EX_reg_write <= ID_reg_write;
            
            EX_read_data_1 <= ID_read_data_1;
            EX_read_data_2 <= ID_read_data_2;
            EX_rs1 <= ID_rs1;
            EX_rs2 <= ID_rs2;
            EX_rd <= ID_rd;
            EX_immediate <= ID_immediate;
            EX_pc_plus_4 <= ID_pc_plus_4;
            EX_pc_current <= ID_pc_current;
            EX_funct7 <= ID_funct7;
            EX_funct3 <= ID_funct3;
        end
    end

endmodule