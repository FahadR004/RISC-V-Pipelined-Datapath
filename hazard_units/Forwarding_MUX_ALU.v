module Forwarding_MUX_ALU #(
    parameter data_width = 32;
) (
  input forward_value, // A or B. For selection
  // Between the following inputs
  input [data_width-1:0] original_data,
  input [data_width-1:0] mem_data,
  input [data_width-1:0] wb_data,
  // Output
  output reg [data_width-1:0] alu_operand 
);


always @ (*)
    begin
        case (forward_value):
            2'b00: alu_operand = original_data;
            2'b01: alu_operand = mem_data;
            2'b10: alu_operand = wb_data;
            default: alu_operand = original_data;
        endcase
        
    end
    
endmodule