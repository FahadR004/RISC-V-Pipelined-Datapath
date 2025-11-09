`timescale 1ns / 1ps

module Execute_Stage_TB;

    // Parameters
    parameter data_width = 32;
    parameter address_width = 32;
    parameter reg_addr_width = 5;
    parameter CLK_PERIOD = 10;

    // Signals
    reg alu_src;
    reg [1:0] alu_op;
    reg branch;
    reg [data_width-1:0] read_data_1;
    reg [data_width-1:0] read_data_2;
    reg [reg_addr_width-1:0] rs1;
    reg [reg_addr_width-1:0] rs2;
    reg [data_width-1:0] immediate;
    reg [address_width-1:0] pc_current;
    reg [6:0] funct7;
    reg [2:0] funct3;
    reg [1:0] forward_A;
    reg [1:0] forward_B;
    reg [data_width-1:0] MEM_alu_result;
    reg [data_width-1:0] WB_write_data;
    reg [reg_addr_width-1:0] MEM_rd;
    reg MEM_reg_write;
    reg [reg_addr_width-1:0] WB_rd;
    reg WB_reg_write;
    
    wire [data_width-1:0] alu_result;
    wire [data_width-1:0] write_data;
    wire zero_flag;
    wire branch_taken;
    wire [address_width-1:0] branch_target;

    // Instantiate Execute Stage
    Execute_Stage #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width)
    ) uut (
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .pc_current(pc_current),
        .funct7(funct7),
        .funct3(funct3),
        .MEM_rd(MEM_rd),
        .MEM_reg_write(MEM_reg_write),
        .MEM_alu_result(MEM_alu_result),
        .WB_rd(WB_rd),
        .WB_reg_write(WB_reg_write),
        .WB_write_data(WB_write_data),
        .alu_result(alu_result),
        .write_data(write_data),
        .zero_flag(zero_flag),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    // Test sequence
    initial begin
        $display("========================================");
        $display("Execute Stage Testbench");
        $display("========================================\n");
        
        // Initialize
        alu_src = 0;
        alu_op = 2'b00;
        branch = 0;
        read_data_1 = 0;
        read_data_2 = 0;
        rs1 = 0;
        rs2 = 0;
        immediate = 0;
        pc_current = 32'h00000100;
        funct7 = 0;
        funct3 = 0;
        MEM_alu_result = 0;
        WB_write_data = 0;
        MEM_rd = 0;
        MEM_reg_write = 0;
        WB_rd = 0;
        WB_reg_write = 0;
        
        #10;
        
        // Test 1: ADD operation (R-type)
        $display("Test 1: ADD Operation");
        $display("------------------------");
        alu_op = 2'b10;      // R-type
        alu_src = 0;         // Use rs2
        read_data_1 = 32'd100;
        read_data_2 = 32'd50;
        funct3 = 3'b000;     // ADD
        funct7 = 7'b0000000; // ADD (not SUB)
        rs1 = 5'd10;
        rs2 = 5'd11;
        #1;
        
        $display("Operation: 100 + 50");
        $display("  ALU Result = %d (expect 150)", alu_result);
        $display("  Zero Flag = %b (expect 0)", zero_flag);
        
        if (alu_result == 32'd150 && zero_flag == 0) begin
            $display("✓ PASS: ADD works correctly\n");
        end else begin
            $display("✗ FAIL: ADD error\n");
        end
        
        // Test 2: SUB operation
        $display("Test 2: SUB Operation");
        $display("------------------------");
        funct7 = 7'b0100000; // SUB
        #1;
        
        $display("Operation: 100 - 50");
        $display("  ALU Result = %d (expect 50)", alu_result);
        
        if (alu_result == 32'd50) begin
            $display("✓ PASS: SUB works correctly\n");
        end else begin
            $display("✗ FAIL: SUB error\n");
        end
        
        // Test 3: AND operation
        $display("Test 3: AND Operation");
        $display("------------------------");
        read_data_1 = 32'hF0F0F0F0;
        read_data_2 = 32'h0F0F0F0F;
        funct3 = 3'b111;     // AND
        funct7 = 7'b0000000;
        #1;
        
        $display("Operation: 0xF0F0F0F0 AND 0x0F0F0F0F");
        $display("  ALU Result = 0x%h (expect 0x00000000)", alu_result);
        $display("  Zero Flag = %b (expect 1)", zero_flag);
        
        if (alu_result == 32'h00000000 && zero_flag == 1) begin
            $display("✓ PASS: AND works correctly\n");
        end else begin
            $display("✗ FAIL: AND error\n");
        end
        
        // Test 4: OR operation
        $display("Test 4: OR Operation");
        $display("------------------------");
        read_data_1 = 32'hF0F0F0F0;
        read_data_2 = 32'h0F0F0F0F;
        funct3 = 3'b110;     // OR
        #1;
        
        $display("Operation: 0xF0F0F0F0 OR 0x0F0F0F0F");
        $display("  ALU Result = 0x%h (expect 0xFFFFFFFF)", alu_result);
        
        if (alu_result == 32'hFFFFFFFF) begin
            $display("✓ PASS: OR works correctly\n");
        end else begin
            $display("✗ FAIL: OR error\n");
        end
        
        // Test 5: XOR operation
        $display("Test 5: XOR Operation");
        $display("------------------------");
        funct3 = 3'b100;     // XOR
        #1;
        
        $display("Operation: 0xF0F0F0F0 XOR 0x0F0F0F0F");
        $display("  ALU Result = 0x%h (expect 0xFFFFFFFF)", alu_result);
        
        if (alu_result == 32'hFFFFFFFF) begin
            $display("✓ PASS: XOR works correctly\n");
        end else begin
            $display("✗ FAIL: XOR error\n");
        end
        
        // Test 6: ADDI (I-type with immediate)
        $display("Test 6: ADDI Operation");
        $display("------------------------");
        alu_src = 1;         // Use immediate
        read_data_1 = 32'd100;
        immediate = 32'd25;
        funct3 = 3'b000;     // ADD
        funct7 = 7'b0000000;
        #1;
        
        $display("Operation: 100 + 25 (immediate)");
        $display("  ALU Result = %d (expect 125)", alu_result);
        
        if (alu_result == 32'd125) begin
            $display("✓ PASS: ADDI works correctly\n");
        end else begin
            $display("✗ FAIL: ADDI error\n");
        end
        
        // Test 7: Load address calculation
        $display("Test 7: Load Address Calculation");
        $display("------------------------");
        alu_op = 2'b00;      // Load/Store (ADD)
        alu_src = 1;         // Use immediate (offset)
        read_data_1 = 32'h00001000;  // Base address
        immediate = 32'd8;            // Offset
        #1;
        
        $display("Operation: 0x1000 + 8 (load address)");
        $display("  ALU Result = 0x%h (expect 0x1008)", alu_result);
        
        if (alu_result == 32'h00001008) begin
            $display("✓ PASS: Load address calculation works\n");
        end else begin
            $display("✗ FAIL: Load address calculation error\n");
        end
        
        // Test 8: Shift Left Logical (SLL)
        $display("Test 8: SLL Operation");
        $display("------------------------");
        alu_op = 2'b10;      // R-type
        alu_src = 0;         // Use rs2
        read_data_1 = 32'h00000001;
        read_data_2 = 32'd4;  // Shift by 4
        funct3 = 3'b001;     // SLL
        funct7 = 7'b0000000;
        #1;
        
        $display("Operation: 1 << 4");
        $display("  ALU Result = %d (expect 16)", alu_result);
        
        if (alu_result == 32'd16) begin
            $display("✓ PASS: SLL works correctly\n");
        end else begin
            $display("✗ FAIL: SLL error\n");
        end
        
        // Test 9: Shift Right Logical (SRL)
        $display("Test 9: SRL Operation");
        $display("------------------------");
        read_data_1 = 32'h00000080;  // 128
        read_data_2 = 32'd3;          // Shift by 3
        funct3 = 3'b101;              // SRL/SRA
        funct7 = 7'b0000000;          // SRL (not SRA)
        #1;
        
        $display("Operation: 128 >> 3");
        $display("  ALU Result = %d (expect 16)", alu_result);
        
        if (alu_result == 32'd16) begin
            $display("✓ PASS: SRL works correctly\n");
        end else begin
            $display("✗ FAIL: SRL error\n");
        end
        
        // Test 10: Shift Right Arithmetic (SRA) with negative number
        $display("Test 10: SRA Operation (Negative)");
        $display("------------------------");
        read_data_1 = 32'hFFFFFFF0;  // -16 in two's complement
        read_data_2 = 32'd2;          // Shift by 2
        funct7 = 7'b0100000;          // SRA
        #1;
        
        $display("Operation: -16 >>> 2 (arithmetic)");
        $display("  ALU Result = 0x%h (expect 0xFFFFFFFC = -4)", alu_result);
        
        if (alu_result == 32'hFFFFFFFC) begin
            $display("✓ PASS: SRA works correctly\n");
        end else begin
            $display("✗ FAIL: SRA error\n");
        end
        
        // Test 11: BEQ (branch if equal) - Equal case
        $display("Test 11: BEQ - Equal Case");
        $display("------------------------");
        branch = 1;
        alu_op = 2'b01;      // Branch
        read_data_1 = 32'd100;
        read_data_2 = 32'd100;
        immediate = 32'd16;   // Branch offset
        pc_current = 32'h00000100;
        funct3 = 3'b000;     // BEQ
        #1;
        
        $display("Comparing: 100 == 100");
        $display("  Branch Taken = %b (expect 1)", branch_taken);
        $display("  Branch Target = 0x%h (expect 0x110)", branch_target);
        
        if (branch_taken == 1 && branch_target == 32'h00000110) begin
            $display("✓ PASS: BEQ (equal) works correctly\n");
        end else begin
            $display("✗ FAIL: BEQ (equal) error\n");
        end
        
        // Test 12: BEQ - Not equal case
        $display("Test 12: BEQ - Not Equal Case");
        $display("------------------------");
        read_data_2 = 32'd50;
        #1;
        
        $display("Comparing: 100 == 50");
        $display("  Branch Taken = %b (expect 0)", branch_taken);
        
        if (branch_taken == 0) begin
            $display("✓ PASS: BEQ (not equal) works correctly\n");
        end else begin
            $display("✗ FAIL: BEQ (not equal) error\n");
        end
        
        // Test 13: BNE (branch if not equal)
        $display("Test 13: BNE");
        $display("------------------------");
        read_data_1 = 32'd100;
        read_data_2 = 32'd50;
        funct3 = 3'b001;     // BNE
        #1;
        
        $display("Comparing: 100 != 50");
        $display("  Branch Taken = %b (expect 1)", branch_taken);
        
        if (branch_taken == 1) begin
            $display("✓ PASS: BNE works correctly\n");
        end else begin
            $display("✗ FAIL: BNE error\n");
        end
        
        // Test 14: BLT (branch if less than, signed)
        $display("Test 14: BLT (Signed)");
        $display("------------------------");
        read_data_1 = 32'hFFFFFFF0;  // -16 (signed)
        read_data_2 = 32'd10;         // 10 (signed)
        funct3 = 3'b100;              // BLT
        #1;
        
        $display("Comparing: -16 < 10 (signed)");
        $display("  Branch Taken = %b (expect 1)", branch_taken);
        
        if (branch_taken == 1) begin
            $display("✓ PASS: BLT (signed) works correctly\n");
        end else begin
            $display("✗ FAIL: BLT (signed) error\n");
        end
        
        // Test 15: BGE (branch if greater or equal, signed)
        $display("Test 15: BGE (Signed)");
        $display("------------------------");
        read_data_1 = 32'd10;
        read_data_2 = 32'hFFFFFFF0;  // -16
        funct3 = 3'b101;              // BGE
        #1;
        
        $display("Comparing: 10 >= -16 (signed)");
        $display("  Branch Taken = %b (expect 1)", branch_taken);
        
        if (branch_taken == 1) begin
            $display("✓ PASS: BGE (signed) works correctly\n");
        end else begin
            $display("✗ FAIL: BGE (signed) error\n");
        end
        
        // Test 16: BLTU (branch if less than, unsigned)
        $display("Test 16: BLTU (Unsigned)");
        $display("------------------------");
        read_data_1 = 32'h00000005;  // 5 (unsigned)
        read_data_2 = 32'hFFFFFFF0;  // Large unsigned number
        funct3 = 3'b110;              // BLTU
        #1;
        
        $display("Comparing: 5 < 0xFFFFFFF0 (unsigned)");
        $display("  Branch Taken = %b (expect 1)", branch_taken);
        
        if (branch_taken == 1) begin
            $display("✓ PASS: BLTU (unsigned) works correctly\n");
        end else begin
            $display("✗ FAIL: BLTU (unsigned) error\n");
        end
        
        // Test 17: BGEU (branch if greater or equal, unsigned)
        $display("Test 17: BGEU (Unsigned)");
        $display("------------------------");
        read_data_1 = 32'hFFFFFFF0;
        read_data_2 = 32'h00000005;
        funct3 = 3'b111;              // BGEU
        #1;
        
        $display("Comparing: 0xFFFFFFF0 >= 5 (unsigned)");
        $display("  Branch Taken = %b (expect 1)", branch_taken);
        
        if (branch_taken == 1) begin
            $display("✓ PASS: BGEU (unsigned) works correctly\n");
        end else begin
            $display("✗ FAIL: BGEU (unsigned) error\n");
        end
        
        // Test 18: Forwarding from MEM stage
        $display("Test 18: Forwarding from MEM Stage");
        $display("------------------------");
        branch = 0;
        alu_op = 2'b10;
        alu_src = 0;
        read_data_1 = 32'd100;  // Original value
        read_data_2 = 32'd50;
        rs1 = 5'd5;
        rs2 = 5'd6;
        MEM_rd = 5'd5;          // MEM stage is writing to x5
        MEM_reg_write = 1;
        MEM_alu_result = 32'd200;  // Forwarded value
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #1;
        
        $display("Without forwarding: 100 + 50 = 150");
        $display("With forwarding from MEM (x5 = 200): 200 + 50 = 250");
        $display("  ALU Result = %d (expect 250)", alu_result);
        
        if (alu_result == 32'd250) begin
            $display("✓ PASS: MEM stage forwarding works\n");
        end else begin
            $display("✗ FAIL: MEM stage forwarding error\n");
        end
        
        // Test 19: Forwarding from WB stage
        $display("Test 19: Forwarding from WB Stage");
        $display("------------------------");
        MEM_reg_write = 0;      // No MEM forwarding
        WB_rd = 5'd5;           // WB stage is writing to x5
        WB_reg_write = 1;
        WB_write_data = 32'd300;  // Forwarded value
        #1;
        
        $display("With forwarding from WB (x5 = 300): 300 + 50 = 350");
        $display("  ALU Result = %d (expect 350)", alu_result);
        
        if (alu_result == 32'd350) begin
            $display("✓ PASS: WB stage forwarding works\n");
        end else begin
            $display("✗ FAIL: WB stage forwarding error\n");
        end
        
        // Test 20: MEM forwarding priority over WB
        $display("Test 20: MEM Forwarding Priority");
        $display("------------------------");
        MEM_reg_write = 1;      // Both MEM and WB forwarding
        MEM_alu_result = 32'd200;
        WB_write_data = 32'd300;
        #1;
        
        $display("MEM has x5 = 200, WB has x5 = 300");
        $display("MEM should have priority (more recent)");
        $display("  ALU Result = %d (expect 250 = 200 + 50)", alu_result);
        
        if (alu_result == 32'd250) begin
            $display("✓ PASS: MEM forwarding priority works\n");
        end else begin
            $display("✗ FAIL: MEM forwarding priority error\n");
        end
        
        // Test 21: No forwarding for x0
        $display("Test 21: No Forwarding for x0");
        $display("------------------------");
        rs1 = 5'd0;             // Reading x0
        read_data_1 = 32'd0;
        MEM_rd = 5'd0;          // MEM writing to x0
        MEM_reg_write = 1;
        MEM_alu_result = 32'd999;
        #1;
        
        $display("MEM trying to forward x0 = 999");
        $display("x0 should always be 0 (no forwarding)");
        $display("  ALU Result = %d (expect 50 = 0 + 50)", alu_result);
        
        if (alu_result == 32'd50) begin
            $display("✓ PASS: x0 not forwarded (correct)\n");
        end else begin
            $display("✗ FAIL: x0 forwarding error\n");
        end
        
        // Test 22: Store data forwarding (rs2)
        $display("Test 22: Store Data Forwarding");
        $display("------------------------");
        alu_op = 2'b00;         // Load/Store
        alu_src = 1;            // Use immediate
        rs1 = 5'd10;
        rs2 = 5'd11;            // Store data source
        read_data_1 = 32'h1000;
        read_data_2 = 32'h00000001;  // Original store data
        immediate = 32'd8;
        MEM_rd = 5'd11;         // Forwarding to rs2
        MEM_reg_write = 1;
        MEM_alu_result = 32'hDEADBEEF;  // Forwarded store data
        #1;
        
        $display("Store address: 0x1000 + 8 = 0x%h", alu_result);
        $display("Store data (forwarded): 0x%h (expect 0xDEADBEEF)", write_data);
        
        if (alu_result == 32'h00001008 && write_data == 32'hDEADBEEF) begin
            $display("✓ PASS: Store data forwarding works\n");
        end else begin
            $display("✗ FAIL: Store data forwarding error\n");
        end
        
        $display("========================================");
        $display("Execute Stage Tests Complete");
        $display("========================================");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("execute_stage_tb.vcd");
        $dumpvars(0, Execute_Stage_TB);
    end

endmodule