module ALU #(
    parameter data_width = 32
) (
    input [2:0] funct3, 
    input [6:0] funct7,
    input [1:0] alu_op,
    input [data_width-1:0] operand_A, 
    input [data_width-1:0] operand_B,
    output reg [data_width-1:0] result
    output zero_flag
);

always (*) 
    begin
         case (alu_op)
        2'b10: begin  // R-type 
            case (funct3)
                3'b000: begin  // add/sub
                    if (funct7 == 7'b0000000)
                        result = operand_A + operand_B;
                    else if (funct7 == 7'b0100000) 
                        result = operand_A - operand_B;
                    else
                        result = 32'b0;  // Default
                end
                3'b111: result = operand_A & operand_B;  // AND
                3'b110: result = operand_A | operand_B;  // OR
                3'b100: result = operand_A ^ operand_B;  // XOR
                3'b001: result = operand_A << operand_B[4:0];  // SLL
                3'b101: begin  // SRL/SRA
                    if (funct7 == 7'b0000000)
                        result = operand_A >> operand_B[4:0];  // SRL
                    else
                        result = $signed(operand_A) >>> operand_B[4:0];  // SRA
                end
                default: result = 32'b0;
            endcase
        end
        
        2'b00: begin  // lw, sw
            result = operand_A + operand_B;
        end
        
        2'b01: begin  // Branch instructions 
            result = operand_A - operand_B;
        end
        
        default: result = 32'b0;
    endcase
    end    
endmodule