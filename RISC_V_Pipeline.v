// Main File

module RISC_V_Pipeline #(
    parameter data_width = 32,
    parameter address_width = 32,
    parameter reg_addr_width = 5,
    parameter total_regs = 32,
    parameter mem_size_kb = 4
) (
    input clk,
    input reset
);

    // STAGE-WISE OUTPUT DECLARATIONS
    // Fetch Stage Input 
    wire pc_write; // From HDU as well
    wire [address_width-1:0] branch_target;
    wire pc_src;

    // Fetch Stage Output
    wire [address_width-1:0] IF_pc_plus_4;
    wire [address_width-1:0] IF_pc_current;
    wire [data_width-1:0] IF_instruction;

    // IF-ID Register Input
    wire if_id_write; // From HDU as well
    wire if_id_flush;

    // IF-ID Register 
    wire [address_width-1:0] ID_pc_plus_4;
    wire [address_width-1:0] ID_pc_current;
    wire [data_width-1:0] ID_instruction;

    // Decode Stage Output
        
        // PC+4 (Untouched)
        wire [address_width-1:0] ID_pc_current_out;
        wire [address_width-1:0] ID_pc_plus_4_out;

        // Immediate Generator
        wire [data_width-1:0] ID_immediate; 

        // Register Code
        wire [reg_addr_width-1:0] ID_rs1;
        wire [reg_addr_width-1:0] ID_rs2;
        wire [reg_addr_width-1:0] ID_rd;

        // Register File
        wire [data_width-1:0] ID_read_data_1;
        wire [data_width-1:0] ID_read_data_2;

        // Control Unit Control Signals
            // EX
            wire ID_alu_src;
            wire [1:0] ID_alu_op;
            // MEM
            wire ID_branch;
            wire ID_mem_read;
            wire ID_mem_write;
            // WB
            wire ID_mem_to_reg;
            wire ID_reg_write;

        // Funct bits for ALU
        wire [6:0] ID_funct7;
        wire [2:0] ID_funct3;

    // ID/EX Register Input
    wire control_mux_select;
    wire id_ex_flush;

    // ID/EX Register 
    wire EX_alu_src;
    wire [1:0] EX_alu_op;
    wire EX_branch;
    wire EX_mem_read;
    wire EX_mem_write;
    wire EX_mem_to_reg;
    wire EX_reg_write;

    wire [data_width-1:0] EX_read_data_1;
    wire [data_width-1:0] EX_read_data_2;
    wire [reg_addr_width-1:0] EX_rs1;
    wire [reg_addr_width-1:0] EX_rs2;
    wire [reg_addr_width-1:0] EX_rd;
    wire [data_width-1:0] EX_immediate;
    wire [address_width-1:0] EX_pc_plus_4;
    wire [address_width-1:0] EX_pc_current;
    wire [6:0] EX_funct7;
    wire [2:0] EX_funct3;    

    // Execution Stage Output
    wire [data_width-1:0] EX_alu_result;
    wire [data_width-1:0] EX_write_data;
    wire EX_zero_flag;
    wire EX_branch_taken;
    wire [address_width-1:0] EX_branch_target;

    // EX_MEM to ALU Forwarding Unit Outputs
    wire [1:0] forward_A;
    wire [1:0] forward_B;

    // EX/MEM Register Outputs
    wire MEM_mem_read;
    wire MEM_mem_write;
    wire MEM_mem_to_reg;
    wire MEM_reg_write;
    wire [data_width-1:0] MEM_alu_result;
    wire [data_width-1:0] MEM_write_data;
    wire [reg_addr_width-1:0] MEM_rd;
    wire [address_width-1:0] MEM_pc_plus_4;
    wire MEM_zero_flag;
    wire ex_mem_flush;
    
    // Branch and Flush Control
    assign if_id_flush = EX_branch_taken;
    assign id_ex_flush = EX_branch_taken;
    assign ex_mem_flush = EX_branch_taken;

    // PC Control
    assign pc_src = EX_branch_taken;
    assign branch_target = EX_branch_target;
    
    // wire wb_reg_write;
    // wire [reg_addr_width-1:0] wb_write_addr;
    // wire [data_width-1:0] wb_write_data;
    // assign if_id_flush = EX_branch_taken;
    // assign id_ex_flush = EX_branch_taken;
    // assign pc_src = EX_branch_taken;
    // assign branch_target = EX_branch_target;

    // Memory Stage Output
    wire [reg_addr_width-1:0] MEM_rs2;
    wire [data_width-1:0] mem_read_data;

    // MEM/WB Register Outputs
    wire WB_mem_to_reg;
    wire WB_reg_write;
    wire [data_width-1:0] WB_alu_result;
    wire [data_width-1:0] WB_mem_data;
    wire [reg_addr_width-1:0] WB_rd;
    wire [address_width-1:0] WB_pc_plus_4;

    // WriteBack Stage Output
    wire [data_width-1:0] WB_write_data;  

    // Write Back Stage Output

    // ----------------- FETCH MODULE --------------------
     Fetch_Stage #(
        .data_width(data_width),
        .address_width(address_width),
        .mem_size_kb(mem_size_kb)
    ) fetch (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .branch_target(branch_target),
        .pc_src(pc_src),
        .pc_plus_4(IF_pc_plus_4),
        .pc_current(IF_pc_current),
        .instruction(IF_instruction)
    );

    // ----------------- IF/ID PIPELINE REGISTER -----------------
     IF_ID_Register #(
        .data_width(data_width),
        .address_width(address_width)
    ) if_id_reg (
        .clk(clk),
        .reset(reset),
        .if_id_write(if_id_write),
        .flush(if_id_flush),
        .IF_pc_plus_4(IF_pc_plus_4),
        .IF_pc_current(IF_pc_current), 
        .IF_instruction(IF_instruction),
        .ID_pc_plus_4(ID_pc_plus_4),
        .ID_pc_current(ID_pc_current),
        .ID_instruction(ID_instruction)
    );
    
    // ----------------- DECODE MODULE --------------------
    Decode_Stage #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width),
        .total_regs(total_regs)
    ) decode (
        .clk(clk),
        .reset(reset),
        .instruction(ID_instruction),
        .pc_plus_4(ID_pc_plus_4),
        .pc_current(ID_pc_current),
        .wb_reg_write(WB_reg_write),
        .wb_write_addr(WB_rd),
        .wb_write_data(WB_write_data),
        
        // Outputs
        .alu_src(ID_alu_src),
        .alu_op(ID_alu_op),
        .branch(ID_branch),
        .mem_read(ID_mem_read),
        .mem_write(ID_mem_write),
        .mem_to_reg(ID_mem_to_reg),
        .reg_write(ID_reg_write),
        .read_data_1(ID_read_data_1),
        .read_data_2(ID_read_data_2),
        .rs1(ID_rs1),
        .rs2(ID_rs2),
        .rd(ID_rd),
        .immediate(ID_immediate),
        .pc_plus_4_out(ID_pc_plus_4_out),
        .pc_current_out(ID_pc_current_out),
        .funct7(ID_funct7),
        .funct3(ID_funct3)
    );
    
    // ----------------- ID/EX PIPELINE REGISTER -----------------
    ID_EX_Register #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width)
    ) id_ex_reg (
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush),
        .control_mux_select(control_mux_select),
        
        // Inputs from Decode
        .ID_alu_src(ID_alu_src),
        .ID_alu_op(ID_alu_op),
        .ID_branch(ID_branch),
        .ID_mem_read(ID_mem_read),
        .ID_mem_write(ID_mem_write),
        .ID_mem_to_reg(ID_mem_to_reg),
        .ID_reg_write(ID_reg_write),
        .ID_read_data_1(ID_read_data_1),
        .ID_read_data_2(ID_read_data_2),
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .ID_rd(ID_rd),
        .ID_immediate(ID_immediate),
        .ID_pc_plus_4(ID_pc_plus_4_out),
        .ID_pc_current(ID_pc_current_out),        
        .ID_funct7(ID_funct7),
        .ID_funct3(ID_funct3),
        
        // Outputs to Execute
        .EX_alu_src(EX_alu_src),
        .EX_alu_op(EX_alu_op),
        .EX_branch(EX_branch),
        .EX_mem_read(EX_mem_read),
        .EX_mem_write(EX_mem_write),
        .EX_mem_to_reg(EX_mem_to_reg),
        .EX_reg_write(EX_reg_write),
        .EX_read_data_1(EX_read_data_1),
        .EX_read_data_2(EX_read_data_2),
        .EX_rs1(EX_rs1),
        .EX_rs2(EX_rs2),
        .EX_rd(EX_rd),
        .EX_immediate(EX_immediate),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_pc_current(EX_pc_current),
        .EX_funct7(EX_funct7),
        .EX_funct3(EX_funct3)
    );

    // ----------------- HAZARD DETECTION UNIT -----------------
    Hazard_Detection_Unit #(
        .reg_addr_width(reg_addr_width)
    ) hdu (
        // Inputs 
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .EX_mem_read(EX_mem_read),
        .EX_reg_write(EX_reg_write), 
        .EX_rd(EX_rd),
        .EX_branch_taken(EX_branch_taken),

        // Outputs
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_mux_select(control_mux_select)
    );

    // ----------------- EXECUTION STAGE -----------------
    Execute_Stage #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width)
    ) execute (
        // Control signals
        .alu_src(EX_alu_src),
        .alu_op(EX_alu_op),
        .branch(EX_branch),
        
        // Data inputs
        .read_data_1(EX_read_data_1),
        .read_data_2(EX_read_data_2),
        .rs1(EX_rs1),
        .rs2(EX_rs2),
        .immediate(EX_immediate),
        .pc_current(EX_pc_current),
        .funct7(EX_funct7),
        .funct3(EX_funct3),
        
        // Forwarding inputs from MEM stage
        .MEM_rd(MEM_rd),
        .MEM_reg_write(MEM_reg_write),
        .MEM_alu_result(MEM_alu_result),
        
        // Forwarding inputs from WB stage
        .WB_rd(WB_rd),
        .WB_reg_write(WB_reg_write),
        .WB_write_data(WB_write_data),
        
        // Outputs
        .alu_result(EX_alu_result),
        .write_data(EX_write_data),
        .zero_flag(EX_zero_flag),

        // BRANCH LOGIC TO BE FIXED ALONG WITH IMMEDIATE GENERATOR VALUE
        .branch_taken(EX_branch_taken),
        .branch_target(EX_branch_target)
    );

