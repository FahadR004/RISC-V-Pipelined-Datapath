// Main File

module RISC_V_Pipeline #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5,
    parameter total_regs = 32
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

    // TEMP ------------- TODO LATER
    wire wb_reg_write;
    wire [reg_addr_width-1:0] wb_write_addr;
    wire [data_width-1:0] wb_write_data;
    assign if_id_flush = 1'b0;
    assign id_ex_flush = 1'b0;
    assign pc_src = 1'b0;
    assign branch_target = {address_width{1'b0}};
    assign wb_reg_write = 1'b0;
    assign wb_write_addr = {reg_addr_width{1'b0}};
    assign wb_write_data = {data_width{1'b0}};

    // Execution Stage Output
    wire ex_branch_taken;

    // Memory Stage Output


    // Write Back Stage Output

    // ----------------- FETCH MODULE --------------------
     Fetch_Stage #(
        .data_width(data_width),
        .address_width(address_width)
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
        .wb_reg_write(wb_reg_write),
        .wb_write_addr(wb_write_addr),
        .wb_write_data(wb_write_data),
        
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
        .EX_rd(EX_rd),

        // Outputs
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_mux_select(control_mux_select),
        .if_id_flush(if_id_flush),
        .ex_branch_taken(ex_branch_taken)
    );


    // ----------------- EXECUTION STAGE -----------------
    Execute_Stage #(
       .data_width(data_width),               
       .address_width(address_width),         
       .reg_addr_width(reg_addr_width),       
       .total_regs(total_regs)     
    ) execute (
        // Inputs
        


        // Outputs

    );

    // ----------------- EX/MEM PIPELINE REGISTER -----------------

    EX_MEM_Register  #(
        
    ) ex_mem_reg (

    );

    // TO-DO
    
    // Memory_Stage memory();
    

    // MEM_WB MEM_WB();
    
    // WriteBack_Stage writeback();

endmodule