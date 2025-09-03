//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Sun May  4 16:27:58 2025
//Host        : AxzBot running 64-bit major release  (build 9200)
//Command     : generate_target proc_top_wrapper.bd
//Design      : proc_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module proc_top_wrapper
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

  wire clk_i;
  wire dcache_valid_i;
  wire [15:0]icache_instr_i;
  wire [15:0]icache_pc_o;
  wire icache_rd_o;
  wire icache_valid_i;
  wire [15:0]mem_addr_o;
  wire [15:0]mem_read_data_i;
  wire mem_read_en_o;
  wire [15:0]mem_write_data_o;
  wire mem_write_en_o;
  wire rst_i;

  proc_top proc_top_i
       (.clk_i(clk_i),
        .dcache_valid_i(dcache_valid_i),
        .icache_instr_i(icache_instr_i),
        .icache_pc_o(icache_pc_o),
        .icache_rd_o(icache_rd_o),
        .icache_valid_i(icache_valid_i),
        .mem_addr_o(mem_addr_o),
        .mem_read_data_i(mem_read_data_i),
        .mem_read_en_o(mem_read_en_o),
        .mem_write_data_o(mem_write_data_o),
        .mem_write_en_o(mem_write_en_o),
        .rst_i(rst_i));
endmodule
