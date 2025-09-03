`timescale 1ns/1ps

module lsu (
  input  wire        clk_i,
  input  wire        rst_i,
  input  wire [15:0] opcode_pc_i, 
  input  wire [15:0] opcode_instr_i, 
  // From Execute
  input  wire [15:0] exec_wb_val_i, 
  input  wire [2:0]  exec_rd_idx_i,   // ALU result: address for LW/LM or value passthrough
  input  wire [15:0] lsu_base_addr_i,  // Value to store (from RegRead)
  output wire        lsu_pending_o,
    // Data returned from memory
         // opcode[3:0] from exec stage

  // To Mem
  input  wire [15:0]  mem_read_data_i,
  input  wire         dcache_valid_i, // load in
  output wire [15:0]  mem_addr_o,
  output wire         mem_read_en_o, //read en
  output wire         mem_write_en_o, //store en
  output wire [15:0]  mem_write_data_o, //store out

  // To Writeback
  output reg  [15:0] wb_val_o,
  output reg  [2:0]  wb_rd_idx_o,
  output wire [15:0] fwd_mem_val_o,
  output wire [2:0]  fwd_mem_rd_o);
  
  
  
reg [15:0] wb_val_r, mem_write_data_r;
reg [2:0]  wb_rd_idx_r;

  // Decode type of operation (we only care LW/LM vs SW/SM)
assign mem_read_en_o  =  (opcode_instr_i[15:12] == 4'b0100) || (opcode_instr_i[15:12] == 4'b0110) ? 1 : 0;
assign mem_write_en_o  = (opcode_instr_i[15:12] == 4'b0101) || (opcode_instr_i[15:12] == 4'b0111) ? 1 : 0;


// load store or none cases
always @(*) begin
      if (mem_read_en_o & dcache_valid_i) begin
        wb_val_r      <= mem_read_data_i;
        wb_rd_idx_r   <= exec_rd_idx_i;
      end
      else if (mem_write_en_o) begin
        mem_write_data_r <= exec_wb_val_i;
      end
      else begin
        wb_val_r         <= exec_wb_val_i;
        wb_rd_idx_r      <= exec_rd_idx_i;
      end
end
// SEQ push to WB STAGE
always @(posedge clk_i) begin
    if (rst_i) begin
      wb_val_o         <= 16'd0;
      wb_rd_idx_o      <= 3'd0;
    end
    else begin
      wb_val_o         <= fwd_mem_val_o;
      wb_rd_idx_o      <= fwd_mem_rd_o;
    end
end
  
  assign mem_addr_o       = lsu_base_addr_i;
  assign mem_write_data_o = mem_write_data_r;
  //assign mem_stall_o = 0;
  assign fwd_mem_val_o  = wb_val_r;
  assign fwd_mem_rd_o = wb_rd_idx_r;
  assign lsu_pending_o = !dcache_valid_i;
endmodule
