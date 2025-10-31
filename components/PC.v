module PC_Register #(
    parameter address_width = 12
) (
    input clk,
    input reset,
    input flush,
    input stall,                              // From Hazard Unit
    input [address_width-1:0] next_pc,        // Next PC value
    
    output reg [address_width-1:0] pc_current // Current PC value
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= {address_width{1'b0}};  // Reset to 0
        else if (flush)                    
            pc_current <= {address_width{1'b0}}; 
        else if (stall)
            pc_current <= pc_current;              // Hold current value
        else
            pc_current <= next_pc;                 // Update to next PC
    end

endmodule