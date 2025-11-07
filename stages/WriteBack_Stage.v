module WriteBack_Stage #(
    parameter data_width = 32
) (
    // Control signal from MEM/WB
    input mem_to_reg,
    
    // Data from MEM/WB
    input [data_width-1:0] alu_result,
    input [data_width-1:0] mem_data,
    
    // Output
    output wire [data_width-1:0] write_data
);

    // Multiplexer: Select between ALU result and memory data
    assign write_data = mem_to_reg ? mem_data : alu_result;
    
    // mem_to_reg = 0: Write ALU result (R-type, I-type arithmetic)
    // mem_to_reg = 1: Write memory data (Load instructions)

endmodule