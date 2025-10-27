// Main File

module RISC_V_Pipeline (
    input clk,
    input reset
);

    Fetch_Stage fetch(
        .clk(clk),
        
    );

    IF_ID IF_ID();
    
    Decode_Stage decode();

    ID_EX ID_EX();
    
    Execute_Stage execute();

    EX_MEM EX_MEM();
    
    Memory_Stage memory();

    MEM_WB MEM_WB();
    
    WriteBack_Stage writeback();

endmodule