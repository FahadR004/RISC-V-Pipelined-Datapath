module MEM_WB_ALU_FU #(
    parameter reg_addr_width = 5
) (
    // From MEM/WB Register (instruction in WB stage)
    input [reg_addr_width-1:0] WB_rd,
    input WB_reg_write,
    
    // From ID/EX Register (instruction in EX stage)
    input [reg_addr_width-1:0] EX_rs1,
    input [reg_addr_width-1:0] EX_rs2,
    
    // Outputs: hazard detected signals
    output wire mem_hazard_rs1,   // WB stage result needed for rs1
    output wire mem_hazard_rs2    // WB stage result needed for rs2
);

    // MEM Hazard for rs1
    assign mem_hazard_rs1 = WB_reg_write && 
                           (WB_rd != {reg_addr_width{1'b0}}) && 
                           (WB_rd == EX_rs1);
    
    // MEM Hazard for rs2
    assign mem_hazard_rs2 = WB_reg_write && 
                           (WB_rd != {reg_addr_width{1'b0}}) && 
                           (WB_rd == EX_rs2);

endmodule