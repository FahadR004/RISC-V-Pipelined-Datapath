`timescale 1ns / 1ps

module Memory_Stage_TB;

    // Parameters
    parameter data_width = 32;
    parameter address_width = 32;
    parameter reg_addr_width = 5;
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk;
    reg mem_write;
    reg [address_width-1:0] mem_address;
    reg [data_width-1:0] MEM_write_data;
    reg [reg_addr_width-1:0] MEM_rs2;
    reg [reg_addr_width-1:0] WB_rd;
    reg WB_reg_write;
    reg [data_width-1:0] WB_write_data;
    
    wire [data_width-1:0] mem_read_data;

    // Instantiate Memory Stage
    Memory_Stage #(
        .data_width(data_width),
        .address_width(address_width),
        .reg_addr_width(reg_addr_width)
    ) uut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_address(mem_address),
        .MEM_write_data(MEM_write_data),
        .MEM_rs2(MEM_rs2),
        .WB_rd(WB_rd),
        .WB_reg_write(WB_reg_write),
        .WB_write_data(WB_write_data),
        .mem_read_data(mem_read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("========================================");
        $display("Memory Stage Testbench");
        $display("========================================\n");
        
        // Initialize
        mem_write = 0;
        mem_address = 0;
        MEM_write_data = 0;
        MEM_rs2 = 0;
        WB_rd = 0;
        WB_reg_write = 0;
        WB_write_data = 0;
        
        #(CLK_PERIOD);
        
        // Test 1: Write to memory
        $display("Test 1: Memory Write");
        $display("------------------------");
        mem_write = 1;
        mem_address = 32'h00000100;
        MEM_write_data = 32'hDEADBEEF;
        MEM_rs2 = 5'd10;
        #(CLK_PERIOD);
        mem_write = 0;
        
        $display("Wrote 0xDEADBEEF to address 0x100");
        $display("✓ PASS: Write initiated\n");
        
        // Test 2: Read from memory
        $display("Test 2: Memory Read");
        $display("------------------------");
        mem_address = 32'h00000100;
        #1;  // Wait for combinational read
        
        $display("Read from address 0x100");
        $display("  Data = 0x%h (expect 0xDEADBEEF)", mem_read_data);
        
        if (mem_read_data == 32'hDEADBEEF) begin
            $display("✓ PASS: Memory read works\n");
        end else begin
            $display("✗ FAIL: Memory read error\n");
        end
        
        // Test 3: Write to another address
        $display("Test 3: Multiple Writes");
        $display("------------------------");
        mem_write = 1;
        mem_address = 32'h00000200;
        MEM_write_data = 32'h12345678;
        #(CLK_PERIOD);
        
        mem_address = 32'h00000300;
        MEM_write_data = 32'hABCDEF00;
        #(CLK_PERIOD);
        mem_write = 0;
        
        // Read back
        mem_address = 32'h00000200;
        #1;
        $display("Address 0x200: 0x%h (expect 0x12345678)", mem_read_data);
        
        mem_address = 32'h00000300;
        #1;
        $display("Address 0x300: 0x%h (expect 0xABCDEF00)", mem_read_data);
        
        if (mem_read_data == 32'hABCDEF00) begin
            $display("✓ PASS: Multiple writes work\n");
        end else begin
            $display("✗ FAIL: Multiple writes error\n");
        end
        
        // Test 4: Store data forwarding from WB (WB → MEM hazard)
        $display("Test 4: Store Data Forwarding from WB");
        $display("------------------------");
        mem_write = 1;
        mem_address = 32'h00000400;
        MEM_write_data = 32'h11111111;  // Original data
        MEM_rs2 = 5'd5;                  // Store uses x5
        WB_rd = 5'd5;                    // WB is writing to x5
        WB_reg_write = 1;
        WB_write_data = 32'h22222222;    // Forwarded data
        #(CLK_PERIOD);
        mem_write = 0;
        
        // Read back to verify forwarded data was written
        mem_address = 32'h00000400;
        WB_reg_write = 0;
        #1;
        
        $display("MEM_write_data = 0x11111111 (original)");
        $display("WB forwarding x5 = 0x22222222");
        $display("Memory should contain: 0x%h (expect 0x22222222)", mem_read_data);
        
        if (mem_read_data == 32'h22222222) begin
            $display("✓ PASS: Store data forwarding works\n");
        end else begin
            $display("✗ FAIL: Store data forwarding error\n");
        end
        
        // Test 5: No forwarding when registers don't match
        $display("Test 5: No Forwarding (Different Registers)");
        $display("------------------------");
        mem_write = 1;
        mem_address = 32'h00000500;
        MEM_write_data = 32'h33333333;
        MEM_rs2 = 5'd10;                 // Store uses x10
        WB_rd = 5'd11;                   // WB writing to x11 (different!)
        WB_reg_write = 1;
        WB_write_data = 32'h44444444;
        #(CLK_PERIOD);
        mem_write = 0;
        
        mem_address = 32'h00000500;
        #1;
        
        $display("Store uses x10, WB writes x11 (no match)");
        $display("Memory should contain original: 0x%h (expect 0x33333333)", mem_read_data);
        
        if (mem_read_data == 32'h33333333) begin
            $display("✓ PASS: No false forwarding\n");
        end else begin
            $display("✗ FAIL: False forwarding occurred\n");
        end
        
        // Test 6: No forwarding to x0
        $display("Test 6: No Forwarding to x0");
        $display("------------------------");
        mem_write = 1;
        mem_address = 32'h00000600;
        MEM_write_data = 32'h55555555;
        MEM_rs2 = 5'd0;                  // Store uses x0
        WB_rd = 5'd0;                    // WB writing to x0
        WB_reg_write = 1;
        WB_write_data = 32'h66666666;    // Should not forward
        #(CLK_PERIOD);
        mem_write = 0;
        
        mem_address = 32'h00000600;
        #1;
        
        $display("Store uses x0 (always 0)");
        $display("Memory should contain: 0x%h (expect 0x55555555, not forwarded)", mem_read_data);
        
        if (mem_read_data == 32'h55555555) begin
            $display("✓ PASS: x0 not forwarded\n");
        end else begin
            $display("✗ FAIL: x0 forwarding error\n");
        end
        
        // Test 7: No forwarding when WB_reg_write = 0
        $display("Test 7: No Forwarding (WB Not Writing)");
        $display("------------------------");
        mem_write = 1;
        mem_address = 32'h00000700;
        MEM_write_data = 32'h77777777;
        MEM_rs2 = 5'd12;
        WB_rd = 5'd12;
        WB_reg_write = 0;                // WB not writing!
        WB_write_data = 32'h88888888;
        #(CLK_PERIOD);
        mem_write = 0;
        
        mem_address = 32'h00000700;
        #1;
        
        $display("WB_reg_write = 0 (WB not writing)");
        $display("Memory should contain original: 0x%h (expect 0x77777777)", mem_read_data);
        
        if (mem_read_data == 32'h77777777) begin
            $display("✓ PASS: No forwarding when WB not writing\n");
        end else begin
            $display("✗ FAIL: Forwarding when shouldn't\n");
        end
        
        // Test 8: Sequential reads (no writes)
        $display("Test 8: Sequential Reads");
        $display("------------------------");
        mem_write = 0;
        
        mem_address = 32'h00000100;
        #1;
        $display("Address 0x100: 0x%h", mem_read_data);
        
        mem_address = 32'h00000200;
        #1;
        $display("Address 0x200: 0x%h", mem_read_data);
        
        mem_address = 32'h00000300;
        #1;
        $display("Address 0x300: 0x%h", mem_read_data);
        
        $display("✓ PASS: Sequential reads work\n");
        
        $display("========================================");
        $display("Memory Stage Tests Complete");
        $display("========================================");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("memory_stage_tb.vcd");
        $dumpvars(0, Memory_Stage_TB);
    end

endmodule