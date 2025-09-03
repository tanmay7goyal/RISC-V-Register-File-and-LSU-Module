`timescale 1ns/1ps

module lsu_tb;

  // Clock and reset
  reg clk_i;
  reg rst_i;

  // Execute stage inputs
  reg [15:0] exec_wb_val_i;
  reg [2:0]  exec_rd_idx_i;
  reg [15:0] lsu_base_addr_i;
  reg [15:0] opcode_pc_i;
  reg [15:0] opcode_instr_i;
  reg        dcache_valid_i;

  // Memory input
  reg  [15:0] mem_read_data_i;

  // LSU outputs
  wire [15:0] mem_addr_o;
  wire        mem_read_en_o;
  wire        mem_write_en_o;
  wire [15:0] mem_write_data_o;
  wire [15:0] wb_val_o;
  wire [2:0]  wb_rd_idx_o;
  wire        mem_stall_o;
  wire [15:0] fwd_mem_val_o;
  wire [2:0]  fwd_mem_rd_o;
  wire        load_pending_o;

  // Instantiate the LSU
  lsu uut (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .exec_wb_val_i(exec_wb_val_i),
    .exec_rd_idx_i(exec_rd_idx_i),
    .dcache_valid_i(dcache_valid_i),
    .lsu_base_addr_i(lsu_base_addr_i),
    .opcode_pc_i(opcode_pc_i),
    .opcode_instr_i(opcode_instr_i),
    .mem_read_data_i(mem_read_data_i),
    .mem_addr_o(mem_addr_o),
    .mem_read_en_o(mem_read_en_o),
    .mem_write_en_o(mem_write_en_o),
    .mem_write_data_o(mem_write_data_o),
    .wb_val_o(wb_val_o),
    .wb_rd_idx_o(wb_rd_idx_o),
    .load_pending_o(load_pending_o),
    .fwd_mem_val_o(fwd_mem_val_o),
    .fwd_mem_rd_o(fwd_mem_rd_o)
  );

  // Clock generation
  initial begin
    clk_i = 1;
    forever #5 clk_i = ~clk_i;
  end

  // Stimulus
  initial begin
    $display("Starting LSU Testbench...");
    rst_i = 1;
    exec_wb_val_i = 0;
    exec_rd_idx_i = 0;
    lsu_base_addr_i = 0;
    opcode_pc_i = 0;
    opcode_instr_i = 0;
    mem_read_data_i = 0;

    #10 rst_i = 0;

    // -------- Test SW (Store Word) --------

    opcode_pc_i = 16'h20;
    opcode_instr_i = 16'b0000_0011_0101_0000;
    exec_rd_idx_i   = 3'd3;
    exec_wb_val_i  = 16'h1221; 
    
    
    #10;
    opcode_pc_i = 16'h30;
    opcode_instr_i = 16'b0101_0110_0100_0010; // opcode[15:12] = 0101 = SW
    exec_wb_val_i  = 16'h4000;               // Data to store
    exec_rd_idx_i  = 3'd5;
    lsu_base_addr_i = 16'h0040;              // Store address

    #10;
    opcode_pc_i = 16'h40;
    opcode_instr_i = 16'b0011_0011_0101_0000;
    exec_rd_idx_i   = 3'd7;
    exec_wb_val_i  = 16'h0099;
    
    
    // -------- Test LW (Load Word) --------
    #10;
    opcode_pc_i = 16'h50;
    opcode_instr_i = 16'b0100_0000_0000_0110; // opcode[15:12] = 0100 = LW
    lsu_base_addr_i = 16'h8000;
    mem_read_data_i = 16'hDEAD;              // Data from memory
    exec_rd_idx_i   = 3'd4;
    
    #10;
    opcode_pc_i = 16'h90;
    opcode_instr_i = 16'b0101_1001_0000_1100; // opcode[15:12] = 0101 = SW
    exec_wb_val_i  = 16'h4000;               // Data to store
    lsu_base_addr_i = 16'h2040; 
    
    
    #10;
    opcode_pc_i = 16'h40;
    opcode_instr_i = 16'b0010_0011_0101_0000;
    exec_rd_idx_i   = 3'd3;
    exec_wb_val_i  = 16'hff0f;


    // Wait a few cycles for writeback to settle
    #30;

    $display("SW mem_write_en: %b, addr: 0x%h, data: 0x%h", mem_write_en_o, mem_addr_o, mem_write_data_o);
    $display("LW mem_read_en:  %b, wb_val: 0x%h, wb_rd_idx: %d", mem_read_en_o, wb_val_o, wb_rd_idx_o);
    $display("Forwarded val:  0x%h, rd_idx: %d", fwd_mem_val_o, fwd_mem_rd_o);

    $finish;
  end

endmodule
