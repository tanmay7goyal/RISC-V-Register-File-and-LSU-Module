//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Sun May  4 19:08:37 2025
//Host        : AxzBot running 64-bit major release  (build 9200)
//Command     : generate_target proc_top.bd
//Design      : proc_top
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "proc_top,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=proc_top,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=5,numReposBlks=5,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=5,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "proc_top.hwdef" *) 
module proc_top
   (clk_i,
    dcache_valid_i,
    icache_instr_i,
    icache_pc_o,
    icache_rd_o,
    icache_valid_i,
    mem_addr_o,
    mem_read_data_i,
    mem_read_en_o,
    mem_write_data_o,
    mem_write_en_o,
    rst_i);
  input clk_i;
  input dcache_valid_i;
  input [15:0]icache_instr_i;
  output [15:0]icache_pc_o;
  output icache_rd_o;
  input icache_valid_i;
  output [15:0]mem_addr_o;
  input [15:0]mem_read_data_i;
  output mem_read_en_o;
  output [15:0]mem_write_data_o;
  output mem_write_en_o;
  input rst_i;

  wire Net;
  wire Net1;
  wire dcache_valid_i;
  wire decoder_fetch_valid_w;
  wire [15:0]decoder_imm_val_o;
  wire [25:0]decoder_one_hot_o;
  wire [15:0]decoder_opcode_instr_o;
  wire [15:0]decoder_opcode_pc_o;
  wire decoder_opcode_valid_o;
  wire [2:0]decoder_ra_idx_o;
  wire [2:0]decoder_rb_idx_o;
  wire [2:0]decoder_rd_idx_o;
  wire [15:0]exec_branch_pc_o;
  wire exec_branch_type_o;
  wire exec_branch_valid_o;
  wire [15:0]exec_current_pc_o;
  wire [15:0]exec_exec_wb_val_o;
  wire [2:0]exec_fwd_ex_rd_o;
  wire [15:0]exec_fwd_ex_val_o;
  wire exec_load_en_w;
  wire [15:0]exec_lsu_base_addr_o;
  wire [2:0]exec_memu_rd_idx_o;
  wire [15:0]exec_opcode_instr_o;
  wire [15:0]exec_opcode_pc_o;
  wire [15:0]fetch_fetch_instr_o;
  wire [15:0]fetch_fetch_pc_o;
  wire [15:0]fetch_icache_pc_o;
  wire fetch_icache_rd_o;
  wire fetch_instr_valid_o;
  wire [15:0]icache_instr_i;
  wire icache_valid_i;
  wire [2:0]lsu_fwd_mem_rd_o;
  wire [15:0]lsu_fwd_mem_val_o;
  wire lsu_lsu_pending_o;
  wire [15:0]lsu_mem_addr_o;
  wire lsu_mem_read_en_o;
  wire lsu_mem_stall_o;
  wire [15:0]lsu_mem_write_data_o;
  wire lsu_mem_write_en_o;
  wire [2:0]lsu_wb_rd_idx_o;
  wire [15:0]lsu_wb_val_o;
  wire [15:0]mem_read_data_i;
  wire [2:0]regread_exec_rd_idx_o;
  wire [15:0]regread_imm_val_o;
  wire [25:0]regread_one_hot_o;
  wire [15:0]regread_opcode_instr_o;
  wire [15:0]regread_opcode_pc_o;
  wire regread_opcode_valid_o;
  wire [15:0]regread_operand_val_a;
  wire [15:0]regread_operand_val_b;

  assign Net = clk_i;
  assign Net1 = rst_i;
  assign dcache_valid_i = dcache_valid_i;
  assign icache_instr_i = icache_instr_i[15:0];
  assign icache_pc_o[15:0] = fetch_icache_pc_o;
  assign icache_rd_o = fetch_icache_rd_o;
  assign icache_valid_i = icache_valid_i;
  assign mem_addr_o[15:0] = lsu_mem_addr_o;
  assign mem_read_data_i = mem_read_data_i[15:0];
  assign mem_read_en_o = lsu_mem_read_en_o;
  assign mem_write_data_o[15:0] = lsu_mem_write_data_o;
  assign mem_write_en_o = lsu_mem_write_en_o;
  decoder decoder
       (.clk_i(Net),
        .fetch_instr_i(fetch_fetch_instr_o),
        .fetch_pc_i(fetch_fetch_pc_o),
        .fetch_valid_w(decoder_fetch_valid_w),
        .imm_val_o(decoder_imm_val_o),
        .instr_valid_i(fetch_instr_valid_o),
        .mem_stall_i(lsu_mem_stall_o),
        .one_hot_o(decoder_one_hot_o),
        .opcode_instr_o(decoder_opcode_instr_o),
        .opcode_pc_o(decoder_opcode_pc_o),
        .opcode_valid_o(decoder_opcode_valid_o),
        .ra_idx_o(decoder_ra_idx_o),
        .rb_idx_o(decoder_rb_idx_o),
        .rd_idx_o(decoder_rd_idx_o),
        .rst_i(Net1));
  exec exec
       (.branch_pc_o(exec_branch_pc_o),
        .branch_type_o(exec_branch_type_o),
        .branch_valid_o(exec_branch_valid_o),
        .clk_i(Net),
        .current_pc_o(exec_current_pc_o),
        .exec_rd_idx_i(regread_exec_rd_idx_o),
        .exec_wb_val_o(exec_exec_wb_val_o),
        .fwd_ex_rd_o(exec_fwd_ex_rd_o),
        .fwd_ex_val_o(exec_fwd_ex_val_o),
        .imm_val_i(regread_imm_val_o),
        .load_en_o(exec_load_en_w),
        .load_pending_i(lsu_lsu_pending_o),
        .lsu_base_addr_o(exec_lsu_base_addr_o),
        .memu_rd_idx_o(exec_memu_rd_idx_o),
        .one_hot_i(regread_one_hot_o),
        .opcode_instr_i(regread_opcode_instr_o),
        .opcode_instr_o(exec_opcode_instr_o),
        .opcode_pc_i(regread_opcode_pc_o),
        .opcode_pc_o(exec_opcode_pc_o),
        .opcode_valid_i(regread_opcode_valid_o),
        .operand_val_a(regread_operand_val_a),
        .operand_val_b(regread_operand_val_b),
        .rst_i(Net1));
  fetch fetch
       (.branch_type_i(exec_branch_type_o),
        .branch_valid_i(exec_branch_valid_o),
        .clk_i(Net),
        .fetch_branch_pc_i(exec_branch_pc_o),
        .fetch_instr_o(fetch_fetch_instr_o),
        .fetch_pc_o(fetch_fetch_pc_o),
        .fetch_valid_i(decoder_fetch_valid_w),
        .icache_instr_i(icache_instr_i),
        .icache_pc_o(fetch_icache_pc_o),
        .icache_rd_o(fetch_icache_rd_o),
        .icache_valid_i(icache_valid_i),
        .instr_valid_o(fetch_instr_valid_o),
        .opcode_pc_i(exec_current_pc_o),
        .rst_i(Net1));
  lsu lsu
       (.clk_i(Net),
        .dcache_valid_i(dcache_valid_i),
        .exec_rd_idx_i(exec_memu_rd_idx_o),
        .exec_wb_val_i(exec_exec_wb_val_o),
        .fwd_mem_rd_o(lsu_fwd_mem_rd_o),
        .fwd_mem_val_o(lsu_fwd_mem_val_o),
        .lsu_base_addr_i(exec_lsu_base_addr_o),
        .lsu_pending_o(lsu_lsu_pending_o),
        .mem_addr_o(lsu_mem_addr_o),
        .mem_read_data_i(mem_read_data_i),
        .mem_read_en_o(lsu_mem_read_en_o),
        .mem_write_data_o(lsu_mem_write_data_o),
        .mem_write_en_o(lsu_mem_write_en_o),
        .opcode_instr_i(exec_opcode_instr_o),
        .opcode_pc_i(exec_opcode_pc_o),
        .rst_i(Net1),
        .wb_rd_idx_o(lsu_wb_rd_idx_o),
        .wb_val_o(lsu_wb_val_o));
  regread regread
       (.branch_pc_i(exec_branch_pc_o),
        .branch_type_i(exec_branch_type_o),
        .branch_valid_i(exec_branch_valid_o),
        .clk_i(Net),
        .dec_ra_idx_i(decoder_ra_idx_o),
        .dec_rb_idx_i(decoder_rb_idx_o),
        .dec_rd_idx_i(decoder_rd_idx_o),
        .ex_rd_idx_i(exec_fwd_ex_rd_o),
        .ex_val_i(exec_fwd_ex_val_o),
        .exec_rd_idx_o(regread_exec_rd_idx_o),
        .imm_val_i(decoder_imm_val_o),
        .imm_val_o(regread_imm_val_o),
        .load_en_i(exec_load_en_w),
        .mem_rd_idx_i(lsu_fwd_mem_rd_o),
        .mem_stall_o(lsu_mem_stall_o),
        .mem_val_i(lsu_fwd_mem_val_o),
        .one_hot_i(decoder_one_hot_o),
        .one_hot_o(regread_one_hot_o),
        .opcode_instr_i(decoder_opcode_instr_o),
        .opcode_instr_o(regread_opcode_instr_o),
        .opcode_pc_i(decoder_opcode_pc_o),
        .opcode_pc_o(regread_opcode_pc_o),
        .opcode_valid_i(decoder_opcode_valid_o),
        .opcode_valid_o(regread_opcode_valid_o),
        .operand_val_a(regread_operand_val_a),
        .operand_val_b(regread_operand_val_b),
        .rst_i(Net1),
        .wb_rd_idx_i(lsu_wb_rd_idx_o),
        .wb_val_i(lsu_wb_val_o));
endmodule
