
DRAWIO_SRC ?= $(CURDIR)/../src/diagram.drawio
DRAWIO_BIN ?= drawio
LAYER0_BIN ?= drawio-layer

TEMP_XML    = temp.xml
FILE_PNG    = $(shell seq -f "cpu_%02g.png" 0 22)
FILE_PNG   += $(shell seq -f "cu_%02g.png" 0 25)
FILE_GIF    = schoolRISCV.gif

all: png gif

png: $(FILE_PNG)  program_flow.png

gif: $(FILE_GIF)

clean:
	rm -f *.png *.gif *.xml

gui:
	$(DRAWIO_BIN) $(DRAWIO_SRC)

####################################################
# gif from png

$(FILE_GIF): $(FILE_PNG)
	convert -delay 150 -loop 0 $(FILE_PNG) $@

####################################################
# layer by layer image generation

# uncompress drawio xml
$(TEMP_XML): $(DRAWIO_SRC)
	$(DRAWIO_BIN) --export --uncompressed --output $@ $(DRAWIO_SRC)

# page CPU
LAYER0_00_0 = 0_border_wide 0_cpuState
LAYER0_00_1 = $(LAYER0_00_0) 0_DataMemory
LAYER0_01_1 = $(LAYER0_00_0) 1_ADDI_addr_shift_BLUE
LAYER0_02_0 = $(LAYER0_00_0) 1_ADDI_addr_shift
LAYER0_02_1 = $(LAYER0_02_0) 1_ADDI_instr 2_ADDI_decode_rs1_BLUE 2_ADDI_instr_rs1_BLUE
LAYER0_03_0 = $(LAYER0_02_0) 2_ADDI_decode_rs1
LAYER0_03_1 = $(LAYER0_03_0) 3_ADDI_instr_imm_BLUE 3_ADDI_decode_immI_BLUE
LAYER0_04_0 = $(LAYER0_03_0) 3_ADDI_decode_immI
LAYER0_04_1 = $(LAYER0_04_0) 4_ADDI_instr_opcode_BLUE 4_ADDI_ALU_BLUE 5_ADDI_stub_aluSrc_mux_BLUE
LAYER0_05_0 = $(LAYER0_04_0) 5_ADDI_stub_aluSrc_mux 4_ADDI_ALU
LAYER0_05_1 = $(LAYER0_05_0) 6_ADDI_decode_rd_BLUE 6_ADDI_instr_rd_BLUE
LAYER0_06_0 = $(LAYER0_05_0) 6_ADDI_decode_rd
LAYER0_06_1 = $(LAYER0_06_0) 4_ADDI_instr_opcode_BLUE 7_ADDI_regfile_write_BLUE 8_ADDI_stub_wdSrc_mux_BLUE
LAYER0_07_0 = $(LAYER0_06_0) 7_ADDI_regfile_write 8_ADDI_stub_wdSrc_mux
LAYER0_07_1 = $(LAYER0_07_0) 9_ADDI_pcPlus4_BLUE 10_ADDI_stub_pcSrc_mux_BLUE 9_ADDI_instr
LAYER0_08_0 = $(LAYER0_07_0) 9_ADDI_pcPlus4 10_ADDI_stub_pcSrc_mux
LAYER0_08_1 = $(LAYER0_08_0) 10_ADDI_instr_imm
LAYER0_09_1 = $(LAYER0_08_0) 11_ADD_instr
LAYER0_10_1 = $(LAYER0_08_0) 11_ADD_instr_rs_BLUE 11_ADD_decode_rs2_BLUE
LAYER0_11_0 = $(filter-out 5_ADDI_stub_aluSrc_mux, $(LAYER0_08_0)) 11_ADD_decode_rs2
LAYER0_11_1 = $(LAYER0_11_0) 12_ADD_aluSrc_mux_BLUE 12_ADD_instr_opcode_BLUE
LAYER0_12_0 = $(LAYER0_11_0) 12_ADD_aluSrc_mux
LAYER0_12_1 = $(LAYER0_12_0) 11_ADD_instr
LAYER0_13_0 = $(filter-out 8_ADDI_stub_wdSrc_mux, $(LAYER0_12_0))
LAYER0_13_1 = $(LAYER0_13_0) 13_LUI_immU_and_wdSrc_mux_BLUE 13_LUI_instr
LAYER0_14_0 = $(LAYER0_13_0) 13_LUI_immU_and_wdSrc_mux
LAYER0_14_1 = $(LAYER0_14_0) 14_BEQ_immB_and_pcBranch_BLUE 14_BEQ_instr_imm_BLUE
LAYER0_15_0 = $(filter-out 10_ADDI_stub_pcSrc_mux, $(LAYER0_14_0)) 14_BEQ_immB_and_pcBranch
LAYER0_15_1 = $(LAYER0_15_0) 15_BEQ_pcSrc_mux_BLUE 15_BEQ_instr_opcode_BLUE
LAYER0_16_0 = $(LAYER0_15_0) 15_BEQ_pcSrc_mux
LAYER0_16_1 = $(LAYER0_16_0) 16_BEQ_aluZero_and_branch_BLUE 17_BEQ_stub_condZero_BLUE 15_BEQ_instr_opcode_BLUE
LAYER0_17_0 = $(LAYER0_16_0) 16_BEQ_aluZero_and_branch 17_BEQ_stub_condZero
LAYER0_17_1 = $(LAYER0_17_0) 17_BEQ_instr
LAYER0_18_1 = $(LAYER0_17_0) 18_BNE_instr
LAYER0_19_0 = $(filter-out 17_BEQ_stub_condZero, $(LAYER0_17_0))
LAYER0_19_1 = $(LAYER0_19_0) 18_BNE_condZero_BLUE 18_BNE_instr_opcode_BLUE
LAYER0_20_0 = $(LAYER0_19_0) 18_BNE_condZero
LAYER0_20_1 = $(LAYER0_20_0) 19_CU_aluSrc_aluControl_BLUE
LAYER0_21_0 = $(LAYER0_20_0) 19_CU_aluSrc_aluControl
LAYER0_21_1 = $(LAYER0_21_0) 20_CU_decode_cmd_BLUE
LAYER0_22_1 = $(LAYER0_21_0) 20_CU_decode_cmd

