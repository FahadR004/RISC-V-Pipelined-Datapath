// Instruction Example for the Data Hazard that requires this Forwarding Unit

// For rs1,
// add x5, x6, x7
//        \
// sub x8, x5, x6

// For rs2,
// add x5, x6, x7
//        `----
//             |
// sub x8, x6, x5
// Dependency for x5

module EX_Hazard_Detector #(
    parameter reg_addr_width = 5
) (
    // From EX/MEM Register (instruction in MEM stage)
    input [reg_addr_width-1:0] MEM_rd,
    input MEM_reg_write,
    
    // From ID/EX Register (instruction in EX stage)
    input [reg_addr_width-1:0] EX_rs1,
    input [reg_addr_width-1:0] EX_rs2,
    
    // Output
    output wire ex_hazard_rs1,    // MEM stage result needed for rs1
    output wire ex_hazard_rs2     // MEM stage result needed for rs2
);
    // RegWrite means to be written in register
    // Secondly checking that destination register is not x0. (x0 is fixed as zero register)
    // EX Hazard for rs1
    assign ex_hazard_rs1 = MEM_reg_write && 
                          (MEM_rd != {reg_addr_width{1'b0}}) && 
                          (MEM_rd == EX_rs1);
    
    // EX Hazard for rs2
    assign ex_hazard_rs2 = MEM_reg_write && 
                          (MEM_rd != {reg_addr_width{1'b0}}) && 
                          (MEM_rd == EX_rs2);

endmodule   