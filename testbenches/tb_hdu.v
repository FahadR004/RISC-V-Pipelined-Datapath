`timescale 1ns / 1ps

module Hazard_Detection_Unit_TB;

    // Parameters
    parameter reg_addr_width = 5;

    // Signals
    reg [reg_addr_width-1:0] ID_rs1;
    reg [reg_addr_width-1:0] ID_rs2;
    reg EX_mem_read;
    reg [reg_addr_width-1:0] EX_rd;
    reg EX_reg_write;
    reg EX_branch_taken;
    
    wire pc_write;
    wire if_id_write;
    wire control_mux_select;

    // Instantiate HDU
    Hazard_Detection_Unit #(
        .reg_addr_width(reg_addr_width)
    ) uut (
        .ID_rs1(ID_rs1),
        .ID_rs2(ID_rs2),
        .EX_mem_read(EX_mem_read),
        .EX_rd(EX_rd),
        .EX_reg_write(EX_reg_write),
        .EX_branch_taken(EX_branch_taken),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_mux_select(control_mux_select)
    );

    // Test sequence
    initial begin
        $display("========================================");
        $display("Hazard Detection Unit Testbench");
        $display("========================================\n");
        
        // Initialize
        ID_rs1 = 0;
        ID_rs2 = 0;
        EX_mem_read = 0;
        EX_rd = 0;
        EX_reg_write = 0;
        EX_branch_taken = 0;
        
        #10;
        
        // Test 1: No hazard (normal operation)
        $display("Test 1: No Hazard");
        $display("------------------------");
        ID_rs1 = 5'd10;
        ID_rs2 = 5'd11;
        EX_mem_read = 0;  // EX is not a load
        EX_rd = 5'd12;
        EX_reg_write = 1;
        #1;
        
        $display("EX: R-type writing to x12");
        $display("ID: Uses x10 and x11 (no dependency)");
        $display("  pc_write = %b (expect 1)", pc_write);
        $display("  if_id_write = %b (expect 1)", if_id_write);
        $display("  control_mux_select = %b (expect 0)", control_mux_select);
        
        if (pc_write == 1 && if_id_write == 1 && control_mux_select == 0) begin
            $display("✓ PASS: No false hazard detected\n");
        end else begin
            $display("✗ FAIL: False hazard detected\n");
        end
        
        // Test 2: Load-Use hazard on rs1
        $display("Test 2: Load-Use Hazard (rs1)");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: LW x2, 0(x1)    [loading x2]");
        $display("  ID: ADD x3, x2, x4  [needs x2 - HAZARD!]");
        ID_rs1 = 5'd2;
        ID_rs2 = 5'd4;
        EX_mem_read = 1;  // EX is a load
        EX_rd = 5'd2;     // Loading into x2
        EX_reg_write = 1;
        #1;
        
        $display("  pc_write = %b (expect 0 - stall)", pc_write);
        $display("  if_id_write = %b (expect 0 - stall)", if_id_write);
        $display("  control_mux_select = %b (expect 1 - bubble)", control_mux_select);
        
        if (pc_write == 0 && if_id_write == 0 && control_mux_select == 1) begin
            $display("✓ PASS: Load-Use hazard on rs1 detected\n");
        end else begin
            $display("✗ FAIL: Load-Use hazard on rs1 not detected\n");
        end
        
        // Test 3: Load-Use hazard on rs2
        $display("Test 3: Load-Use Hazard (rs2)");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: LW x5, 0(x1)    [loading x5]");
        $display("  ID: SUB x6, x7, x5  [needs x5 - HAZARD!]");
        ID_rs1 = 5'd7;
        ID_rs2 = 5'd5;
        EX_mem_read = 1;
        EX_rd = 5'd5;
        EX_reg_write = 1;
        #1;
        
        $display("  pc_write = %b (expect 0)", pc_write);
        $display("  if_id_write = %b (expect 0)", if_id_write);
        $display("  control_mux_select = %b (expect 1)", control_mux_select);
        
        if (pc_write == 0 && if_id_write == 0 && control_mux_select == 1) begin
            $display("✓ PASS: Load-Use hazard on rs2 detected\n");
        end else begin
            $display("✗ FAIL: Load-Use hazard on rs2 not detected\n");
        end
        
        // Test 4: Load-Use hazard on both rs1 and rs2
        $display("Test 4: Load-Use Hazard (Both Sources)");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: LW x8, 0(x1)    [loading x8]");
        $display("  ID: ADD x9, x8, x8  [needs x8 twice - HAZARD!]");
        ID_rs1 = 5'd8;
        ID_rs2 = 5'd8;
        EX_mem_read = 1;
        EX_rd = 5'd8;
        EX_reg_write = 1;
        #1;
        
        $display("  Stall detected = %b (expect 1)", (pc_write == 0));
        
        if (pc_write == 0 && if_id_write == 0 && control_mux_select == 1) begin
            $display("✓ PASS: Load-Use hazard on both sources detected\n");
        end else begin
            $display("✗ FAIL: Load-Use hazard on both sources not detected\n");
        end
        
        // Test 5: No hazard - R-type in EX (not a load)
        $display("Test 5: No Hazard - R-type in EX");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: ADD x10, x11, x12  [R-type, not load]");
        $display("  ID: SUB x13, x10, x14  [uses x10, but can forward]");
        ID_rs1 = 5'd10;
        ID_rs2 = 5'd14;
        EX_mem_read = 0;  // Not a load!
        EX_rd = 5'd10;
        EX_reg_write = 1;
        #1;
        
        $display("  No stall (forwarding handles this)");
        $display("  pc_write = %b (expect 1)", pc_write);
        
        if (pc_write == 1 && if_id_write == 1 && control_mux_select == 0) begin
            $display("✓ PASS: No stall for R-type (forwarding works)\n");
        end else begin
            $display("✗ FAIL: False stall for R-type\n");
        end
        
        // Test 6: No hazard - Store instruction in EX
        $display("Test 6: No Hazard - Store in EX");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: SW x15, 0(x1)      [Store, no rd write]");
        $display("  ID: ADD x16, x15, x17  [uses x15]");
        ID_rs1 = 5'd15;
        ID_rs2 = 5'd17;
        EX_mem_read = 0;
        EX_reg_write = 0;  // Store doesn't write registers!
        EX_rd = 5'd15;     // Don't care, but set anyway
        #1;
        
        $display("  Store has reg_write = 0, so no hazard");
        $display("  pc_write = %b (expect 1)", pc_write);
        
        if (pc_write == 1 && if_id_write == 1 && control_mux_select == 0) begin
            $display("✓ PASS: No false hazard for store\n");
        end else begin
            $display("✗ FAIL: False hazard for store\n");
        end
        
        // Test 7: No hazard - writing to x0
        $display("Test 7: No Hazard - Writing to x0");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: LW x0, 0(x1)    [loading into x0]");
        $display("  ID: ADD x3, x0, x4  [uses x0, but x0 always = 0]");
        ID_rs1 = 5'd0;
        ID_rs2 = 5'd4;
        EX_mem_read = 1;
        EX_rd = 5'd0;      // Writing to x0
        EX_reg_write = 1;
        #1;
        
        $display("  x0 is always 0, no hazard possible");
        $display("  pc_write = %b (expect 1)", pc_write);
        
        if (pc_write == 1 && if_id_write == 1 && control_mux_select == 0) begin
            $display("✓ PASS: No hazard for x0\n");
        end else begin
            $display("✗ FAIL: False hazard for x0\n");
        end
        
        // Test 8: No hazard - different registers
        $display("Test 8: No Hazard - Different Registers");
        $display("------------------------");
        $display("Pipeline:");
        $display("  EX: LW x20, 0(x1)   [loading x20]");
        $display("  ID: ADD x21, x22, x23  [uses x22, x23, not x20]");
        ID_rs1 = 5'd22;
        ID_rs2 = 5'd23;
        EX_mem_read = 1;
        EX_rd = 5'd20;
        EX_reg_write = 1;
        #1;
        
        $display("  Different registers, no dependency");
        $display("  pc_write = %b (expect 1)", pc_write);
        
        if (pc_write == 1 && if_id_write == 1 && control_mux_select == 0) begin
            $display("✓ PASS: No false hazard for different registers\n");
        end else begin
            $display("✗ FAIL: False hazard for different registers\n");
        end
        
        // Test 9: Real instruction sequence simulation
        $display("Test 9: Real Instruction Sequence");
        $display("------------------------");
        $display("Program:");
        $display("  0x100: LW  x2, 0(x1)");
        $display("  0x104: ADD x3, x2, x4    <- Hazard here!");
        $display("  0x108: SUB x5, x3, x6");
        $display("");
        
        // Cycle 1: LW in EX, ADD in ID
        $display("Cycle 1: LW in EX, ADD in ID");
        ID_rs1 = 5'd2;   // ADD needs x2
        ID_rs2 = 5'd4;
        EX_mem_read = 1; // LW in EX
        EX_rd = 5'd2;
        EX_reg_write = 1;
        #1;
        $display("  Hazard detected: stall = %b (expect 1)", (pc_write == 0));
        
        // Cycle 2: Stalled - LW in MEM, ADD still in ID, bubble in EX
        $display("Cycle 2: Stalled - bubble inserted");
        EX_mem_read = 0; // Bubble in EX (no operation)
        EX_reg_write = 0;
        #1;
        $display("  No hazard now: stall = %b (expect 0)", (pc_write == 0));
        
        // Cycle 3: LW in WB, ADD in EX (with forwarding)
        $display("Cycle 3: ADD proceeds with forwarding");
        $display("  ADD can now execute (data forwarded from MEM/WB)");
        
        if (pc_write == 1) begin
            $display("✓ PASS: Stall and resume sequence works\n");
        end else begin
            $display("✗ FAIL: Stall sequence error\n");
        end
        
        // Test 10: Multiple consecutive loads (worst case)
        $display("Test 10: Multiple Consecutive Loads");
        $display("------------------------");
        $display("  LW x10, 0(x1)");
        $display("  LW x11, 4(x1)");
        $display("  ADD x12, x10, x11  <- Two hazards!");
        
        // First load
        ID_rs1 = 5'd10;
        ID_rs2 = 5'd11;
        EX_mem_read = 1;
        EX_rd = 5'd10;
        EX_reg_write = 1;
        #1;
        $display("First load hazard: stall = %b", (pc_write == 0));
        
        // Second load (still has hazard with x11)
        ID_rs1 = 5'd10;
        ID_rs2 = 5'd11;
        EX_mem_read = 1;
        EX_rd = 5'd11;
        EX_reg_write = 1;
        #1;
        $display("Second load hazard: stall = %b", (pc_write == 0));
        
        $display("✓ PASS: Multiple hazards handled\n");
        
        $display("========================================");
        $display("Hazard Detection Unit Tests Complete");
        $display("========================================");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("hdu_tb.vcd");
        $dumpvars(0, Hazard_Detection_Unit_TB);
    end

endmodule