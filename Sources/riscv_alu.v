`include "def_ex.v"
module riscv_alu(
    input [1:0] alu_op_i,
    input [15:0] alu_a_i,
    input [15:0] alu_b_i,
    input alu_cin_i,
    output reg alu_cout_o,
    output reg [15:0] alu_p_o,
    output reg [15:0] compare_o
    );

    wire [15:0] ADD_result; 
    wire [15:0] SUB_result; 
    wire [15:0] NAND_result;
    wire carry_out; 
    
   bkadder u_add(
    .a(alu_a_i),
    .b(alu_b_i),
    .cin(alu_cin_i),
    .s(ADD_result),
    .cout(carry_out));
    
    bkadder u_sub(
    .a(alu_a_i),
    .b(~alu_b_i),
    .cin(1'b1),
    .s(SUB_result),
    .cout());
    
    bitwise_nand u_bitnand(
        .a(alu_a_i),
        .b(alu_b_i),
        .y(NAND_result)
    );

    // ALU output selection using continuous assignments
    always @(*) begin
        case(alu_op_i)
            `NONE: alu_p_o = alu_p_o;
            `ADD: begin 
                alu_p_o = ADD_result; 
                alu_cout_o = carry_out; 
                end
            `SUB: begin
                alu_p_o = alu_p_o;
                compare_o = SUB_result;
                end
            `NAND: begin alu_p_o = NAND_result; end
            default: alu_p_o = 16'b0;
         endcase
    end
endmodule