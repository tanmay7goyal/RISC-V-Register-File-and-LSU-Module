
module regread( 
  input wire clk_i,
  input wire rst_i,

  // from decoder
  input wire        opcode_valid_i,
  input wire [15:0] opcode_pc_i,
  input wire [15:0] opcode_instr_i,
  
  input wire [25:0] one_hot_i,
  input wire [2:0]  dec_rd_idx_i, dec_ra_idx_i, dec_rb_idx_i,
  input wire [15:0] imm_val_i,
  input wire        branch_valid_i,
  input wire [15:0] branch_pc_i,
  
  // to execute
  output reg        opcode_valid_o,
  output reg [15:0] opcode_pc_o,
  output reg [15:0] opcode_instr_o,
  output reg [25:0] one_hot_o, 
  output reg [15:0] operand_val_a, 
  output reg [15:0] operand_val_b,
  output reg [2:0]  exec_rd_idx_o,
  output reg [15:0] imm_val_o,
  
  // for writeback stage
  input wire [15:0] ex_val_i,
  input wire [2:0]  ex_rd_idx_i,
  input wire        load_en_i,
  input wire [15:0] mem_val_i,
  input wire [2:0]  mem_rd_idx_i,
  
  input wire [15:0] wb_val_i,
  input wire [2:0]  wb_rd_idx_i,
  input wire        branch_type_i,
  
  output wire       mem_stall_o
);

// Internal Register File (8 registers, 16-bit each)
reg [15:0] gpr [7:0]; // General Purpose Registers
integer i;
reg valid_r, count_r, bv_rrq, bv_rr = 0, stall_r = 0, stall_rq;
wire valid_w;

//BRANCH FLUSH LOGIC, IF RR current pc != calculated branch_pc from EXEC, 
// then send opcode invalid, 
//if no branch taken, then pipeline valid signal from DECODE
always @(*) begin
gpr[0] = opcode_pc_i;
bv_rr = branch_valid_i;

//TAKEN 
if (branch_valid_i) begin
    if(branch_pc_i == gpr[0]) begin //if current PC matches with Incoming branch, go ahead
        bv_rr = 0;
        valid_r = 1; end
    else begin
        bv_rr = 1;
        valid_r = 0; end //otherwise the pushed to EXEC instr will be invalid (flushed)
    end
else if (bv_rrq) //holds the branch valid signal until branch PC is not matched with Coming PC
    if(branch_pc_i == gpr[0]) begin
        bv_rr = 0;
        valid_r = 1; end
    else begin
        bv_rr = 1;
        valid_r = 0;  end
        
