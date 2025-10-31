module Decode_Stage #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5,
    parameter total_regs = 32
) (
    input clk,
    input reset,
    
    // From IF/ID Register
    input [data_width-1:0] instruction,
    input [address_width-1:0] pc_current,
    input [address_width-1:0] pc_plus_4,
    
    // From Write Back Stage (for register file write)
    input WB_reg_write,
    input [reg_addr_width-1:0] WB_write_addr,
    input [data_width-1:0] WB_write_data,
    
    // Outputs to ID/EX Register
    // Control Signals
    output wire alu_src,
    output wire [1:0] alu_op,
    output wire branch,
    output wire mem_read,
    output wire mem_write,
    output wire mem_to_reg,
    output wire reg_write,
    
    // Data and Register Addresses
    output wire [data_width-1:0] read_data_1,
    output wire [data_width-1:0] read_data_2,
    output wire [reg_addr_width-1:0] rs1,
    output wire [reg_addr_width-1:0] rs2,
    output wire [reg_addr_width-1:0] rd,
    
    // Immediate value
    output wire [data_width-1:0] immediate,
    
    // Pass-through signals
    output wire [address_width-1:0] pc_plus_4_out,
    output wire [address_width-1:0] pc_current_out
    output wire [6:0] funct7,
    output wire [2:0] funct3
);

    // Instruction field decoding - will work for all types of instructions
    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    assign pc_plus_4_out = pc_plus_4;
    assign pc_current_out = pc_current;
    
    Control_Unit control_unit (
        .opcode(opcode),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write)
    );
    
    Register_File #(
        .data_width(data_width),
        .reg_width(reg_addr_width),
        .total_regs(total_regs)
    ) register_file (
        .clk(clk),
        .write_enable(WB_reg_write),
        .read_addr_1(rs1),
        .read_addr_2(rs2),
        .write_addr(WB_write_addr),
        .write_reg_data(WB_write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );
    
    // Immediate Generator Instance
    Immediate_Generator #(
        .data_width(data_width)
    ) imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

endmodule