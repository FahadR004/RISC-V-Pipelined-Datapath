// Instruction Example for the Data Hazard that requires this Forwarding Unit

// add x7, x6, x8
// sw x7, 20(x5) 

// Dependency for x7. New value of x7 needs to be written in address, x5+20

module MEM_WB_MEM_FU #(
    parameter reg_addr_width = 5
) (
    // From MEM/WB Register (instruction in WB stage)
    input [reg_addr_width-1:0] WB_rd,
    input WB_reg_write,
    
    // From EX/MEM Register (instruction in MEM stage)
    input mem_write,
    input [reg_addr_width-1:0] MEM_rs2,
    
    // Output
    output wire mem_hazard   // WB stage result needed for rs1
);
    // RegWrite means to be written in register
    // Secondly checking that destination register is not x0. (x0 is fixed as zero register)
    assign mem_hazard = WB_reg_write && 
                           (WB_rd != {reg_addr_width{1'b0}}) && 
                           (WB_rd == MEM_rs2);

endmodule