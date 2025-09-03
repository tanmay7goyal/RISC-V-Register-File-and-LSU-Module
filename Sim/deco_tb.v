`timescale 1ns/1ps
`include "../../sources_1/new/def_iitb25.v"

module tb_decoder;

  // Inputs
  reg clk_i;
  reg rst_i;
  reg instr_valid_i;
  reg [15:0] fetch_pc_i;
  reg [15:0] fetch_instr_i;
  reg mem_stall_i;

  // Outputs
  //wire fetch_valid_o;
  wire fetch_valid_w;
  wire opcode_valid_o;
  wire [15:0] opcode_pc_o;
  wire [15:0] opcode_instr_o;
  wire [25:0] one_hot_o;
  wire [2:0] rd_idx_o, ra_idx_o, rb_idx_o;
  wire [15:0] imm_val_o;

  // Instruction Queue
  reg [15:0] instr_mem [0:15];
  reg [15:0] pc_mem [0:15];
  integer instr_ptr;

  // Track fetch_valid_o
  reg fetch_valid_d; // delayed version

  // Instantiate DUT
  decoder uut (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .instr_valid_i(instr_valid_i),
    .fetch_pc_i(fetch_pc_i),
    .fetch_instr_i(fetch_instr_i),
   // .fetch_valid_o(fetch_valid_o),
    .opcode_valid_o(opcode_valid_o),
    .opcode_pc_o(opcode_pc_o),
    .opcode_instr_o(opcode_instr_o),
    .one_hot_o(one_hot_o),
    .rd_idx_o(rd_idx_o),
    .ra_idx_o(ra_idx_o),
    .rb_idx_o(rb_idx_o),
    .imm_val_o(imm_val_o),
    .fetch_valid_w(fetch_valid_w),
    .mem_stall_i(mem_stall_i)
  );

  // Clock Generation
  always #5 clk_i = ~clk_i;

  initial begin
    $display("\n===== START DECODER TEST =====");

    // Initialize
    clk_i = 1;
    rst_i = 1;
    instr_valid_i = 0;
    fetch_pc_i = 0;
    fetch_instr_i = 0;
    mem_stall_i = 0;
   // fetch_valid_d = 0;
    instr_ptr = 0;

    // Load instructions
    pc_mem[0] = 16'h002A; instr_mem[0] = 16'b0011_101_000000001; // LLI
    pc_mem[1] = 16'h001E; instr_mem[1] = 16'b0100_100_101_110011; // LW
    pc_mem[2] = 16'h0020; instr_mem[2] = 16'b0101_011_100_001111; // SW
    pc_mem[3] = 16'h0032; instr_mem[3] = 16'b1010_001_010_000001; //BLE
    pc_mem[4] = 16'h0022; instr_mem[4] = 16'b0011_111_000000111; // LLI
    pc_mem[5] = 16'h002C; instr_mem[5] = 16'b0110_010_001110010; // LM
    pc_mem[6] = 16'h003E; instr_mem[6] = 16'b0111_011_011000111; // SM
    pc_mem[7] = 16'h0042; instr_mem[7] = 16'b1000_001_010_001101;
    pc_mem[8] = 16'h0010; instr_mem[8] = 16'b0110_110_000000000;
    pc_mem[9] = 16'h0034; instr_mem[9] = 16'b1010_101_110_111101; //BLE // BEQ

    // Deassert reset
    @(posedge clk_i); rst_i = 0;

    // Main loop
    forever begin
      @(posedge clk_i);

      // Send new instruction only if previous cycle gave us fetch_valid_o = 1
      if (fetch_valid_w && instr_ptr < 10) begin
        instr_valid_i <= 1;
        fetch_pc_i    <= pc_mem[instr_ptr];
        fetch_instr_i <= instr_mem[instr_ptr];
        instr_ptr     <= instr_ptr + 1;
      end else begin
        instr_valid_i <= 0;
      end

      // Update delayed fetch_valid
     // fetch_valid_d <= fetch_valid_o;

      // Stop simulation after last instruction is done
      if (instr_ptr == 10) begin
      #10;
        $display("===== END DECODER TEST =====");
        $finish;
      end
    end
  end


  // Debug print
  always @(posedge clk_i) begin
    if (opcode_valid_o) begin
      $display("[Time %0t ns] PC: %h | Instr: %h | OneHot: %b | rd=%0d ra=%0d rb=%0d imm=%h",
          $time, opcode_pc_o, opcode_instr_o, one_hot_o,
          rd_idx_o, ra_idx_o, rb_idx_o, imm_val_o);
    end
  end

endmodule
