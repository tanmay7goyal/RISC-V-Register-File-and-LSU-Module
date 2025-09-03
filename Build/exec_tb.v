`timescale 1ns/1ps
`include "../../sources_1/new/def_ex.v"

module tb_exec();

    // Clock and reset
    reg clk_i;
    reg rst_i;
    
    // Inputs
    reg opcode_valid_i;
    reg [15:0] opcode_pc_i;
    reg [15:0] opcode_instr_i;
    reg [25:0] one_hot_i;
    reg [15:0] operand_val_a;
    reg [15:0] operand_val_b;
    reg [15:0] imm_val_i;
    reg [2:0] exec_rd_idx_i;
    
    // Outputs
    wire [15:0] exec_wb_val_o;
    wire [2:0] memu_rd_idx_o;
    wire branch_valid_o;
    wire [15:0] branch_pc_o;
    wire [15:0] opcode_pc_o;
    wire [15:0] opcode_instr_o;
    wire        load_en_o;
    wire [15:0] current_pc_o;
    wire [15:0] fwd_wb_val_o;
    wire [2:0] fwd_ex_rd_o;

    // Instantiate the Unit Under Test
    exec uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .opcode_valid_i(opcode_valid_i),
        .opcode_pc_i(opcode_pc_i),
        .opcode_instr_i(opcode_instr_i),
        .one_hot_i(one_hot_i),        
        .branch_type_o(branch_type_o),
        .operand_val_a(operand_val_a),
        .operand_val_b(operand_val_b),
        .imm_val_i(imm_val_i),
        .exec_rd_idx_i(exec_rd_idx_i),
        .exec_wb_val_o(exec_wb_val_o),
        .memu_rd_idx_o(memu_rd_idx_o),
        .branch_valid_o(branch_valid_o),
        .branch_pc_o(branch_pc_o),
        .current_pc_o(current_pc_o),
        .opcode_pc_o(opcode_pc_o),
        .opcode_instr_o(opcode_instr_o),
        .load_en_o(load_en_o),
        .fwd_wb_val_o(fwd_wb_val_o),
        .fwd_ex_rd_o(fwd_ex_rd_o)
    );
    
    // Clock generation
    always #5 clk_i = ~clk_i;
    
    // Helper function to set one-hot encoding
    function [25:0] set_one_hot;
        input integer op;
        begin
            set_one_hot = 0;
            set_one_hot[op] = 1;
        end
    endfunction

    // Main test sequence
    initial begin
        // Initialize
        clk_i = 1;
        rst_i = 1;
        opcode_valid_i = 0;
        {opcode_pc_i, opcode_instr_i, one_hot_i} = 0;
        {operand_val_a, operand_val_b, imm_val_i, exec_rd_idx_i} = 0;
        
        // Reset
        #20 rst_i = 0;
        
        $display("Starting IITB-RISC-25 Instruction Test Suite");
        $display("------------------------------------------");
        
        // Test all 26 instructions sequentially with #10 delays
        // Cycle 1: ADA R1, R2, R3
        opcode_valid_i = 1;
        opcode_instr_i = 16'b0000001010001000; // ADA R1, R2, R3
        opcode_pc_i = 16'h0100;
        one_hot_i = set_one_hot(`ADA);
        operand_val_a = 16'hFFFF;
        operand_val_b = 16'h0003;
        exec_rd_idx_i = 3'b001;
        #10;
        
        // Cycle 2: ADC R4, R5, R6 (with C=1)
        opcode_instr_i = 16'b0000010010100010; // ADC R4, R5, R6
        opcode_pc_i = 16'h0102;
        one_hot_i = set_one_hot(`ADC);
        operand_val_a = 16'h0000;
        operand_val_b = 16'h0000;
        exec_rd_idx_i = 3'b100;
        #10;
        
        // Cycle 3: ADZ R7, R0, R1 (with Z=1)
        
        opcode_instr_i = 16'b0000011100000001; // ADZ R7, R0, R1
        opcode_pc_i = 16'h0104;
        one_hot_i = set_one_hot(`ADZ);
        operand_val_a = 16'hFFFF;
        operand_val_b = 16'h0001;
        exec_rd_idx_i = 3'b111;
        #10;
        
        // Cycle 4: AWC R2, R3, R4
        opcode_instr_i = 16'b0000000111000011; // AWC R2, R3, R4
        opcode_pc_i = 16'h0106;
        one_hot_i = set_one_hot(`AWC);
        operand_val_a = 16'hFFFE;
        operand_val_b = 16'h0001;
        exec_rd_idx_i = 3'b010;
        #10;
        
        // Continue with remaining instructions...
        // Cycle 5: ACA R5, R6, R7
        opcode_instr_i = 16'b0000010101110100; // ACA R5, R6, R7
        opcode_pc_i = 16'h0108;
        one_hot_i = set_one_hot(`ACA);
        operand_val_a = 16'h0FF0;
        exec_rd_idx_i = 3'b101;
        #10;
        
        // Cycle 6: ACC R1, R2, R3 (with C=1)
        opcode_instr_i = 16'b0000001010001110; // ACC R1, R2, R3
        opcode_pc_i = 16'h010A;
        one_hot_i = set_one_hot(`ACC);
        operand_val_a = 16'h0002;
        operand_val_b = 16'hFFF3;
        exec_rd_idx_i = 3'b001;
        #10;
        
        // Cycle 7: ACZ R4, R5, R6 (with Z=1)
        opcode_instr_i = 16'b0000010010101101; // ACZ R4, R5, R6
        opcode_pc_i = 16'h010C;
        one_hot_i = set_one_hot(`ACZ);
        operand_val_a = 16'h0005;
        operand_val_b = 16'hff0f;
        exec_rd_idx_i = 3'b100;
        #10;
        
        // Cycle 8: ACW R7, R0, R1
        opcode_instr_i = 16'b0000011100000111; // ACW R7, R0, R1
        opcode_pc_i = 16'h010E;
        one_hot_i = set_one_hot(`ACW);
        operand_val_a = 16'h0001;
        operand_val_b = 16'h0022;
        exec_rd_idx_i = 3'b111;
        #10;
        
        // Cycle 9: ADI R2, R3, #10
        opcode_instr_i = 16'b0001001000111010; // ADI R2, R3, #10
        opcode_pc_i = 16'h0110;
        one_hot_i = set_one_hot(`ADI);
        operand_val_a = 16'h0005;
        imm_val_i = 16'h0003;
        exec_rd_idx_i = 3'b010;
        #10;
        
        // Cycle 10: NDU R5, R6, R7
        opcode_instr_i = 16'b0010010101110000; // NDU R5, R6, R7
        opcode_pc_i = 16'h0112;
        one_hot_i = set_one_hot(`NDU);
        operand_val_a = 16'hFFFF;
        operand_val_b = 16'hFFFF;
        exec_rd_idx_i = 3'b101;
        #10;
        
        // Cycle 11: NDC R1, R2, R3 (with C=1)
        opcode_instr_i = 16'b0010001010001010; // NDC R1, R2, R3
        opcode_pc_i = 16'h0114;
        one_hot_i = set_one_hot(`NDC);
        operand_val_a = 16'h0FFF;
        operand_val_b = 16'hF00F;
        exec_rd_idx_i = 3'b001;
        #10;
        
        // Cycle 12: NDZ R4, R5, R6 (with Z=1)
        
        opcode_instr_i = 16'b0010010010101001; // NDZ R4, R5, R6
        opcode_pc_i = 16'h0116;
        one_hot_i = set_one_hot(`NDZ);
        operand_val_a = 16'h00FF;
        operand_val_b = 16'h000F;
        exec_rd_idx_i = 3'b100;
        #10;
        
        // Cycle 13: NCU R7, R0, R1
        opcode_instr_i = 16'b0010011100001100; // NCU R7, R0, R1
        opcode_pc_i = 16'h0118;
        one_hot_i = set_one_hot(`NCU);
        operand_val_a = 16'hFFFF;
        operand_val_b = 16'hFFFF;
        exec_rd_idx_i = 3'b111;
        #10;
        
        // Cycle 14: NCC R2, R3, R4 (with C=1)
        
        opcode_instr_i = 16'b0010000111001110; // NCC R2, R3, R4
        opcode_pc_i = 16'h011A;
        one_hot_i = set_one_hot(`NCC);
        operand_val_a = 16'h0FFF;
        operand_val_b = 16'h0F0F;
        exec_rd_idx_i = 3'b010;
        #10;
        
        // Cycle 15: NCZ R5, R6, R7 (with Z=1)
        opcode_valid_i = 1;
        opcode_instr_i = 16'b0010010101111101; // NCZ R5, R6, R7
        opcode_pc_i = 16'h011C;
        one_hot_i = set_one_hot(`NCZ);
        operand_val_a = 16'hF0FF;
        operand_val_b = 16'h0F00;
        exec_rd_idx_i = 3'b101;
        #10;
        
        // Cycle 16: LLI R1, #255
        opcode_instr_i = 16'b0011001001111111; // LLI R1, #255
        opcode_pc_i = 16'h011E;
        one_hot_i = set_one_hot(`LLI);
        imm_val_i = 16'h00FF;
        exec_rd_idx_i = 3'b001;
        #10;
        
        // Cycle 17: LW R2, R3, #4
        opcode_instr_i = 16'b0100001000110100; // LW R2, R3, #4
        opcode_pc_i = 16'h0120;
        one_hot_i = set_one_hot(`LW);
        operand_val_b = 16'h1000;
        imm_val_i = 16'h0004;
        exec_rd_idx_i = 3'd5;
        #10;
        
        // Cycle 18: SW R4, R5, #8
        opcode_instr_i = 16'b0101010010101000; // SW R4, R5, #8
        opcode_pc_i = 16'h0122;
        one_hot_i = set_one_hot(`SW);
        operand_val_a = 16'h5055;
        operand_val_b = 16'h0200;
        imm_val_i = 16'h0008;
        #10;
        
        // Cycle 19: LM R6, #0b00000001 (load R0)
        opcode_instr_i = 16'b0110011000000001; // LM R6, #0b00000001
        opcode_pc_i = 16'h0124;
        one_hot_i = set_one_hot(`LM);
        operand_val_b = 16'h2000;
        exec_rd_idx_i = 3'd7;
        #10;
        
        opcode_instr_i = 16'b0110011000000001; // LM R6, #0b00000001
        opcode_pc_i = 16'h0124;
        one_hot_i = set_one_hot(`LM);
        operand_val_b = 16'h2000;
        exec_rd_idx_i = 3'd6;
        #10;
        
        opcode_instr_i = 16'b0110011000000001; // LM R6, #0b00000001
        opcode_pc_i = 16'h0124;
        one_hot_i = set_one_hot(`LM);
        operand_val_b = 16'h2000;
        exec_rd_idx_i = 3'd2;
        #10;
        
        // Cycle 20: SM R7, #0b00000010 (store R1)
        opcode_instr_i = 16'b0111011100000010; // SM R7, #0b00000010
        opcode_pc_i = 16'h0126;
        one_hot_i = set_one_hot(`SM);
        operand_val_b = 16'h4000;
        operand_val_a = 16'h0234;
        #10;
        
        opcode_instr_i = 16'b0111011100000010; // SM R7, #0b00000010
        opcode_pc_i = 16'h0126;
        one_hot_i = set_one_hot(`SM);
        operand_val_b = 16'h4000;
        operand_val_a = 16'h1034;
        #10;
        
        opcode_instr_i = 16'b0111011100000010; // SM R7, #0b00000010
        opcode_pc_i = 16'h0126;
        one_hot_i = set_one_hot(`SM);
        operand_val_b = 16'h4000;
        operand_val_a = 16'h1204;
        #10;
        
        opcode_instr_i = 16'b0111011100000010; // SM R7, #0b00000010
        opcode_pc_i = 16'h0126;
        one_hot_i = set_one_hot(`SM);
        operand_val_b = 16'h4000;
        operand_val_a = 16'h1230;
        #10;
        
        // Cycle 21: BEQ R1, R2, #8 (taken)
        opcode_instr_i = 16'b1000001001001000; // BEQ R1, R2, #8
        opcode_pc_i = 16'h0128;
        one_hot_i = set_one_hot(`BEQ);
        operand_val_a = 16'h0989;
        operand_val_b = 16'h0989;
        imm_val_i = 16'h0020;
        #10;
        
        // Cycle 22: BLT R3, R4, #-4 (taken)
        opcode_instr_i = 16'b1001001111001100; // BLT R3, R4, #-4
        opcode_pc_i = 16'h0130;
        one_hot_i = set_one_hot(`BLT);
        operand_val_a = 16'h8000; // -32768
        operand_val_b = 16'h0001; // 1
        imm_val_i = 16'h0004; // +4
        #10;
        
        // Cycle 23: BLE R5, R6, #16 (not taken)
        opcode_instr_i = 16'b1010010101100000; // BLE R5, R6, #16
        opcode_pc_i = 16'h0134;
        one_hot_i = set_one_hot(`BLE);
        operand_val_a = 16'h0002;
        operand_val_b = 16'hFFFC;
        imm_val_i = 16'h0010; //+10
        #10;
        
        // Cycle 24: JAL R7, #32
        opcode_instr_i = 16'b1011011100100000; // JAL R7, #32
        opcode_pc_i = 16'h0138;
        one_hot_i = set_one_hot(`JAL);
        imm_val_i = 16'h0020;
        exec_rd_idx_i = 3'b111;
        #10;
        
        // Cycle 25: JLR R1, R2
        opcode_instr_i = 16'b1100001001000000; // JLR R1, R2
        opcode_pc_i = 16'h0140;
        one_hot_i = set_one_hot(`JLR);
        operand_val_b = 16'hABCD;
        exec_rd_idx_i = 3'b001;
        #10;
        
        // Cycle 26: JRI R3, #64
        opcode_instr_i = 16'b1101001111000000; // JRI R3, #64
        opcode_pc_i = 16'h0142;
        one_hot_i = set_one_hot(`JRI);
        operand_val_a = 16'h1000;
        imm_val_i = 16'h0040;
        #10;
        
        opcode_instr_i = 16'b0100001000110100; // LW R2, R3, #4
        opcode_pc_i = 16'h0144;
        one_hot_i = set_one_hot(`LW);
        operand_val_b = 16'h1700;
        imm_val_i = 16'h0010;
        exec_rd_idx_i = 3'd2;
        #10;
        
        // Final report
        #10;
        $display("All 26 instructions tested sequentially");
        $finish;
    end

    // Monitor results
    always @(posedge clk_i) begin
        if (opcode_valid_i) begin
            $display("[%0t] PC=%h Instr=%h A=%h B=%h ? Result=%h Branch=%b Target=%h",
                $time, opcode_pc_i, opcode_instr_i, 
                operand_val_a, operand_val_b,
                exec_wb_val_o, branch_valid_o, branch_pc_o, current_pc_o, opcode_instr_o);
        end
    end
endmodule