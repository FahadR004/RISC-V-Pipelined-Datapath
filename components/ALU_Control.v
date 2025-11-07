module ALU_Control (
    input [1:0] alu_op,           // From control unit
    input [2:0] funct3,           
    input [6:0] funct7,           
     
    output reg [3:0] alu_control  // To ALU (4-bit control signal)
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin
        case (alu_op)
            2'b00: begin  // Load/Store (add for address calculation)
                alu_control = ALU_ADD;
            end
            
            2'b01: begin  // Branch (subtract for comparison)
                alu_control = ALU_SUB;
            end
            
            2'b10: begin  // R-type or I-type arithmetic
                case (funct3)
                    3'b000: begin  // ADD/SUB
                        if (funct7 == 7'b0100000)
                            alu_control = ALU_SUB;
                        else
                            alu_control = ALU_ADD;
                    end
                    3'b001: alu_control = ALU_SLL;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;
                    3'b100: alu_control = ALU_XOR;
                    3'b101: begin  // SRL/SRA
                        if (funct7 == 7'b0100000)
                            alu_control = ALU_SRA;
                        else
                            alu_control = ALU_SRL;
                    end
                    3'b111: alu_control = ALU_AND;
                    3'b110: alu_control = ALU_OR;
                    default: alu_control = ALU_ADD;
                endcase
            end
            
            default: alu_control = ALU_ADD;
        endcase
    end

endmodule