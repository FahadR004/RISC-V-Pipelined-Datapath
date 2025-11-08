module Branch_Unit #(
    parameter address_width = 32
) (
    // Input
    input [address_width-1:0] pc_current,      // Current PC from ID/EX
    input [address_width-1:0] immediate,       // Branch offset (sign-extended)
    input branch_signal,                       // Branch control signal
    input zero_flag,                           // From ALU
    input [2:0] funct3,                        // Branch type
    
    // Operands for comparison
    input [data_width-1:0] operand_A,           // rs1 value
    input [data_width-1:0] operand_B,           // rs2 value
    
    // Output
    output reg branch_taken,                   // 1 = take branch, 0 = don't
    output wire [address_width-1:0] branch_target  // Target address
);

    // Calculate branch target address (byte arithmetic)
    // PC + immediate (both are byte addresses)
    assign branch_target = pc_current + immediate;

    wire signed_less_than;
    wire unsigned_less_than;
    wire equal;
    
    assign equal = (operand_A == operand_B);
    assign signed_less_than = ($signed(operand_A) < $signed(operand_B));
    assign unsigned_less_than = (operand_A < operand_B);
    
    // Note: RISC-V branch offsets are already in bytes and always even (bit[0] = 0)

    always @(*) begin
        branch_taken = 1'b0;  // Default: don't take branch
        
        if (branch_signal) begin  // Only evaluate if it's a branch instruction
            case (funct3)
               3'b000: branch_taken = equal;              // BEQ (equal)
                3'b001: branch_taken = ~equal;             // BNE (not equal)
                3'b100: branch_taken = signed_less_than;   // BLT (less than, signed)
                3'b101: branch_taken = ~signed_less_than;  // BGE (greater/equal, signed)
                3'b110: branch_taken = unsigned_less_than; // BLTU (less than, unsigned)
                3'b111: branch_taken = ~unsigned_less_than;// BGEU (greater/equal, unsigned)
                default: branch_taken = 1'b0;
            endcase
        end
    end

endmodule