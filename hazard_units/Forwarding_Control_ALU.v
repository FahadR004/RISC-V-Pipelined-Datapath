module Forwarding_Control_ALU (
    // From EX_MEM to ALU 
    input ex_hazard_rs1,      
    input ex_hazard_rs2,   
    // From MEM_WB to ALU    
    input mem_hazard_rs1,     
    input mem_hazard_rs2,     
    
    // Forwarding Unit Outputs
    output reg [1:0] forward_A,  
    // 00 = Contents of rs1 read from register file go forward, 
    // 01 = Data from MEM,
    // 10 = Data from WB 
    output reg [1:0] forward_B
    // 00 = Contents of rs1 read from register file go forward, 
    // 01 = Data from MEM,
    // 10 = Data from WB 
);
    // We prioritize data from MEM over WB because of a case like this:
    // add x5, x6, x7
    // sub x5, x5, x9
    // and x9, x5, x10
    // We don't want the value of x5 to be written from WB stage as it being updated in MEM stage again.
    // Thus, prioritizing the data from MEM stage. 

    // Forward A (rs1) with priority: EX hazard > MEM hazard > No forward
    always @(*) 
        begin
            if (ex_hazard_rs1)
                forward_A = 2'b01;        // Forward from EX/MEM (highest priority)
            else if (mem_hazard_rs1)
                forward_A = 2'b10;        // Forward from MEM/WB (lower priority)
            else
                forward_A = 2'b00;        // No Forwarding
        end
    
    // Forward B (rs2) with priority: EX hazard > MEM hazard > No forward
    always @(*) 
        begin
            if (ex_hazard_rs2)
                forward_B = 2'b01;        // Forward from EX/MEM (highest priority)
            else if (mem_hazard_rs2)
                forward_B = 2'b10;        // Forward from MEM/WB (lower priority)
            else
                forward_B = 2'b00;        // No Forwarding
        end

endmodule