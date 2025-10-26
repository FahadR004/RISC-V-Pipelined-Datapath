module Control_Unit(
    input [6:0] opcode,
    
    // Execution Stage Signals
    output reg alu_src,
    output reg [1:0] alu_op,
    
    // Memory Stage Signals
    output reg branch,
    output reg mem_read,
    output reg mem_write,

    // Write Back Stage Signals
    output reg mem_to_reg,
    output reg reg_write
);

always @ (*) begin
    case (opcode)
        7'b0110011: begin // R-Format
            reg_write = 1'b1;
            alu_src = 1'b0;
            alu_op = 2'b10;
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            mem_to_reg = 1'b0;
        end
        7'b0000011: begin // Load Word
            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_op = 2'b00;
            branch = 1'b0;
            mem_read = 1'b1;
            mem_write = 1'b0;
            mem_to_reg = 1'b1;
        end
        7'b0100011: begin // Store Word
            reg_write = 1'b0;
            alu_src = 1'b1;
            alu_op = 2'b00;
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b1;
            mem_to_reg = 1'bx; 
        end
        7'b1100011: begin // Branch 
            reg_write = 1'b0;
            alu_src = 1'b0;
            alu_op = 2'b01;
            branch = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
            mem_to_reg = 1'bx; 
        end
        default: begin
            reg_write = 1'b0;
            alu_src = 1'b0;
            alu_op = 2'b00;
            branch = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
            mem_to_reg = 1'b0;
        end
    endcase
end

endmodule