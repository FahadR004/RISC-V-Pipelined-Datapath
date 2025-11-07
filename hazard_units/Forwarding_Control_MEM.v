module Forwarding_Control_MEM (
    // From MEM_WB to MEM    
    input mem_hazard,          
    // Forwarding Unit Output
    output reg forward_C,  
    // 0 = Contents of rs2 from MEM_WB go forward, 
    // 1 = Data from WB  
);

    // Forward C 
    always @(*) 
        begin
            if (mem_hazard)
                forward_C = 1'b1;        // Forward from MEM/WB
            else
                forward_C = 1'b0;        // No Forwarding
        end

endmodule