// NOT TAKEN LOGIC AFTER TAKEN / MISPREDICTION
else if (!branch_valid_i && branch_type_i)
    if(opcode_pc_i != opcode_pc_o + 16'b1) begin
        bv_rr = 1;
        valid_r = 0; end
    else begin
        bv_rr = 0;
        valid_r = 1; end
else begin
valid_r = opcode_valid_i; 
bv_rr = 0; end 
end


reg [15:0] opcode_instr_r, imm_val_r; 
reg [15:0] operand_val_a_r,operand_val_b_r, wb_val_r;
reg [25:0] one_hot_r ;
reg [2:0]  exec_rd_idx_r, wb_rd_idx_r;

wire [15:0] opcode_pc_w, opcode_instr_w, imm_val_w, wb_val_w;
wire [15:0] operand_val_a_w, operand_val_b_w;
wire [25:0] one_hot_w ;
wire [2:0]  exec_rd_idx_w, wb_rd_idx_w;


//BUFFER 
always @(*) begin
    opcode_instr_r = opcode_instr_i;
    one_hot_r = one_hot_i;
    imm_val_r = imm_val_i;
    exec_rd_idx_r = dec_rd_idx_i;
    wb_val_r = wb_val_i;
    wb_rd_idx_r = wb_rd_idx_i;
    //COMB hazard handling muxes, priority wise
    operand_val_b_r =  (ex_rd_idx_i == dec_rb_idx_i && //only if match, and invalid load at EXEC
                        load_en_i == 1'b0 && // and EXEC is invalid
                        opcode_valid_o == 1) ? ex_val_i :
                       (mem_rd_idx_i == dec_rb_idx_i) ? mem_val_i :
                       (wb_rd_idx_i == dec_rb_idx_i) ? wb_val_i :
                       gpr[dec_rb_idx_i];
    operand_val_a_r =  (ex_rd_idx_i == dec_ra_idx_i && //only if match, and invalid load at EXEC
                        load_en_i == 1'b0 &&  // and EXEC is invalid
                        opcode_valid_o == 1) ? ex_val_i : 
                       (mem_rd_idx_i == dec_ra_idx_i) ? mem_val_i :
                       (wb_rd_idx_i == dec_ra_idx_i) ? wb_val_i :
                       gpr[dec_ra_idx_i];
                       
     // if Exec has LW, then it will stop current instruction we have Load dependency                  
    if(load_en_i) 
        if ( (opcode_instr_i[15:12] == 4'b0000 || opcode_instr_i[15:12] == 4'b0010 ||
              opcode_instr_i[15:12] == 4'b0001 || opcode_instr_i[15:12] == 4'b1000 ||
              opcode_instr_i[15:12] == 4'b1001 || opcode_instr_i[15:12] == 4'b1010 ||
              opcode_instr_i[15:12] == 4'b1100 || opcode_instr_i[15:12] == 4'b1101) && 
              ((exec_rd_idx_o == dec_ra_idx_i) || (exec_rd_idx_o == dec_rb_idx_i)) ) begin
            stall_r = 1; end
        else begin
            stall_r = 0; end
    else begin
            stall_r = 0; end
end

// TO PIPELINE
assign valid_w = valid_r;
assign opcode_pc_w = gpr[0];
assign opcode_instr_w = opcode_instr_r;
assign one_hot_w = one_hot_r;
assign imm_val_w = imm_val_r;
assign exec_rd_idx_w = exec_rd_idx_r;
assign operand_val_a_w = operand_val_a_r;
assign operand_val_b_w = operand_val_b_r;
assign wb_val_w = wb_val_r;
assign wb_rd_idx_w = wb_rd_idx_r;

// Sequential Push
always @(posedge clk_i) begin
  if (rst_i) begin
    // Reset all outputs and GPR
    opcode_valid_o <= 1'b0;
    opcode_pc_o    <= 16'b0;
    opcode_instr_o <= 16'b0;
    one_hot_o      <= 26'b0;
    operand_val_a  <= 16'b0;
    operand_val_b  <= 16'b0;
    exec_rd_idx_o  <= 3'b0;
    valid_r <= 0;
    bv_rrq <= 0;
    // Reset GPRs (optional, safe initialization)
    for (i = 0; i < 8; i = i + 1)
      gpr[i] <= 16'b0;
  end
  else begin
   stall_rq <= 0;
   if (opcode_valid_i) begin
    bv_rrq <= (branch_valid_i) || (!branch_valid_i && branch_type_i) ? bv_rr : 0; //stores a valid register to compare PC until match arrives
   if(!mem_stall_o) begin // when mem is stalled it will send the Load instr 2 times, 1 time valid,
   // following time invalid, making it look like flushed or stalled (either works)
      opcode_valid_o <= valid_w;
      opcode_pc_o    <= opcode_pc_w;
      opcode_instr_o <= opcode_instr_w;
      one_hot_o      <= one_hot_w;
      imm_val_o      <= imm_val_w;
      exec_rd_idx_o  <= exec_rd_idx_w;
      
      //writeback happens to REG FILE
      if (wb_rd_idx_w !=0) gpr[wb_rd_idx_w] <= wb_val_w; //write protected r0
      
      //HANDLED HAZARD TO PIPELINE PUSH
      operand_val_a <= operand_val_a_w;
      operand_val_b <= operand_val_b_w;
    end
  else opcode_valid_o <= 0;
     end
    else begin
     opcode_valid_o <= 1'b0; 
    end
  end
end
//direct stall signal to decode, and that gets to fetch to stop fetchin
assign mem_stall_o = stall_r;

endmodule
