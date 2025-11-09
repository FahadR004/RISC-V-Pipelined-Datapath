`timescale 1ns / 1ps

module Decode_Stage_TB;

    // Parameters
    parameter data_width = 32;
    parameter address_width = 32;
    parameter reg_addr_width = 5;
    parameter total_regs = 32;
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk;
    reg reset;
    reg [data_width-1:0] instruction;
    reg [address_width-1:0] pc_plus_4;
    reg [address_width-1:0] pc_current;
    reg wb_reg_write;
    reg [reg_addr_width-1:0] wb_write_addr;
    reg [data_width-1:0] wb_write_data;
    
    wire alu_src;
    wire [1:0] alu_op;
    wire branch;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire reg_write;
    wire [data_width-1:0] read_data_1;
    wire [data_width-1:0] read_data_2;
    wire [reg_addr_width-1:0] rs1;
    wire [reg_addr_width-1:0] rs2;
    wire [reg_addr_width-1:0] rd;
    wire [data_width-1:0] immediate;
    wire [address_width-1:0] pc_plus_4_out;
    wire [address_width-1:0] pc_current_out;
    wire [6:0] funct7;
    wire [2:0] funct3;

    // Instantiate Decode Stage
    Decode_Stage #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width),
        .total_regs(total_regs)
    ) uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .pc_plus_4(pc_plus_4),
        .pc_current(pc_current),
        .wb_reg_write(wb_reg_write),
        .wb_write_addr(wb_write_addr),
        .wb_write_data(wb_write_data),
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

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("========================================");
        $display("Decode Stage Testbench");
        $display("========================================\n");
        
        // Initialize
        reset = 1;
        instruction = 32'h00000000;
        pc_plus_4 = 32'h00000004;
        pc_current = 32'h00000000;
        wb_reg_write = 0;
        wb_write_addr = 0;
        wb_write_data = 0;
        
        #(CLK_PERIOD);
        reset = 0;
        
        // Initialize some register values for testing
        #(CLK_PERIOD);
        wb_reg_write = 1;
        wb_write_addr = 5'd10;  // x10
        wb_write_data = 32'h00000064;  // 100
        #(CLK_PERIOD);
        wb_write_addr = 5'd11;  // x11
        wb_write_data = 32'h00000032;  // 50
        #(CLK_PERIOD);
        wb_reg_write = 0;
        
        // Test 1: R-type instruction (ADD x12, x10, x11)
        $display("Test 1: R-Type Instruction (ADD)");
        $display("------------------------");
        instruction = 32'h00B50633;  // ADD x12, x10, x11
        pc_current = 32'h00000100;
        pc_plus_4 = 32'h00000104;
        #1;  // Wait for combinational logic
        
        $display("Instruction: ADD x12, x10, x11");
        $display("Control Signals:");
        $display("  alu_src = %b (expect 0)", alu_src);
        $display("  alu_op = %b (expect 10)", alu_op);
        $display("  reg_write = %b (expect 1)", reg_write);
        $display("  mem_read = %b (expect 0)", mem_read);
        $display("  mem_write = %b (expect 0)", mem_write);
        $display("  branch = %b (expect 0)", branch);
        $display("Decoded Fields:");
        $display("  rs1 = %d, rs2 = %d, rd = %d", rs1, rs2, rd);
        $display("  funct3 = %b, funct7 = %b", funct3, funct7);
        $display("Register Values:");
        $display("  read_data_1 (x10) = %d", read_data_1);
        $display("  read_data_2 (x11) = %d", read_data_2);
        
        if (alu_src == 0 && alu_op == 2'b10 && reg_write == 1 && 
            rs1 == 10 && rs2 == 11 && rd == 12 &&
            read_data_1 == 100 && read_data_2 == 50) begin
            $display("✓ PASS: R-type decoded correctly\n");
        end else begin
            $display("✗ FAIL: R-type decoding error\n");
        end
        
        // Test 2: I-type instruction (ADDI x13, x10, 25)
        $display("Test 2: I-Type Instruction (ADDI)");
        $display("------------------------");
        instruction = 32'h01950693;  // ADDI x13, x10, 25
        #1;
        
        $display("Instruction: ADDI x13, x10, 25");
        $display("Control Signals:");
        $display("  alu_src = %b (expect 1)", alu_src);
        $display("  alu_op = %b (expect 10)", alu_op);
        $display("  reg_write = %b (expect 1)", reg_write);
        $display("Decoded Fields:");
        $display("  rs1 = %d, rd = %d", rs1, rd);
        $display("  immediate = %d (expect 25)", immediate);
        $display("Register Values:");
        $display("  read_data_1 (x10) = %d", read_data_1);
        
        if (alu_src == 1 && alu_op == 2'b10 && reg_write == 1 &&
            rs1 == 10 && rd == 13 && immediate == 32'd25) begin
            $display("✓ PASS: I-type decoded correctly\n");
        end else begin
            $display("✗ FAIL: I-type decoding error\n");
        end
        
        // Test 3: Load instruction (LW x14, 8(x10))
        $display("Test 3: Load Instruction (LW)");
        $display("------------------------");
        instruction = 32'h00852703;  // LW x14, 8(x10)
        #1;
        
        $display("Instruction: LW x14, 8(x10)");
        $display("Control Signals:");
        $display("  alu_src = %b (expect 1)", alu_src);
        $display("  alu_op = %b (expect 00)", alu_op);
        $display("  mem_read = %b (expect 1)", mem_read);
        $display("  mem_to_reg = %b (expect 1)", mem_to_reg);
        $display("  reg_write = %b (expect 1)", reg_write);
        $display("Decoded Fields:");
        $display("  rs1 = %d, rd = %d", rs1, rd);
        $display("  immediate = %d (expect 8)", immediate);
        
        if (alu_src == 1 && alu_op == 2'b00 && mem_read == 1 &&
            mem_to_reg == 1 && reg_write == 1 &&
            rs1 == 10 && rd == 14 && immediate == 32'd8) begin
            $display("✓ PASS: Load instruction decoded correctly\n");
        end else begin
            $display("✗ FAIL: Load instruction decoding error\n");
        end
        
        // Test 4: Store instruction (SW x11, 12(x10))
        $display("Test 4: Store Instruction (SW)");
        $display("------------------------");
        instruction = 32'h00B52623;  // SW x11, 12(x10)
        #1;
        
        $display("Instruction: SW x11, 12(x10)");
        $display("Control Signals:");
        $display("  alu_src = %b (expect 1)", alu_src);
        $display("  alu_op = %b (expect 00)", alu_op);
        $display("  mem_write = %b (expect 1)", mem_write);
        $display("  reg_write = %b (expect 0)", reg_write);
        $display("Decoded Fields:");
        $display("  rs1 = %d, rs2 = %d", rs1, rs2);
        $display("  immediate = %d (expect 12)", immediate);
        $display("  read_data_2 (store data) = %d", read_data_2);
        
        if (alu_src == 1 && alu_op == 2'b00 && mem_write == 1 &&
            reg_write == 0 && rs1 == 10 && rs2 == 11 &&
            immediate == 32'd12) begin
            $display("✓ PASS: Store instruction decoded correctly\n");
        end else begin
            $display("✗ FAIL: Store instruction decoding error\n");
        end
        
        // Test 5: Branch instruction (BEQ x10, x11, 16)
        $display("Test 5: Branch Instruction (BEQ)");
        $display("------------------------");
        instruction = 32'h00B50863;  // BEQ x10, x11, 16
        #1;
        
        $display("Instruction: BEQ x10, x11, 16");
        $display("Control Signals:");
        $display("  alu_src = %b (expect 0)", alu_src);
        $display("  alu_op = %b (expect 01)", alu_op);
        $display("  branch = %b (expect 1)", branch);
        $display("  reg_write = %b (expect 0)", reg_write);
        $display("Decoded Fields:");
        $display("  rs1 = %d, rs2 = %d", rs1, rs2);
        $display("  immediate = %d (expect 16)", immediate);
        $display("  funct3 = %b (000 for BEQ)", funct3);
        $display("Register Values:");
        $display("  read_data_1 (x10) = %d", read_data_1);
        $display("  read_data_2 (x11) = %d", read_data_2);
        
        if (alu_src == 0 && alu_op == 2'b01 && branch == 1 &&
            reg_write == 0 && rs1 == 10 && rs2 == 11 &&
            immediate == 32'd16 && funct3 == 3'b000) begin
            $display("✓ PASS: Branch instruction decoded correctly\n");
        end else begin
            $display("✗ FAIL: Branch instruction decoding error\n");
        end
        
        // Test 6: Immediate generation for negative values
        $display("Test 6: Negative Immediate (ADDI x15, x10, -10)");
        $display("------------------------");
        instruction = 32'hFF650793;  // ADDI x15, x10, -10
        #1;
        
        $display("Instruction: ADDI x15, x10, -10");
        $display("  immediate = %d (expect -10)", $signed(immediate));
        $display("  immediate (hex) = 0x%h", immediate);
        
        if ($signed(immediate) == -10) begin
            $display("✓ PASS: Negative immediate sign-extended correctly\n");
        end else begin
            $display("✗ FAIL: Negative immediate error\n");
        end
        
        // Test 7: Register file write and read
        $display("Test 7: Register File Write/Read");
        $display("------------------------");
        instruction = 32'h00000000;  // NOP
        #(CLK_PERIOD);
        
        // Write to x20
        wb_reg_write = 1;
        wb_write_addr = 5'd20;
        wb_write_data = 32'hDEADBEEF;
        #(CLK_PERIOD);
        wb_reg_write = 0;
        
        // Read from x20
        instruction = 32'h014A0A33;  // ADD x20, x20, x20 (read x20 twice)
        #1;
        
        $display("Wrote 0xDEADBEEF to x20");
        $display("Read back: read_data_1 = 0x%h, read_data_2 = 0x%h", 
                 read_data_1, read_data_2);
        
        if (read_data_1 == 32'hDEADBEEF && read_data_2 == 32'hDEADBEEF) begin
            $display("✓ PASS: Register file write/read works\n");
        end else begin
            $display("✗ FAIL: Register file error\n");
        end
        
        // Test 8: x0 always reads as 0
        $display("Test 8: x0 Register (Always Zero)");
        $display("------------------------");
        
        // Try to write to x0
        wb_reg_write = 1;
        wb_write_addr = 5'd0;
        wb_write_data = 32'h12345678;
        #(CLK_PERIOD);
        wb_reg_write = 0;
        
        // Read x0
        instruction = 32'h00000033;  // ADD x0, x0, x0
        #1;
        
        $display("Attempted to write 0x12345678 to x0");
        $display("Read back: read_data_1 = 0x%h (expect 0)", read_data_1);
        
        if (read_data_1 == 32'h00000000) begin
            $display("✓ PASS: x0 always reads as zero\n");
        end else begin
            $display("✗ FAIL: x0 not hardwired to zero\n");
        end
        
        $display("========================================");
        $display("Decode Stage Tests Complete");
        $display("========================================");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("decode_stage_tb.vcd");
        $dumpvars(0, Decode_Stage_TB);
    end

endmodule