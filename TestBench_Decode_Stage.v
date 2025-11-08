`timescale 1ns/1ps

module Decode_Stage_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 12;
    parameter REG_ADDR_WIDTH = 5;
    parameter TOTAL_REGS = 32;

    // Inputs
    reg clk;
    reg reset;
    reg [DATA_WIDTH-1:0] instruction;
    reg [ADDR_WIDTH-1:0] pc_current;
    reg [ADDR_WIDTH-1:0] pc_plus_4;
    reg WB_reg_write;
    reg [REG_ADDR_WIDTH-1:0] WB_write_addr;
    reg [DATA_WIDTH-1:0] WB_write_data;

    // Outputs
    wire alu_src;
    wire [1:0] alu_op;
    wire branch;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire reg_write;
    wire [DATA_WIDTH-1:0] read_data_1;
    wire [DATA_WIDTH-1:0] read_data_2;
    wire [REG_ADDR_WIDTH-1:0] rs1;
    wire [REG_ADDR_WIDTH-1:0] rs2;
    wire [REG_ADDR_WIDTH-1:0] rd;
    wire [DATA_WIDTH-1:0] immediate;
    wire [ADDR_WIDTH-1:0] pc_plus_4_out;
    wire [ADDR_WIDTH-1:0] pc_current_out;
    wire [6:0] funct7;
    wire [2:0] funct3;

    Decode_Stage #(
        .data_width(DATA_WIDTH),
        .address_width(ADDR_WIDTH),
        .reg_addr_width(REG_ADDR_WIDTH),
        .total_regs(TOTAL_REGS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .pc_current(pc_current),
        .pc_plus_4(pc_plus_4),
        .WB_reg_write(WB_reg_write),
        .WB_write_addr(WB_write_addr),
        .WB_write_data(WB_write_data),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .immediate(immediate),
        .pc_plus_4_out(pc_plus_4_out),
        .pc_current_out(pc_current_out),
        .funct7(funct7),
        .funct3(funct3)
    );

    //clock
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 0;
        pc_current = 12'h004;
        pc_plus_4 = 12'h008;
        WB_reg_write = 0;
        WB_write_addr = 0;
        WB_write_data = 0;

        // ===== TEST CASE 1: R-Type (ADD) =====
        // opcode = 0110011, funct3 = 000, funct7 = 0000000
        // rs1 = 2, rs2 = 3, rd = 1
        instruction = 32'b0000000_00011_00010_000_00001_0110011;
        #10;
        $display("\n--- TEST 1: R-Type (ADD) ---");
        $display("Opcode = %b | ALU_OP = %b | RegWrite = %b | ALU_SRC = %b", instruction[6:0], alu_op, reg_write, alu_src);
        $display("RS1 = %0d | RS2 = %0d | RD = %0d | Funct3 = %b | Funct7 = %b", rs1, rs2, rd, funct3, funct7);

        // ===== TEST CASE 2: I-Type (Load Word - LW) =====
        // opcode = 0000011
        instruction = 32'b000000000100_00010_010_00001_0000011; // LW x1, 4(x2)
        #10;
        $display("\n--- TEST 2: I-Type (LW) ---");
        $display("Opcode = %b | MemRead = %b | MemToReg = %b | ALU_SRC = %b", instruction[6:0], mem_read, mem_to_reg, alu_src);
        $display("Immediate = %d (Expected: 4)", immediate);

        // ===== TEST CASE 3: S-Type (SW) =====
        // opcode = 0100011
        instruction = 32'b0000000_00011_00010_010_00100_0100011; // SW x3, 4(x2)
        #10;
        $display("\n--- TEST 3: S-Type (SW) ---");
        $display("Opcode = %b | MemWrite = %b | ALU_SRC = %b", instruction[6:0], mem_write, alu_src);
        $display("Immediate = %d (Expected: 4)", immediate);

        // ===== TEST CASE 4: B-Type (BEQ) =====
        // opcode = 1100011
        instruction = 32'b0000000_00011_00010_000_00100_1100011; // BEQ x2, x3, offset=4
        #10;
        $display("\n--- TEST 4: B-Type (BEQ) ---");
        $display("Opcode = %b | Branch = %b | ALU_OP = %b", instruction[6:0], branch, alu_op);
        $display("Immediate = %d (Expected: 4)", immediate);

        // ===== TEST CASE 5: Register File Write =====
        $display("\n--- TEST 5: Register File Write ---");
        WB_reg_write = 1;
        WB_write_addr = 5'd1;
        WB_write_data = 32'hDEADBEEF;
        #10; // Write at posedge
        WB_reg_write = 0;
        instruction = 32'b0000000_00000_00001_000_00000_0110011; // Read from x1
        #10;
        $display("Read Data 1 = %h (Expected: DEADBEEF)", read_data_1);

        // ===== TEST CASE 6: Default/Unknown Opcode =====
        instruction = 32'b0000000_00000_00000_000_00000_1111111;
        #10;
        $display("\n--- TEST 6: Unknown Opcode ---");
        $display("Opcode = %b | All Control Signals = 0?", instruction[6:0]);
        $display("RegWrite=%b | Branch=%b | MemRead=%b | MemWrite=%b", reg_write, branch, mem_read, mem_write);

        // Finish
        #20;
        $stop;
    end
endmodule
