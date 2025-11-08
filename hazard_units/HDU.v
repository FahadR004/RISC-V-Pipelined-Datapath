module Hazard_Detection_Unit #(
    parameter reg_addr_width = 5,
) ( 
    // From IF/ID
    input [reg_addr_width-1:0] ID_rs1,
    input [reg_addr_width-1:0] ID_rs2,
    // From ID/EX
    input EX_mem_read,
    input [reg_addr_width-1:0] EX_rd,
    input EX_branch_taken,
    input EX_reg_write,

    output reg pc_write,
    output reg if_id_write,
    output reg control_mux_select,
);


always @ (*) 
    begin
        pc_write = 1'b1;
        if_id_write = 1'b1;
        control_mux_select = 1'b0;
        // Load-Use Hazard
        if (EX_mem_read && EX_reg_write &&
            ((ID_rs1 === EX_rd) || (ID_rs2 == EX_rd))
            && (EX_rd != 5'b0)
        ) // If the hazard is detected, nothing is written in PC or IF_ID and bubble is inserted in ID/EX
            begin
                pc_write = 1'b0;
                if_id_write = 1'b0;
                control_mux_select = 1'b1;  // For Bubble Insertion
            end
    end
    
endmodule