cpu_%.png: $(TEMP_XML)
	$(LAYER0_BIN) $(TEMP_XML) --page-index 0 --action-type show_only --name $(LAYER0_$*_1)
	$(DRAWIO_BIN) $(TEMP_XML) --page-index 0 --export --output $@

# page CU
LAYER1_00_1 = 0_Border 0_Table 0_CPU
LAYER1_01_1 = 0_Border 1_0_ADDI_table_cmd 1_0_ADDI_CPU_cmd
LAYER1_02_1 = 0_Border 1_1_ADDI_table_aluSrc 1_1_ADDI_CPU_aluSrc
LAYER1_03_1 = 0_Border 1_2_ADDI_table_wdSrc 1_2_ADDI_CPU_wdSrc
LAYER1_04_1 = 0_Border 1_3_ADDI_table_pcSrc 1_3_ADDI_CPU_pcSrc
LAYER1_05_1 = 0_Border 1_4_ADDI_table_final 1_4_ADDI_CPU_final
LAYER1_06_1 = 0_Border 2_0_ADD_table_cmd 2_0_ADD_CPU_cmd
LAYER1_07_1 = 0_Border 2_1_ADD_table_aluSrc 2_1_ADD_CPU_aluSrc
LAYER1_08_1 = 0_Border 2_2_ADD_table_wdSrc 1_2_ADDI_CPU_wdSrc
LAYER1_09_1 = 0_Border 2_3_ADD_table_pcSrc 1_3_ADDI_CPU_pcSrc
LAYER1_10_1 = 0_Border 2_4_ADD_table_final 2_4_ADD_CPU_final
LAYER1_11_1 = 0_Border 3_1_LUI_table_cmd 3_0_LUI_CPU_cmd
LAYER1_12_1 = 0_Border 3_2_LUI_table_wdSrc 3_2_LUI_CPU_wdSrc
LAYER1_13_1 = 0_Border 3_3_LUI_table_pcSrc 3_2_LUI_CPU_wdSrc
LAYER1_14_1 = 0_Border 3_4_LUI_table_final 3_4_LUI_CPU_final
LAYER1_15_1 = 0_Border 4_0_BEQ_table_cmd 1_0_ADDI_CPU_cmd
LAYER1_16_1 = 0_Border 4_1_BEQ_table_aluSrc 2_1_ADD_CPU_aluSrc
LAYER1_17_1 = 0_Border 4_2_BEQ_table_wdSrc 2_1_ADD_CPU_aluSrc
LAYER1_18_1 = 0_Border 4_3_BEQ_table_pcBranch 4_3_BEQ_CPU_pcBranch
LAYER1_19_1 = 0_Border 4_4_BEQ_table_pcSrc 4_4_BEQ_CPU_pcBranch
LAYER1_20_1 = 0_Border 4_4_BEQ_table_pcSrc 4_5_BEQ_CPU_pcPlus4
LAYER1_21_1 = 0_Border 5_0_BEN_table_cmd 1_0_ADDI_CPU_cmd
LAYER1_22_1 = 0_Border 5_1_BNE_table_aluSrc 2_1_ADD_CPU_aluSrc
LAYER1_23_1 = 0_Border 5_2_BNE_table_pcSrc 5_2_BNE_pcBranch
LAYER1_24_1 = 0_Border 5_2_BNE_table_pcSrc 5_3_BNE_pcPlus4
LAYER1_25_1 = 0_Border 5_3_BNE_table_final 0_CPU

cu_%.png: $(TEMP_XML)
	$(LAYER0_BIN) $(TEMP_XML) --page-index 1 --action-type show_only --name $(LAYER1_$*_1)
	$(DRAWIO_BIN) $(TEMP_XML) --page-index 1 --export --output $@

# other images
program_flow.png: $(DRAWIO_SRC)
	$(DRAWIO_BIN) --export --page-index 4 $< --output $@