// ----------------- EX/MEM PIPELINE REGISTER -----------------
    EX_MEM_Register #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width)
    ) ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .flush(ex_mem_flush),
        
        // Control signals from Execute
        .EX_mem_read(EX_mem_read),
        .EX_mem_write(EX_mem_write),
        .EX_mem_to_reg(EX_mem_to_reg),
        .EX_reg_write(EX_reg_write),
        
        // Data from Execute
        .EX_alu_result(EX_alu_result),
        .EX_write_data(EX_write_data),
        .EX_rd(EX_rd),
        .EX_rs2(EX_rs2),
        .EX_pc_plus_4(EX_pc_plus_4),
        .EX_zero_flag(EX_zero_flag),
        
        // Outputs to Memory
        .MEM_mem_read(MEM_mem_read),
        .MEM_mem_write(MEM_mem_write),
        .MEM_mem_to_reg(MEM_mem_to_reg),
        .MEM_reg_write(MEM_reg_write),
        .MEM_alu_result(MEM_alu_result),
        .MEM_write_data(MEM_write_data),
        .MEM_rd(MEM_rd),
        .MEM_rs2(MEM_rs2),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        .MEM_zero_flag(MEM_zero_flag)
    );

    Memory_Stage #(
    .data_width(data_width),
    .address_width(address_width),
    .reg_addr_width(reg_addr_width),
    .mem_size_kb(mem_size_kb)
    ) memory (
        // Input
        .clk(clk),
        .mem_write(MEM_mem_write),
        .mem_address(MEM_alu_result),
        .MEM_write_data(MEM_write_data),
        .MEM_rs2(MEM_rs2),
        .WB_rd(WB_rd),                          // From MEM/WB register
        .WB_reg_write(WB_reg_write),            // From MEM/WB register
        .WB_write_data(WB_write_data),          // From WriteBack stage
        // Output
        .mem_read_data(mem_read_data)
    );

    // ----------------- MEM/WB PIPELINE REGISTER -----------------
    MEM_WB_Register #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width)
    ) mem_wb_reg (
        .clk(clk),
        .reset(reset),
        
        // Control signals from Memory
        .MEM_mem_to_reg(MEM_mem_to_reg),
        .MEM_reg_write(MEM_reg_write),
        
        // Data from Memory
        .MEM_alu_result(MEM_alu_result),
        .MEM_mem_data(mem_read_data),           // Output from Memory Stage
        .MEM_rd(MEM_rd),
        .MEM_pc_plus_4(MEM_pc_plus_4),
        
        // Outputs to WriteBack
        .WB_mem_to_reg(WB_mem_to_reg),
        .WB_reg_write(WB_reg_write),
        .WB_alu_result(WB_alu_result),
        .WB_mem_data(WB_mem_data),
        .WB_rd(WB_rd),
        .WB_pc_plus_4(WB_pc_plus_4)
    );

    // ----------------- WRITEBACK STAGE -----------------
    WriteBack_Stage #(
        .data_width(data_width)
    ) writeback (
        .mem_to_reg(WB_mem_to_reg),
        .alu_result(WB_alu_result),
        .mem_data(WB_mem_data),
        .write_data(WB_write_data)              // Goes Register File
    );
    
endmodule