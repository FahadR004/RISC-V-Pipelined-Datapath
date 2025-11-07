module Execute_Stage #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5
) (
    // Control signals from ID/EX
    input alu_src,
    input [1:0] alu_op,
    input branch,
    
    // Data from ID/EX
    input [data_width-1:0] read_data_1,
    input [data_width-1:0] read_data_2,
    input [reg_addr_width-1:0] rs1,
    input [reg_addr_width-1:0] rs2,
    input [data_width-1:0] immediate,
    input [address_width-1:0] pc_current,
    input [6:0] funct7,
    input [2:0] funct3,
    
    // Forwarding inputs from MEM stage
    input [reg_addr_width-1:0] MEM_rd,
    input MEM_reg_write,
    input [data_width-1:0] MEM_alu_result,
    
    // Forwarding inputs from WB stage
    input [reg_addr_width-1:0] WB_rd,
    input WB_reg_write,
    input [data_width-1:0] WB_write_data,
    
    // Outputs
    output wire [data_width-1:0] alu_result,
    output wire zero_flag,
    output wire [data_width-1:0] mem_write_data, // For Data Memory
    output wire branch_taken,
    output wire [address_width-1:0] branch_target
);

    // Internal wires
    wire [data_width-1:0] alu_operand_A;
    wire [data_width-1:0] alu_operand_B;
    wire [data_width-1:0] forwarded_A;
    wire [data_width-1:0] forwarded_B;
    wire [3:0] alu_control;
    
    // Forwarding control signals
    wire [1:0] forward_A;
    wire [1:0] forward_B;
    
    // Hazard detection signals
    wire ex_hazard_rs1, ex_hazard_rs2;
    wire mem_hazard_rs1, mem_hazard_rs2;
    
    // FORWARDING LOGIC (Modular Components)
    
    // EX Hazard Detector (MEM → EX forwarding)
    EX_MEM_ALU_FU #(
        .reg_addr_width(reg_addr_width)
    ) ex_hazard_detector (
        // Inputs
        .MEM_rd(MEM_rd),
        .MEM_reg_write(MEM_reg_write),
        .EX_rs1(rs1),
        .EX_rs2(rs2),
        // Outputs
        .ex_hazard_rs1(ex_hazard_rs1),
        .ex_hazard_rs2(ex_hazard_rs2)
    );
    
    // MEM Hazard Detector (WB → EX forwarding)
    MEM_WB_ALU_FU #(
        .reg_addr_width(reg_addr_width)
    ) mem_hazard_detector (
        // Input
        .WB_rd(WB_rd),
        .WB_reg_write(WB_reg_write),
        .EX_rs1(rs1),
        .EX_rs2(rs2),
        // Outputs
        .mem_hazard_rs1(mem_hazard_rs1),
        .mem_hazard_rs2(mem_hazard_rs2)
    );
    
    // Forwarding Control Unit
    Forwarding_Control_ALU forward_ctrl (
        .ex_hazard_rs1(ex_hazard_rs1),
        .ex_hazard_rs2(ex_hazard_rs2),
        .mem_hazard_rs1(mem_hazard_rs1),
        .mem_hazard_rs2(mem_hazard_rs2),
        .forward_A(forward_A),
        .forward_B(forward_B)
    );
    
    // Forwarding Multiplexer for Operand A
    Forwarding_MUX_ALU #(
        .data_width(data_width)
    ) fwd_mux_A (
        .forward_value(forward_A),
        .original_data(read_data_1),
        .mem_data(MEM_alu_result),
        .wb_data(WB_write_data),
        .alu_operand(forwarded_A)
    );
    
    // Forwarding Multiplexer for Operand B
    Forwarding_MUX #(
        .data_width(data_width)
    ) fwd_mux_B (
        .forward_value(forward_B),
        .original_data(read_data_2),
        .mem_data(MEM_alu_result),
        .wb_data(WB_write_data),
        .alu_operand(forwarded_B)
    );
    
    // ALU LOGIC
    
    // ALU Source Multiplexer (immediate vs rs2)
    assign alu_operand_A = forwarded_A;
    assign alu_operand_B = (alu_src) ? immediate : forwarded_B; // Second MUX
    
    // Store instruction needs forwarded rs2 data
    assign mem_write_data = forwarded_B;
    
    // ALU Control Unit
    ALU_Control alu_ctrl (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );
    
    // ALU
    ALU #(
        .data_width(data_width)
    ) alu (
        .alu_control(alu_control),
        .operand_A(alu_operand_A),
        .operand_B(alu_operand_B),
        .result(alu_result),
        .zero_flag(zero_flag)
    );
    
    //  BRANCH LOGIC
    // TO BE FIXED ALONG WITH IMMEDIATE GENERATOR VALUE
    Branch_Unit #(
        .address_width(address_width)
    ) branch_unit (
        .pc_current(pc_current),
        .immediate(immediate),
        .branch_signal(branch),
        .zero_flag(zero_flag),
        .funct3(funct3),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

endmodule