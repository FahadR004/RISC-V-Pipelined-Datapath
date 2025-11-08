module PC_Register #(
    parameter address_width = 32
) (
    input clk,
    input reset,
    input pc_write,                              // From Hazard Unit
    input [address_width-1:0] next_pc,        // Next PC value (Byte Address)
    
    output reg [address_width-1:0] pc_current // Current PC value (Byte Address)
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= {address_width{1'b0}};  // Reset to 0
        else if (pc_write)
            pc_current <= next_pc;         // Update to next PC     
        else
            pc_current <= pc_current;     // Hold current value            
    end

endmodule