`timescale 1ns/1ps
`include "../../sources_1/new/def_ex.v"
module tb_regread;

  // Clock and reset
  reg clk_i;
  reg rst_i;

  // Inputs
  reg opcode_valid_i;
  reg [15:0] opcode_pc_i;
  reg [15:0] opcode_instr_i;
  reg [25:0] one_hot_i;
  reg [2:0] dec_rd_idx_i, dec_ra_idx_i, dec_rb_idx_i;
  reg branch_valid_i;
  reg [15:0] branch_pc_i;
  reg [15:0] ex_val_i;
  reg [2:0] ex_rd_idx_i;
  reg [15:0] mem_val_i;
  reg [2:0] mem_rd_idx_i;
  reg [15:0] wb_val_i;
  reg [15:0] imm_val_i;
  reg [2:0] wb_rd_idx_i;
  reg        load_en_i;

  // Outputs
  wire opcode_valid_o;
  wire [15:0] opcode_pc_o;
  wire [15:0] opcode_instr_o;
  wire [25:0] one_hot_o;
  wire [15:0] operand_val_a;
  wire [15:0] operand_val_b;
  wire [2:0] exec_rd_idx_o;
  wire [15:0] imm_val_o;
  wire       mem_stall_o;
  // DUT
  regread uut (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .opcode_valid_i(opcode_valid_i),
    .opcode_pc_i(opcode_pc_i),
    .opcode_instr_i(opcode_instr_i),
    .one_hot_i(one_hot_i),
    .imm_val_i(imm_val_i),
    .load_en_i(load_en_i),
    .dec_rd_idx_i(dec_rd_idx_i),
    .dec_ra_idx_i(dec_ra_idx_i),
    .dec_rb_idx_i(dec_rb_idx_i),
    .branch_valid_i(branch_valid_i),
    .branch_type_i(branch_type_i),
    .branch_pc_i(branch_pc_i),
    .opcode_valid_o(opcode_valid_o),
    .opcode_pc_o(opcode_pc_o),
    .opcode_instr_o(opcode_instr_o),
    .one_hot_o(one_hot_o),
    .operand_val_a(operand_val_a),
    .operand_val_b(operand_val_b),
    .exec_rd_idx_o(exec_rd_idx_o),
    .ex_val_i(ex_val_i),
    .ex_rd_idx_i(ex_rd_idx_i),
    .mem_val_i(mem_val_i),
    .mem_stall_o(mem_stall_o),
    .mem_rd_idx_i(mem_rd_idx_i),
    .wb_val_i(wb_val_i),
    .wb_rd_idx_i(wb_rd_idx_i),
    .imm_val_o(imm_val_o)
  );

  // Clock
  always #5 clk_i = ~clk_i;
    function [25:0] set_one_hot;
        input integer op;
        begin
            set_one_hot = 0;
            set_one_hot[op] = 1;
        end
    endfunction
    
  initial begin

    // Reset
    clk_i = 1;
    rst_i = 1;
    opcode_valid_i = 0;
    opcode_pc_i = 0;
    opcode_instr_i = 0;
    one_hot_i = 0;
    dec_rd_idx_i = 0;
    dec_ra_idx_i = 0;
    dec_rb_idx_i = 0;
    branch_valid_i = 0;
    branch_pc_i = 0;
    ex_val_i = 0;
    ex_rd_idx_i = 0;
    mem_val_i = 0;
    mem_rd_idx_i = 0;
    wb_val_i = 0;
    wb_rd_idx_i = 0;
    
    #10 rst_i=0;
    
    uut.gpr[1] = 16'h2222;
    uut.gpr[2] = 16'h3333;
    uut.gpr[3] = 16'h4444;
    uut.gpr[4] = 16'h5555;
    uut.gpr[5] = 16'h6666;
    uut.gpr[6] = 16'h7777;
    uut.gpr[7] = 16'h8888;
    
    #10;
    
    opcode_valid_i = 1;
    opcode_pc_i = 16'h0102;
    opcode_instr_i = 16'b0000010010100010;
    one_hot_i = set_one_hot(`ADC);
    dec_rd_idx_i = 3'd4;
    dec_ra_idx_i = 3'd5;
    dec_rb_idx_i = 3'd1;
    wb_val_i = 16'h14;
    wb_rd_idx_i = 3'd5;
    
    #10;
    
    opcode_valid_i = 1;
    opcode_pc_i = 16'h0104;
    opcode_instr_i = 16'b0001001000111010;
    one_hot_i = set_one_hot(`ADI);
    dec_rd_idx_i = 3'd1;
    dec_ra_idx_i = 3'd5;
    imm_val_i = 16'h0003;
    wb_val_i = 16'h20;
    wb_rd_idx_i = 3'd7;
    branch_valid_i = 1;
    branch_pc_i = 16'h4000;
    
    #10;
    opcode_valid_i = 1;
    opcode_pc_i = 16'h0110;
    opcode_instr_i = 16'b0010010010101001;
    one_hot_i = set_one_hot(`NDZ);
    dec_rd_idx_i = 3'd7;
    dec_ra_idx_i = 3'd7;
    dec_rb_idx_i = 3'd3;
    wb_val_i = 16'hFF;
    wb_rd_idx_i = 3'd4;
    mem_val_i = 16'hAB;
    mem_rd_idx_i = 3'd5;
    ex_val_i = 16'hDC;
    ex_rd_idx_i = 3'd3;
    branch_valid_i = 0;
    
    #10;
    
    opcode_pc_i = 16'h4000;
    opcode_instr_i = 16'b0010010110101011;
    one_hot_i = set_one_hot(`ADZ);
    dec_rd_idx_i = 3'd2;
    dec_ra_idx_i = 3'd4;
    dec_rb_idx_i = 3'd6;
    wb_val_i = 16'hd;
    wb_rd_idx_i = 3'd1;
    
    #10;
    
    opcode_valid_i = 1;
    opcode_pc_i = 16'h0104;
    opcode_instr_i = 16'b0001001000111010;
    one_hot_i = set_one_hot(`ADI);
    dec_rd_idx_i = 3'd1;
    dec_ra_idx_i = 3'd5;
    imm_val_i = 16'h0003;
    wb_val_i = 16'h20;
    wb_rd_idx_i = 3'd7;
    branch_valid_i = 1;
    branch_pc_i = 16'h9000;
    
    #10;
    opcode_valid_i = 1;
    opcode_pc_i = 16'h0110;
    opcode_instr_i = 16'b0010010010101001;
    one_hot_i = set_one_hot(`NDZ);
    dec_rd_idx_i = 3'd7;
    dec_ra_idx_i = 3'd7;
    dec_rb_idx_i = 3'd3;
    wb_val_i = 16'hFF;
    wb_rd_idx_i = 3'd4;
    mem_val_i = 16'hAB;
    mem_rd_idx_i = 3'd5;
    ex_val_i = 16'hDC;
    ex_rd_idx_i = 3'd3;
    
    #10;
    
    opcode_pc_i = 16'h4000;
    opcode_instr_i = 16'b0010010110101011;
    one_hot_i = set_one_hot(`ADZ);
    dec_rd_idx_i = 3'd2;
    dec_ra_idx_i = 3'd4;
    dec_rb_idx_i = 3'd6;
    wb_val_i = 16'hd;
    wb_rd_idx_i = 3'd1;
    
    #10;
    
    opcode_valid_i = 1;
    opcode_pc_i = 16'h9000;
    opcode_instr_i = 16'b0000010010100010;
    one_hot_i = set_one_hot(`ADC);
    dec_rd_idx_i = 3'd4;
    dec_ra_idx_i = 3'd5;
    dec_rb_idx_i = 3'd1;
    wb_val_i = 16'h14;
    wb_rd_idx_i = 3'd5;
    
    #40 $finish;
  end


endmodule
