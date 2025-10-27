module Fetch #(
    parameter data_width = 32,
    parameter address_width = 12
) (
    input clk,
    input reset,
    input wire stall,           // From Hazard Unit
    input wire flush,           // From Hazard Unit (for branches)
    input wire [address_width-1:0] branch_target,  // From MEM stage
    input wire pc_src,          // From MEM stage (branch taken signal)

    output wire [address_bits-1:0] pc_plus_4,
    output wire [data_width-1:0] instruction,
    output reg [data_width-1:0] pc_current 
);

wire [address_width-1:0] next_pc;

always @ (posedge clk or posedge reset) 
    begin
        if (reset)
            pc_current <= 12'h_000; // Restart execution from 0th address
        else if (stall)
            pc_current <= pc_current; // Hold the same instruction
        else
            pc_current <= next_pc; 
    end

// If 1, we jump to branch target else, we perform sequential execution.
assign next_pc = (pc_src) ? branch_target : (pc_current + 4);
assign pc_plus_4 = pc_current + 4;


// I have defined word memory but it will expect a byte address. Conversion will occur internally
Instruction_Memory inst_mem (
    .address(pc_current), // This is the current value being passed. Updated in next clock cycle
    .instruction(instruction)
)

    
endmodule