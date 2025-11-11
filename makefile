# Makefile for RISC-V Pipeline Testbenches

# Compiler
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Include directories
INCLUDES = -I./components -I./components/ALU -I./components/CU \
           -I./hazard_units -I./pipeline_registers -I./stages

# Output directory
BUILD_DIR = ./build

# Creates build directory 
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# FETCH STAGE TESTBENCH
fetch: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_fetch \
		testbenches/tb_fetch.v \
		stages/Fetch_Stage.v \
		components/PC.v \
		components/Instruction_Memory.v
	$(VVP) $(BUILD_DIR)/tb_fetch
	@echo "Fetch Stage test complete!"

fetch_wave: fetch
	$(GTKWAVE) $(BUILD_DIR)/fetch_stage_tb.vcd &

# DECODE STAGE TESTBENCH
decode: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_decode \
		testbenches/tb_decode.v \
		stages/Decode_Stage.v \
		components/Control_Unit.v \
		components/Register_File.v \
		components/Immediate_Generator.v
	$(VVP) $(BUILD_DIR)/tb_decode
	@echo "Decode Stage test complete!"

decode_wave: decode
	$(GTKWAVE) $(BUILD_DIR)/decode_stage_tb.vcd &

# EXECUTE STAGE TESTBENCH
execute: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_execute \
		testbenches/tb_execute.v \
		stages/Execute_Stage.v \
		components/ALU/ALU.v \
		components/ALU/ALU_Control.v \
		components/Branch_Unit.v \
		hazard_units/EX_Hazard_Detector.v \
		hazard_units/MEM_Hazard_Detector.v \
		hazard_units/Forwarding_Control.v \
		hazard_units/Forwarding_Mux.v
	$(VVP) $(BUILD_DIR)/tb_execute
	@echo "Execute Stage test complete!"

execute_wave: execute
	$(GTKWAVE) $(BUILD_DIR)/execute_stage_tb.vcd &

# MEMORY STAGE TESTBENCH
memory: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_memory \
		testbenches/tb_memory.v \
		stages/Memory_Stage.v \
		components/Data_Memory.v \
		hazard_units/MEM_WB_MEM_FU.v \
		hazard_units/Forwarding_Control_MEM.v
	$(VVP) $(BUILD_DIR)/tb_memory
	@echo "Memory Stage test complete!"

memory_wave: memory
	$(GTKWAVE) $(BUILD_DIR)/memory_stage_tb.vcd &

# WRITEBACK STAGE TESTBENCH
writeback: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_writeback \
		testbenches/tb_writeback.v \
		stages/WriteBack_Stage.v
	$(VVP) $(BUILD_DIR)/tb_writeback
	@echo "WriteBack Stage test complete!"

writeback_wave: writeback
	$(GTKWAVE) $(BUILD_DIR)/writeback_stage_tb.vcd &

# HAZARD DETECTION UNIT TESTBENCH
hdu: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_hdu \
		testbenches/tb_hdu.v \
		hazard_units/Hazard_Detection_Unit.v
	$(VVP) $(BUILD_DIR)/tb_hdu
	@echo "Hazard Detection Unit test complete!"

hdu_wave: hdu
	$(GTKWAVE) $(BUILD_DIR)/hdu_tb.vcd &

# FULL PIPELINE TESTBENCH
pipeline: $(BUILD_DIR)
	$(IVERILOG) $(INCLUDES) -o $(BUILD_DIR)/tb_pipeline \
		testbenches/tb_pipeline.v \
		RISC-V_Pipeline.v \
		stages/Fetch_Stage.v \
		stages/Decode_Stage.v \
		stages/Execute_Stage.v \
		stages/Memory_Stage.v \
		stages/WriteBack_Stage.v \
		pipeline_registers/IF_ID_Register.v \
		pipeline_registers/ID_EX_Register.v \
		pipeline_registers/EX_MEM_Register.v \
		pipeline_registers/MEM_WB_Register.v \
		components/PC_Register.v \
		components/Instruction_Memory.v \
		components/Data_Memory.v \
		components/Control_Unit.v \
		components/Register_File.v \
		components/Immediate_Generator.v \
		components/ALU/ALU.v \
		components/ALU/ALU_Control.v \
		components/Branch_Unit.v \
		hazard_units/Hazard_Detection_Unit.v \
		hazard_units/EX_Hazard_Detector.v \
		hazard_units/MEM_Hazard_Detector.v \
		hazard_units/Forwarding_Control.v \
		hazard_units/Forwarding_Mux.v \
		hazard_units/MEM_WB_MEM_FU.v \
		hazard_units/Forwarding_Control_MEM.v
	$(VVP) $(BUILD_DIR)/tb_pipeline
	@echo "Full Pipeline test complete!"

pipeline_wave: pipeline
	$(GTKWAVE) $(BUILD_DIR)/pipeline_tb.vcd &

# RUN ALL TESTS
all: fetch decode execute memory writeback hdu
	@echo ""
	@echo "=========================================="
	@echo "All testbenches completed!"
	@echo "=========================================="

# CLEAN BUILD ARTIFACTS
clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vcd
	@echo "Cleaned build artifacts"

# HELP
help:
	@echo "RISC-V Pipeline Testbench Makefile"
	@echo "======================================"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Individual Stage Tests:"
	@echo "  make fetch      - Run Fetch Stage testbench"
	@echo "  make decode     - Run Decode Stage testbench"
	@echo "  make execute    - Run Execute Stage testbench"
	@echo "  make memory     - Run Memory Stage testbench"
	@echo "  make writeback  - Run WriteBack Stage testbench"
	@echo "  make hdu        - Run Hazard Detection Unit testbench"
	@echo ""
	@echo "View Waveforms:"
	@echo "  make fetch_wave    - Run and view Fetch waveform"
	@echo "  make decode_wave   - Run and view Decode waveform"
	@echo "  (similar for other stages)"
	@echo ""
	@echo "Full Pipeline:"
	@echo "  make pipeline      - Run full pipeline testbench"
	@echo "  make pipeline_wave - Run and view pipeline waveform"
	@echo ""
	@echo "Other:"
	@echo "  make all    - Run all individual stage tests"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make help   - Show this help message"

.PHONY: all clean help fetch decode execute memory writeback hdu pipeline \
        fetch_wave decode_wave execute_wave memory_wave writeback_wave hdu_wave pipeline_wave