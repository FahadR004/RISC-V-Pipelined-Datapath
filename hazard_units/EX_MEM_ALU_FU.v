module EX_Hazard_Detector #(
    parameter reg_addr_width = 5
) (
    // From EX/MEM Register (instruction in MEM stage)
    input [reg_addr_width-1:0] MEM_rd,
    input MEM_reg_write,
    
    // From ID/EX Register (instruction in EX stage)
    input [reg_addr_width-1:0] EX_rs1,
    input [reg_addr_width-1:0] EX_rs2,
    
    // Outputs: hazard detected signals
    output wire ex_hazard_rs1,    // MEM stage result needed for rs1
    output wire ex_hazard_rs2     // MEM stage result needed for rs2
);

    // EX Hazard for rs1
    assign ex_hazard_rs1 = MEM_reg_write && 
                          (MEM_rd != {reg_addr_width{1'b0}}) && 
                          (MEM_rd == EX_rs1);
    
    // EX Hazard for rs2
    assign ex_hazard_rs2 = MEM_reg_write && 
                          (MEM_rd != {reg_addr_width{1'b0}}) && 
                          (MEM_rd == EX_rs2);

endmodule   