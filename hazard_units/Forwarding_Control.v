module Forwarding_Control (
    // Hazard detection inputs
    input ex_hazard_rs1,      // From EX Hazard Detector
    input ex_hazard_rs2,      // From EX Hazard Detector
    input mem_hazard_rs1,     // From MEM Hazard Detector
    input mem_hazard_rs2,     // From MEM Hazard Detector
    
    // Forwarding control outputs
    output reg [1:0] forward_A,   // 00=no forward, 01=from MEM, 10=from WB
    output reg [1:0] forward_B    // 00=no forward, 01=from MEM, 10=from WB
);

    // Forward A (rs1) with priority: EX hazard > MEM hazard > no forward
    always @(*) begin
        if (ex_hazard_rs1)
            forward_A = 2'b01;        // Forward from EX/MEM (highest priority)
        else if (mem_hazard_rs1)
            forward_A = 2'b10;        // Forward from MEM/WB (lower priority)
        else
            forward_A = 2'b00;        // No forwarding
    end
    
    // Forward B (rs2) with priority: EX hazard > MEM hazard > no forward
    always @(*) begin
        if (ex_hazard_rs2)
            forward_B = 2'b01;        // Forward from EX/MEM (highest priority)
        else if (mem_hazard_rs2)
            forward_B = 2'b10;        // Forward from MEM/WB (lower priority)
        else
            forward_B = 2'b00;        // No forwarding
    end

endmodule