// Main File

module RISC_V_Pipeline (
    input clk,
    input reset
);

    Fetch_Stage fetch();
    
    Decode_Stage decode();
    
    Execute_Stage execute();
    
    Memory_Stage memory();
    
    WriteBack_Stage writeback();

endmodule