module Hazard_Detection_Unit #(
    parameter reg_addr_width = 5,
) ( 
    // From IF/ID
    input ID_rs1,
    input ID_rs2,
    // From ID/EX
    input EX_mem_read,
    input EX_rd,
    input EX_branch_taken,

    output reg pc_write,
    output reg if_id_write,
    output reg control_mux_select,
    output reg if_id_flush
);


always @ (*) 
    begin
        pc_write = 1'b1;
        if_id_write = 1'b1;
        control_mux_select = 1'b0;
        if_id_flush = 1'b0;
        // Load-Use Hazard
        if (ID_mem_read && 
            ((ID_rs1 === EX_rd) || (ID_rs2 == EX_rd))
            && (EX_rd != 5'b0)
        ) // If the hazard is detected, nothing is written in PC or IF_ID and bubble is inserted in ID/EX
            begin
                pc_write = 1'b0;
                if_id_write = 1'b0;
                control_mux_select = 1'b1;  // For Bubble Insertion
            end
        
        if (EX_branch_taken)
            begin
                if_id_flush = 1'b1;
            end
    end
    
endmodule