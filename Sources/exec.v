`include "def_ex.v"


module exec(
  input wire clk_i,
  input wire rst_i,
  
  // signals from deocder thru rr
  input wire        opcode_valid_i,
  input wire [15:0] opcode_pc_i,
  input wire [15:0] opcode_instr_i,
  input wire [25:0] one_hot_i,
  // operands from rr
  input wire [15:0] operand_val_a, 
  input wire [15:0] operand_val_b,
  
  input wire [2:0]  exec_rd_idx_i,
  input wire [15:0] imm_val_i,
  output reg  [15:0] opcode_pc_o,
  output reg  [15:0] opcode_instr_o,
  // to mem / rr if forward
  output reg [15:0] exec_wb_val_o,
  output reg [2:0]  memu_rd_idx_o,
  output reg [15:0] lsu_base_addr_o,
  
  // branch to BHT (IF) or FLUSH (RR)
  output wire        branch_valid_o,
  output wire        branch_type_o,
  output wire [15:0] branch_pc_o,
  output wire [15:0] current_pc_o,
  
  
  // stall or forward
  //output reg exec_stall_o,
  input  wire       load_pending_i,
  output wire [15:0] fwd_ex_val_o,
  output wire [2:0] fwd_ex_rd_o,
  output wire       load_en_o);
  
  // internal reg and wires
  reg [1:0] alu_func_r, flag_cz_r;
  reg  alu_input_cin_r, branch_req_r, c_r, z_r, stall_r, load_en_r, branch_type_r;
  reg [15:0] alu_input_a_r, alu_input_b_r, rdx_r, store_val_r;
  reg [15:0] bk_a_r, bk_b_r, branch_pc_r, ls_addr_r, pc_r, instr_r;
  reg [25:0] one_hot_r;
  reg [2:0] load_rd_r;
  
  wire [15:0] alu_p_w, instr_w;
  wire alu_cout_w, stall_w;
  wire [15:0] bk_s_w, lsu_addr_w, branch_p_w, rdx_w, pc_w, lsu_base_addr_w;
  wire over_w, c_w, z_w, brq_w;
  wire [25:0] one_hot_w;
  
  
  // BASIC USE OF WIRES FOR PIPELINE PUSH ARCH
  assign stall_w = stall_r;
  assign pc_w = pc_r;
  assign lsu_addr_w = ls_addr_r;
  assign c_w = c_r;
  assign z_w = z_r;
  assign brq_w = branch_req_r;
  assign rdx_w = rdx_r;
  assign over_w = (operand_val_a[15] != operand_val_b[15]) 
                    & (operand_val_a[15] != branch_p_w[15]);
  assign one_hot_w = one_hot_r;
  assign instr_w = instr_r;
  
  
  // ALL THE CASES INSIDE COMBINATIONAL BLOCKS
  always @(*) begin
    load_en_r = 0;
    alu_input_cin_r = 1'b0;
    branch_req_r = 1'b0;
    branch_pc_r = 0;
    {c_r,z_r} = 2'd0;
    {bk_a_r, bk_b_r} = 0;
    branch_type_r = (opcode_instr_i[15:12] == 4'b1000 || opcode_instr_i[15:12] == 4'b1001
                    || opcode_instr_i[15:12] == 4'b1010) ? 1 : 0 ; 
  if (opcode_valid_i) begin
    alu_func_r = `NONE;
    alu_input_a_r = operand_val_a;
    alu_input_b_r = operand_val_b;
    instr_r = opcode_instr_i;
    pc_r = opcode_pc_i;
    rdx_r = exec_rd_idx_i;
    branch_type_r = 0;
    store_val_r  = (one_hot_i[`SW] || one_hot_i[`SM]) ? operand_val_a : store_val_r;
    case (opcode_instr_i[15:12]) 
    
    
        4'b0000: begin //R types
        c_r = 0; z_r = 0;   
        if (one_hot_i[`ADA]) begin//1
            alu_func_r = `ADD;
            c_r = alu_cout_w;
            z_r = !(|alu_p_w);
            end
        else if (one_hot_i[`ADC]) begin //2
            alu_func_r = flag_cz_r[1] ? `ADD : `NONE;
            c_r = flag_cz_r[1] ? alu_cout_w : flag_cz_r[1];
            z_r = flag_cz_r[1] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`ADZ]) begin //2
            alu_func_r = flag_cz_r[0] ? `ADD : `NONE;
            c_r = flag_cz_r[0] ? alu_cout_w : flag_cz_r[1];
            z_r = flag_cz_r[0] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`AWC]) begin//2
            alu_func_r = `ADD;
            alu_input_cin_r = flag_cz_r[1];
            c_r = alu_cout_w;
            z_r = !(|alu_p_w);
            end
        else if (one_hot_i[`ACA]) begin //2
            alu_func_r = `ADD;
            alu_input_b_r = ~ operand_val_b;
            c_r = alu_cout_w;
            z_r = !(|alu_p_w);
            end
        else if (one_hot_i[`ACC]) begin //2
            alu_func_r = flag_cz_r[1] ? `ADD : `NONE;
            alu_input_b_r = ~ operand_val_b;
            c_r = flag_cz_r[1] ? alu_cout_w : flag_cz_r[1];
            z_r = flag_cz_r[1] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`ACZ]) begin //2
            alu_func_r = flag_cz_r[0] ? `ADD : `NONE;
            alu_input_b_r = ~ operand_val_b;
            c_r = flag_cz_r[0] ? alu_cout_w : flag_cz_r[1];
            z_r = flag_cz_r[0] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`ACW]) begin //2
            alu_func_r = `ADD;
            alu_input_b_r = ~ operand_val_b;
            alu_input_cin_r = flag_cz_r[1];
            c_r = alu_cout_w;
            z_r = !(|alu_p_w);
            end
      end
      
      4'b0010: begin
        if (one_hot_i[`NDU]) begin //2
            alu_func_r = `NAND;
            z_r = !(|alu_p_w);
            end
        else if (one_hot_i[`NDC]) begin //2
            alu_func_r = flag_cz_r[1] ? `NAND : `NONE;
            z_r = flag_cz_r[1] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`NDZ]) begin //2  
            alu_func_r = flag_cz_r[0] ? `NAND : `NONE;
            z_r = flag_cz_r[0] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`NCU]) begin //2
            alu_func_r = `NAND;
            alu_input_b_r = ~ operand_val_b;
            end
        else if (one_hot_i[`NCC]) begin //2
            alu_func_r = flag_cz_r[1] ? `NAND : `NONE;
            alu_input_b_r = ~ operand_val_b;
            z_r = flag_cz_r[1] ? !(|alu_p_w) : flag_cz_r[0];
            end
        else if (one_hot_i[`NCZ]) begin //2  
            alu_func_r = flag_cz_r[0] ? `NAND : `NONE;
            alu_input_b_r = ~ operand_val_b;
            z_r = flag_cz_r[0] ? !(|alu_p_w) : flag_cz_r[0];
            end          
        end
        
        4'b0100, 4'b0101, 4'b0110, 4'b0111: begin //Loads types
            if (one_hot_i[`LW]) begin
            bk_a_r = operand_val_b;
            bk_b_r = imm_val_i;
            ls_addr_r = bk_s_w;
            load_en_r = 1;
            end
            if (one_hot_i[`SW]) begin
            bk_a_r = operand_val_b;
            bk_b_r = imm_val_i;
            ls_addr_r = bk_s_w;
            load_en_r = 1;
            end
            if (one_hot_i[`LM]) begin
            ls_addr_r = operand_val_b;
            end
            if (one_hot_i[`SM]) begin
            ls_addr_r = operand_val_b;
            end
        end
        
        4'b0001: begin //ADI
            if (one_hot_i[`ADI]) begin //2
            alu_func_r = `ADD;
            alu_input_b_r = imm_val_i;
            c_r = alu_cout_w;
            z_r = !(|alu_p_w);
            end
        end
        4'b0011: begin //LLI
            if (one_hot_i[`LLI]) begin //2
            alu_func_r = `ADD;
            alu_input_a_r = imm_val_i;
            alu_input_b_r = 16'd0;
            end  
        end
        4'b1000, 4'b1010, 4'b1001: begin //bracnesh
            bk_a_r = opcode_pc_i;
            bk_b_r = imm_val_i;
            branch_pc_r = bk_s_w;
            branch_req_r = 1'b0;
            
            
            
//              // UNSGINED COMPARISONS            
//            if (one_hot_i[`BEQ]) begin //2
//            alu_func_r = `SUB;
//            branch_req_r = !(|alu_p_w);
//            end  
//            if (one_hot_i[`BLT]) begin //2
//            alu_func_r = `SUB;
//            branch_req_r = alu_p_w[15];
//            end 
//            if (one_hot_i[`BLE]) begin //2
//            alu_func_r = `SUB;
//            branch_req_r = alu_p_w[15] | !(|alu_p_w);
//            end

//          //SIGNED COMPARISON : COULD have been done by operators, but for the sake of ALU
            if (one_hot_i[`BEQ]) begin //2
            alu_func_r = `SUB;
            branch_req_r = !(|branch_p_w);
            end  
            if (one_hot_i[`BLT]) begin //2
            alu_func_r = `SUB; //check overflow and sign bit
            branch_req_r = over_w ^ branch_p_w[15];
            end 
            if (one_hot_i[`BLE]) begin //2
            alu_func_r = `SUB;
            branch_req_r = (over_w ^ branch_p_w[15]) | !(|branch_p_w);
            end  
        end
        
        4'b1011, 4'b1100, 4'b1101: begin //JLS
            bk_a_r = opcode_pc_i;
            bk_b_r = imm_val_i;
            branch_pc_r = bk_s_w;
            branch_req_r = 1'b1;
            
            if (one_hot_i[`JAL]) begin //2
            alu_func_r = `ADD;
            alu_input_a_r = opcode_pc_i;
            alu_input_b_r = 16'd1;
            end  
            if (one_hot_i[`JLR]) begin //2
            alu_func_r = `ADD;
            alu_input_a_r = opcode_pc_i;
            alu_input_b_r = 16'd1;
            branch_pc_r = operand_val_b;
            end 
            if (one_hot_i[`JRI]) begin //2
            bk_a_r = operand_val_a;
            bk_b_r = imm_val_i;
            branch_pc_r = bk_s_w;
            end  
        end
        default: begin
            alu_func_r = `NONE;
            branch_req_r = 1'b0;
        end 
    endcase
    end 
    else begin
        alu_func_r = `NONE;
        branch_req_r = 1'b0;
    end
    stall_r = 0; 
  end
  
  //comb instances  
    bkadder u_bk(
    .a(bk_a_r),
    .b(bk_b_r),
    .cin(1'b0),
    .s(bk_s_w),
    .cout());
    
     riscv_alu u_alu(
    .alu_op_i(alu_func_r),
    .alu_a_i(alu_input_a_r),
    .alu_b_i(alu_input_b_r),
    .alu_cin_i(alu_input_cin_r),
    .alu_cout_o(alu_cout_w),
    .alu_p_o(alu_p_w),
    .compare_o(branch_p_w));
    
  // SEQuential PIPELINE PUSH
  always @(posedge clk_i) begin
    if(rst_i) begin
        opcode_instr_o <= 0;
        flag_cz_r <= 2'd0;
        exec_wb_val_o <= 16'd0;
        memu_rd_idx_o <= 3'd0;
        opcode_pc_o <= 16'd0;
        //exec_stall_o <= 1'b0;
        lsu_base_addr_o <= 0;
        store_val_r <= 0;
        pc_r <= 0;
    end
    else begin
        opcode_instr_o <= instr_w;
        flag_cz_r <= {c_w,z_w};
        one_hot_r <= one_hot_i;
    //  load_rd_r     <= (one_hot_i[`LW] || one_hot_i[`LM]) ? exec_rd_idx_i : load_rd_r;
        
        exec_wb_val_o <= fwd_ex_val_o;
        memu_rd_idx_o <= fwd_ex_rd_o;
        opcode_pc_o <= pc_w;
        //exec_stall_o <= 1'b0; //no corner case for execute to stall
        //exec_stall_o <= stall_w;
        lsu_base_addr_o <= lsu_base_addr_w;
    end
  end
  
  
  // Branch FLUSH and Branch Hist table
  assign branch_valid_o = brq_w;
  assign branch_pc_o = branch_pc_r;
  assign current_pc_o = pc_w;
  
  // LSU address modification
  assign lsu_base_addr_w = ((one_hot_w[`LM] || one_hot_w[`SM])
                           & (current_pc_o == opcode_pc_o)) ?
                           lsu_base_addr_o + 2'd1 : lsu_addr_w;
  
  // STRAIGHT COMPARABLE FORWARD LOGIC WIRES and Store adjustments
  // no mod in ex val out on NONE alu ops and BEQ Comparisons
  assign fwd_ex_val_o =  (one_hot_i[`SW] || one_hot_i[`SM]) ? operand_val_a : 
                         (alu_func_r == `NONE || alu_func_r == `SUB) ?  
                          exec_wb_val_o : alu_p_w;
                          
  assign fwd_ex_rd_o  =  exec_rd_idx_i;
//  // (one_hot_w[`LW] || one_hot_w[`LM]) ? 
//                         (alu_func_r == `NONE | alu_func_r == `SUB) ?  
//                          memu_rd_idx_o : rdx_w; 
  assign load_en_o    =   load_en_r | load_pending_i;    
  assign branch_type_o = (opcode_instr_i[15:12] == 4'b1000 || opcode_instr_i[15:12] == 4'b1001
                    || opcode_instr_i[15:12] == 4'b1010) ? 1 : 0 ;                   
  endmodule








