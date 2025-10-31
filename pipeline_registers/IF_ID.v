module IF_ID_Register #(
    parameter data_width = 32,
    parameter address_width = 12
) (
    input clk,
    input reset,
    input stall,   // From Hazard Unit
    input flush,   // From Hazard Unit
    
    // Inputs from Fetch Stage
    input [address_width-1:0] IF_pc_plus_4,
    input [address_width-1:0] IF_pc_current,
    input [data_width-1:0] IF_instruction,
    
    // Outputs to Decode Stage
    output reg [address_width-1:0] ID_pc_plus_4,
    output reg [address_width-1:0] ID_pc_current,
    output reg [data_width-1:0] ID_instruction
);

    always @(posedge clk or posedge reset) 
        begin
            if (reset || flush) begin
                // Reset or flush: Insert bubble (NOP)
                ID_pc_plus_4 <= {address_width{1'b0}};
                ID_pc_current <= {address_width{1'b0}};
                ID_instruction <= 32'h00000013;  // NOP (ADDI x0, x0, 0)
            end
            else if (stall) begin
                // Stall: Hold current values
                ID_pc_plus_4 <= ID_pc_plus_4;
                ID_pc_current <= ID_pc_current;
                ID_instruction <= ID_instruction;
            end
            else begin
                // Normal operation
                ID_pc_plus_4 <= IF_pc_plus_4;
                ID_pc_current <= IF_pc_current;
                ID_instruction <= IF_instruction;
            end
        end

endmodule