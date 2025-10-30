module Decode #(
    parameter data_width = 32,
    parameter address_width = 12,
    parameter reg_addr_width = 5
) (
    input clk,
    input reset,
    input stall,                                    // From Hazard Unit
    input flush,                                    // From Hazard Unit
    
    // From Fetch Stage
    input [data_width-1:0] instruction,
    input [address_width-1:0] pc_plus_4,
    input [address_width-1:0] pc_current,
    
    // From Write Back Stage (for register file write)
    input wb_reg_write,
    input [reg_addr_width-1:0] wb_write_addr,
    input [data_width-1:0] wb_write_data,
    
    // Control Signals to Execute Stage
    output reg alu_src,
    output reg [1:0] alu_op,
    
    // Control Signals to Memory Stage
    output reg branch,
    output reg mem_read,
    output reg mem_write,
    
    // Control Signals to Write Back Stage
    output reg mem_to_reg,
    output reg reg_write,
    
    // Data and Register Addresses
    output reg [data_width-1:0] read_data_1,
    output reg [data_width-1:0] read_data_2,
    output reg [reg_addr_width-1:0] rs1,            // Source register 1
    output reg [reg_addr_width-1:0] rs2,            // Source register 2
    output reg [reg_addr_width-1:0] rd,             // Destination register
    
    // Immediate value
    output reg [data_width-1:0] immediate,
    
    // Pass-through signals
    output reg [address_width-1:0] pc_plus_4_out,
    output reg [address_width-1:0] pc_current_out,
    output reg [6:0] funct7,
    output reg [2:0] funct3
);

// Internal wires from Control Unit
wire cu_alu_src;
wire [1:0] cu_alu_op;
wire cu_branch;
wire cu_mem_read;
wire cu_mem_write;
wire cu_mem_to_reg;
wire cu_reg_write;

// Internal wires from Register File
wire [data_width-1:0] rf_read_data_1;
wire [data_width-1:0] rf_read_data_2;

// Instruction fields
wire [6:0] opcode;
wire [reg_addr_width-1:0] rs1_addr;
wire [reg_addr_width-1:0] rs2_addr;
wire [reg_addr_width-1:0] rd_addr;
wire [6:0] funct7_wire;
wire [2:0] funct3_wire;

// Decode instruction fields
assign opcode = instruction[6:0];
assign rd_addr = instruction[11:7];
assign funct3_wire = instruction[14:12];
assign rs1_addr = instruction[19:15];
assign rs2_addr = instruction[24:20];
assign funct7_wire = instruction[31:25];

// Immediate Generation Logic
reg [data_width-1:0] imm_gen;

always @(*) begin
    case (opcode)
        7'b0010011, // I-type (ADDI, etc.)
        7'b0000011: begin // I-type (Load)
            imm_gen = {{20{instruction[31]}}, instruction[31:20]};
        end
        7'b0100011: begin // S-type (Store)
            imm_gen = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        end
        7'b1100011: begin // B-type (Branch)
            imm_gen = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        end
        7'b0110111, // U-type (LUI)
        7'b0010111: begin // U-type (AUIPC)
            imm_gen = {instruction[31:12], 12'b0};
        end
        7'b1101111: begin // J-type (JAL)
            imm_gen = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        end
        default: begin
            imm_gen = 32'b0;
        end
    endcase
end

// Instantiate Control Unit
Control_Unit cu (
    .opcode(opcode),
    .alu_src(cu_alu_src),
    .alu_op(cu_alu_op),
    .branch(cu_branch),
    .mem_read(cu_mem_read),
    .mem_write(cu_mem_write),
    .mem_to_reg(cu_mem_to_reg),
    .reg_write(cu_reg_write)
);

// Instantiate Register File
Register_File #(
    .data_width(data_width),
    .address_bits(reg_addr_width),
    .total_regs(32)
) rf (
    .clk(clk),
    .write_enable(wb_reg_write),
    .read_addr_1(rs1_addr),
    .read_addr_2(rs2_addr),
    .write_addr(wb_write_addr),
    .write_reg_data(wb_write_data),
    .read_data_1(rf_read_data_1),
    .read_data_2(rf_read_data_2)
);

// Pipeline Register: Decode -> Execute
always @(posedge clk or posedge reset) begin
    if (reset || flush) begin
        // Reset all outputs to default (NOP)
        alu_src <= 1'b0;
        alu_op <= 2'b00;
        branch <= 1'b0;
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        mem_to_reg <= 1'b0;
        reg_write <= 1'b0;
        read_data_1 <= 32'b0;
        read_data_2 <= 32'b0;
        rs1 <= 5'b0;
        rs2 <= 5'b0;
        rd <= 5'b0;
        immediate <= 32'b0;
        pc_plus_4_out <= 12'b0;
        pc_current_out <= 12'b0;
        funct7 <= 7'b0;
        funct3 <= 3'b0;
    end
    else if (!stall) begin
        // Pass control signals
        alu_src <= cu_alu_src;
        alu_op <= cu_alu_op;
        branch <= cu_branch;
        mem_read <= cu_mem_read;
        mem_write <= cu_mem_write;
        mem_to_reg <= cu_mem_to_reg;
        reg_write <= cu_reg_write;
        
        // Pass register data
        read_data_1 <= rf_read_data_1;
        read_data_2 <= rf_read_data_2;
        
        // Pass register addresses
        rs1 <= rs1_addr;
        rs2 <= rs2_addr;
        rd <= rd_addr;
        
        // Pass immediate
        immediate <= imm_gen;
        
        // Pass PC values
        pc_plus_4_out <= pc_plus_4;
        pc_current_out <= pc_current;
        
        // Pass function fields for ALU control
        funct7 <= funct7_wire;
        funct3 <= funct3_wire;
    end
    // If stall, hold current values (do nothing)
end

endmodule