`timescale 1ns / 1ps

module Fetch_Stage_TB;

    // Parameters
    parameter data_width = 32;
    parameter address_width = 32;
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk;
    reg reset;
    reg pc_write;
    reg [address_width-1:0] branch_target;
    reg pc_src;
    
    wire [address_width-1:0] pc_plus_4;
    wire [address_width-1:0] pc_current;
    wire [data_width-1:0] instruction;

    // Instantiate Fetch Stage
    Fetch_Stage #(
        .data_width(data_width),
        .address_width(address_width)
    ) uut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .branch_target(branch_target),
        .pc_src(pc_src),
        .pc_plus_4(pc_plus_4),
        .pc_current(pc_current),
        .instruction(instruction)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("========================================");
        $display("Fetch Stage Testbench");
        $display("========================================\n");
        
        // Initialize instruction memory with test program
        uut.inst_mem.memory_block[0] = 32'h00450293;  // ADDI x5, x10, 4
        uut.inst_mem.memory_block[1] = 32'h00500313;  // ADDI x6, x0, 5
        uut.inst_mem.memory_block[2] = 32'h006283B3;  // ADD x7, x5, x6
        uut.inst_mem.memory_block[3] = 32'h40628433;  // SUB x8, x5, x6
        uut.inst_mem.memory_block[4] = 32'hFE208EE3;  // BEQ x1, x2, -4
        
        // Initialize signals
        reset = 1;
        pc_write = 1;
        pc_src = 0;
        branch_target = 32'h00000000;
        
        // Test 1: Reset behavior
        $display("Test 1: Reset Behavior");
        $display("------------------------");
        #(CLK_PERIOD);
        reset = 0;
        #(CLK_PERIOD);
        
        if (pc_current == 32'h00000000 && pc_plus_4 == 32'h00000004) begin
            $display("✓ PASS: PC initialized to 0x00000000");
            $display("  PC = 0x%h, PC+4 = 0x%h", pc_current, pc_plus_4);
        end else begin
            $display("✗ FAIL: PC not initialized correctly");
            $display("  Expected PC = 0x00000000, Got PC = 0x%h", pc_current);
        end
        $display("");
        
        // Test 2: Sequential fetch (normal operation)
        $display("Test 2: Sequential Fetch");
        $display("------------------------");
        pc_write = 1;
        pc_src = 0;
        
        repeat(4) begin
            #(CLK_PERIOD);
            $display("Cycle: PC = 0x%h, Instruction = 0x%h, PC+4 = 0x%h", 
                     pc_current, instruction, pc_plus_4);
        end
        
        if (pc_current == 32'h00000010) begin
            $display("✓ PASS: Sequential fetching works (PC increments by 4)");
        end else begin
            $display("✗ FAIL: Sequential fetching broken");
            $display("  Expected PC = 0x00000010, Got PC = 0x%h", pc_current);
        end
        $display("");
        
        // Test 3: PC stall (pc_write = 0)
        $display("Test 3: PC Stall (pc_write = 0)");
        $display("------------------------");
        pc_write = 0;
        #(CLK_PERIOD);
        
        if (pc_current == 32'h00000010) begin
            $display("✓ PASS: PC correctly held during stall");
            $display("  PC = 0x%h (unchanged)", pc_current);
        end else begin
            $display("✗ FAIL: PC changed during stall");
            $display("  Expected PC = 0x00000010, Got PC = 0x%h", pc_current);
        end
        $display("");
        
        // Test 4: Resume after stall
        $display("Test 4: Resume After Stall");
        $display("------------------------");
        pc_write = 1;
        #(CLK_PERIOD);
        
        if (pc_current == 32'h00000014) begin
            $display("✓ PASS: PC resumed after stall");
            $display("  PC = 0x%h", pc_current);
        end else begin
            $display("✗ FAIL: PC didn't resume correctly");
        end
        $display("");
        
        // Test 5: Branch taken (pc_src = 1)
        $display("Test 5: Branch Taken");
        $display("------------------------");
        pc_src = 1;
        branch_target = 32'h00000100;
        #(CLK_PERIOD);
        
        if (pc_current == 32'h00000100) begin
            $display("✓ PASS: Branch target correctly loaded");
            $display("  PC = 0x%h (branch target)", pc_current);
        end else begin
            $display("✗ FAIL: Branch target not loaded");
            $display("  Expected PC = 0x00000100, Got PC = 0x%h", pc_current);
        end
        $display("");
        
        // Test 6: Return to sequential after branch
        $display("Test 6: Sequential After Branch");
        $display("------------------------");
        pc_src = 0;
        #(CLK_PERIOD);
        
        if (pc_current == 32'h00000104) begin
            $display("✓ PASS: Sequential execution resumed after branch");
            $display("  PC = 0x%h", pc_current);
        end else begin
            $display("✗ FAIL: Sequential execution not resumed");
        end
        $display("");
        
        // Test 7: Instruction memory access
        $display("Test 7: Instruction Memory Access");
        $display("------------------------");
        reset = 1;
        #(CLK_PERIOD);
        reset = 0;
        pc_write = 1;
        pc_src = 0;
        
        #(CLK_PERIOD);
        if (instruction == 32'h00450293) begin
            $display("✓ PASS: Instruction memory read correctly");
            $display("  Address 0x00000000: Instruction = 0x%h", instruction);
        end else begin
            $display("✗ FAIL: Instruction memory read error");
        end
        
        #(CLK_PERIOD);
        if (instruction == 32'h00500313) begin
            $display("✓ PASS: Next instruction fetched correctly");
            $display("  Address 0x00000004: Instruction = 0x%h", instruction);
        end else begin
            $display("✗ FAIL: Next instruction fetch error");
        end
        $display("");
        
        $display("========================================");
        $display("Fetch Stage Tests Complete");
        $display("========================================");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("fetch_stage_tb.vcd");
        $dumpvars(0, Fetch_Stage_TB);
    end

endmodule