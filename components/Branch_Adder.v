module Branch_Adder #(
    parameter address_width = 12
) (
    input [address_width-1:0] pc_current,      // Current PC from ID/EX
    input [address_width-1:0] immediate,       // Branch offset (sign-extended)
    input branch_signal,                       // Branch control signal
    input zero_flag,                           // From ALU
    input [2:0] funct3,                        // Branch type
    
    output reg branch_taken,                   // 1 = take branch, 0 = don't
    output wire [address_width-1:0] branch_target  // Target address
);

    // Calculate branch target address
    assign branch_target = pc_current + immediate;

    // Determine if branch should be taken
    always @(*) begin
        branch_taken = 1'b0;  // Default: don't take branch
        
        if (branch_signal) begin  // Only evaluate if it's a branch instruction
            case (funct3)
                3'b000: branch_taken = zero_flag;       // BEQ (equal)
                3'b001: branch_taken = ~zero_flag;      // BNE (not equal)
                // Add more branch types if needed (BLT, BGE, etc.)
                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule