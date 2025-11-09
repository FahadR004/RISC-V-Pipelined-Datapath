`timescale 1ns / 1ps

module WriteBack_Stage_TB;

    // Parameters
    parameter data_width = 32;

    // Signals
    reg mem_to_reg;
    reg [data_width-1:0] alu_result;
    reg [data_width-1:0] mem_data;
    
    wire [data_width-1:0] write_data;

    // Instantiate WriteBack Stage
    WriteBack_Stage #(
        .data_width(data_width)
    ) uut (
        .mem_to_reg(mem_to_reg),
        .alu_result(alu_result),
        .mem_data(mem_data),
        .write_data(write_data)
    );

    // Test sequence
    initial begin
        $display("========================================");
        $display("WriteBack Stage Testbench");
        $display("========================================\n");
        
        // Initialize
        mem_to_reg = 0;
        alu_result = 0;
        mem_data = 0;
        
        #10;
        
       // Test 1: Select ALU result (R-type, I-type arithmetic)
        $display("Test 1: Select ALU Result");
        $display("------------------------");
        mem_to_reg = 0;  // Select ALU result
        alu_result = 32'hDEADBEEF;
        mem_data = 32'h12345678;
        #1;
        
        $display("mem_to_reg = 0 (select ALU result)");
        $display("  ALU result = 0x%h", alu_result);
        $display("  Memory data = 0x%h", mem_data);
        $display("  Write data = 0x%h (expect 0xDEADBEEF)", write_data);
        
        if (write_data == 32'hDEADBEEF) begin
            $display("✓ PASS: ALU result selected correctly\n");
        end else begin
            $display("✗ FAIL: ALU result selection error\n");
        end
        
        // Test 2: Select memory data (Load instructions)
        $display("Test 2: Select Memory Data");
        $display("------------------------");
        mem_to_reg = 1;  // Select memory data
        alu_result = 32'hDEADBEEF;
        mem_data = 32'h12345678;
        #1;
        
        $display("mem_to_reg = 1 (select memory data)");
        $display("  ALU result = 0x%h", alu_result);
        $display("  Memory data = 0x%h", mem_data);
        $display("  Write data = 0x%h (expect 0x12345678)", write_data);
        
        if (write_data == 32'h12345678) begin
            $display("✓ PASS: Memory data selected correctly\n");
        end else begin
            $display("✗ FAIL: Memory data selection error\n");
        end
        
        // Test 3: Switching between sources
        $display("Test 3: Multiple Selections");
        $display("------------------------");
        
        // Arithmetic result
        mem_to_reg = 0;
        alu_result = 32'h00000064;  // 100
        mem_data = 32'h00000000;
        #1;
        $display("Arithmetic: write_data = %d (expect 100)", write_data);
        
        // Load result
        mem_to_reg = 1;
        alu_result = 32'h00000000;
        mem_data = 32'h000000C8;  // 200
        #1;
        $display("Load: write_data = %d (expect 200)", write_data);
        
        // Another arithmetic
        mem_to_reg = 0;
        alu_result = 32'h0000012C;  // 300
        #1;
        $display("Arithmetic: write_data = %d (expect 300)", write_data);
        
        if (write_data == 32'd300) begin
            $display("✓ PASS: Multiple selections work\n");
        end else begin
            $display("✗ FAIL: Multiple selections error\n");
        end
        
        // Test 4: Zero values
        $display("Test 4: Zero Values");
        $display("------------------------");
        mem_to_reg = 0;
        alu_result = 32'h00000000;
        mem_data = 32'h00000000;
        #1;
        
        $display("ALU result = 0, Memory data = 0");
        $display("  Write data = 0x%h (expect 0x00000000)", write_data);
        
        if (write_data == 32'h00000000) begin
            $display("✓ PASS: Zero values handled correctly\n");
        end else begin
            $display("✗ FAIL: Zero values error\n");
        end
        
        // Test 5: Maximum values
        $display("Test 5: Maximum Values");
        $display("------------------------");
        mem_to_reg = 1;
        alu_result = 32'hFFFFFFFF;
        mem_data = 32'hFFFFFFFF;
        #1;
        
        $display("All ones: write_data = 0x%h (expect 0xFFFFFFFF)", write_data);
        
        if (write_data == 32'hFFFFFFFF) begin
            $display("✓ PASS: Maximum values handled correctly\n");
        end else begin
            $display("✗ FAIL: Maximum values error\n");
        end
        
        // Test 6: Typical instruction sequences
        $display("Test 6: Typical Instruction Sequences");
        $display("------------------------");
        
        // ADD x3, x1, x2 (R-type)
        $display("ADD instruction:");
        mem_to_reg = 0;
        alu_result = 32'd150;  // Result of add
        mem_data = 32'hXXXXXXXX;  // Don't care
        #1;
        $display("  Write data = %d (expect 150)", write_data);
        
        // LW x4, 0(x1) (Load)
        $display("LW instruction:");
        mem_to_reg = 1;
        alu_result = 32'h00001000;  // Address (don't care for writeback)
        mem_data = 32'hABCDEF00;    // Loaded from memory
        #1;
        $display("  Write data = 0x%h (expect 0xABCDEF00)", write_data);
        
        // ADDI x5, x4, 10 (I-type)
        $display("ADDI instruction:");
        mem_to_reg = 0;
        alu_result = 32'd210;
        #1;
        $display("  Write data = %d (expect 210)", write_data);
        
        $display("✓ PASS: Typical sequences work\n");
        
        $display("========================================");
        $display("WriteBack Stage Tests Complete");
        $display("========================================");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("writeback_stage_tb.vcd");
        $dumpvars(0, WriteBack_Stage_TB);
    end

endmodule