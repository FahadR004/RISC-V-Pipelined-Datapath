module ALU #(
    parameter data_width = 32
) (
    input [3:0] alu_control,              // From ALU Control
    input [data_width-1:0] operand_A, 
    input [data_width-1:0] operand_B,
    
    output reg [data_width-1:0] result,
    output wire zero_flag
);

    // ALU Control codes
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;

    always @(*) begin
        case (alu_control)
            ALU_ADD: result = operand_A + operand_B;
            ALU_SUB: result = operand_A - operand_B;
            ALU_AND: result = operand_A & operand_B;
            ALU_OR:  result = operand_A | operand_B;
            ALU_XOR: result = operand_A ^ operand_B;
            ALU_SLL: result = operand_A << operand_B[4:0];
            ALU_SRL: result = operand_A >> operand_B[4:0];
            ALU_SRA: result = $signed(operand_A) >>> operand_B[4:0];
            default: result = {data_width{1'b0}};
        endcase
    end

    assign zero_flag = (result == {data_width{1'b0}});

endmodule