module Immediate_Generator #(
    parameter data_width = 32
) (
    input [data_width-1:0] instruction,
    
    output reg [data_width-1:0] immediate
);

    wire [6:0] opcode;
    assign opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011, // I-type (ADDI, SLTI, etc.)
            7'b0000011, // I-type (Load instructions)
            // 7'b1100111: begin // I-type (JALR)
            //     immediate = {{20{instruction[31]}}, instruction[31:20]};
            // end
            7'b0100011: begin // S-type (Store instructions)
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin // B-type (Branch instructions)
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end            
            // 7'b0110111, // U-type (LUI)
            // 7'b0010111: begin // U-type (AUIPC)
            //     immediate = {instruction[31:12], 12'b0};
            // end
            
            // 7'b1101111: begin // J-type (JAL)
            //     immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            // end
            default: begin
                immediate = {data_width{1'b0}};
            end
        endcase
    end

endmodule