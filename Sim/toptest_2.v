`timescale 1ns/1ps

module tb_proc_top_wrapper2;

  reg clk_i = 1;
  reg rst_i;

  always #5 clk_i = ~clk_i;  // 10ns clock

  // Wires and Regs
  wire [15:0] icache_pc_o_0;
  wire        icache_rd_o_0;
  wire         icache_valid_i_0;
  wire         dcache_valid_i_0;
  wire  [15:0] icache_instr_i_0;

  wire [15:0] mem_addr_o_0;
  wire [15:0] mem_write_data_o_0;
  wire  [15:0] mem_read_data_i_0;
  wire        mem_read_en_o_0;
  wire        mem_write_en_o_0;

  // Instruction memory (icache-style ROM)
  reg [15:0] instr_mem [0:31];
  integer i;

  // proc_top Wrapper Instance
  proc_top_wrapper dut (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .icache_instr_i_0(icache_instr_i_0),
    .icache_pc_o_0(icache_pc_o_0),
    .icache_rd_o_0(icache_rd_o_0),
    .icache_valid_i_0(icache_valid_i_0),
    .dcache_valid_i_0(dcache_valid_i_0),
    .mem_addr_o_0(mem_addr_o_0),
    .mem_read_data_i_0(mem_read_data_i_0),
    .mem_read_en_o_0(mem_read_en_o_0),
    .mem_write_data_o_0(mem_write_data_o_0),
    .mem_write_en_o_0(mem_write_en_o_0)
  );
  reg [15:0] data_r;
  assign icache_instr_i_0 = instr_mem[icache_pc_o_0>>1];
  assign icache_valid_i_0 = 1;
  assign dcache_valid_i_0 = 1;
  assign mem_read_data_i_0 = 
                mem_addr_o_0[3:2] == 0 ?
                mem_addr_o_0[1:0] == 0 ? 1 :
                mem_addr_o_0[1:0] == 1 ? 2 :
                mem_addr_o_0[1:0] == 2 ? 3 : 10 :
                mem_addr_o_0[3:2] == 1 ?
                mem_addr_o_0[1:0] == 0 ? 5 :
                mem_addr_o_0[1:0] == 1 ? 9 :
                mem_addr_o_0[1:0] == 2 ? 6 : 8 :
                mem_addr_o_0[3:2] == 2 ?
                mem_addr_o_0[1:0] == 0 ? 11 :
                mem_addr_o_0[1:0] == 1 ? 92 :
                mem_addr_o_0[1:0] == 2 ? 32 : 99 :
                mem_addr_o_0[3:2] == 3 ?
                mem_addr_o_0[1:0] == 0 ? 15 :
                mem_addr_o_0[1:0] == 1 ? 19 :
                mem_addr_o_0[1:0] == 2 ? 61 : 84 : 
                20;  // dummy memory read data
                

  initial begin
    // Reset and Setup
    rst_i = 1;

    // Load dummy instructions
    instr_mem[0]  = 16'b0000_011_010_111_111; //AWC
    instr_mem[1]  = 16'b0001_001_010_000111; // ADI
    instr_mem[2]  = 16'b0000_111_111_111_001; // ADI
    instr_mem[3]  = 16'b0100_011_001_010000; // LW
    instr_mem[4]  = 16'b0000_100_011_101_000;   // ADA
    instr_mem[5]  = 16'b0000_101_010_111_001;   // ADZ
    instr_mem[6]  = 16'b0010_100_110_101_001; // NDZ
    instr_mem[7]  = 16'b0000_101_010_011_001; // ADZ
    instr_mem[8]  = 16'b0000_111_110_000100;  // BEQ
    instr_mem[9]  = 16'b0000_000_000_000010;   // ADC
    instr_mem[10] = 16'b0100_111_101_000001;  // LW 
    instr_mem[11] = 16'b0011_101_010_001111;   // LLI
    instr_mem[12] = 16'b1000_101_010_100011;  // BEQ
    instr_mem[13] = 16'b0111_011_010101100;   // SM 
    instr_mem[14] = 16'b0110_110_011111110;   // LM 
    instr_mem[15] = 16'b0011_101_000001111;   // LLI
    instr_mem[16] = 16'b0011_111_000000000;   // LLI
    instr_mem[17] = 16'b1001_110_100_000011;   // BLE
    instr_mem[18] = 16'b0011_100_001000000;   // LLI
    instr_mem[19] = 16'b0000_111_001_101_000; // ADA
    instr_mem[20] = 16'b0101_001_110_001001; // SW
    instr_mem[22] = 16'b0011_111_000000000;   //LLI
    instr_mem[21] = 16'b0011_101_010_001_000;  //lli
    instr_mem[23] = 16'b1100_101_111_000000;  // JLR
    instr_mem[24] = 16'b0000_111_110_000001;  // BEQ
    instr_mem[25] = 16'b0011_101_000000000;   // LLI
    instr_mem[26] = 16'b1100_101_101_000001;   // JLR 

    // Hold reset for a few cycles
    #20;
    rst_i = 0;
    data_r = 0 ;
    i = 1;
    #1600;
    $finish;
  end

endmodule
