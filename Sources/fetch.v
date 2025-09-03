module fetch (
  input wire clk_i,
  input wire rst_i,
  
  // icache
  input wire        icache_valid_i,
  input wire [15:0] icache_instr_i,
  output wire       icache_rd_o,
  output reg [15:0] icache_pc_o,
  
  // pipeline deal
  input  wire       fetch_valid_i,//receive from decoder
  output reg        instr_valid_o, //send to decoder
  output reg [15:0] fetch_pc_o, // ''
  output reg [15:0] fetch_instr_o, // ''
  
  // branch history table receive from branch execution
  input wire        branch_valid_i,
  input wire        branch_type_i,
  input wire [15:0] fetch_branch_pc_i,
  input wire [15:0] opcode_pc_i
);
  
  reg [15:0] pc_r;
  reg [15:0] instr_r, instr_valid_r;
  reg predictor_true_q, match_branch_q, match_already_q, icache_rd;
  reg [15:0] predictor_pc_q;
  wire [15:0] instr_w, pc_w, instr_q;
  wire instr_valid_w;
  
  reg [15:0] pc_table [0:7];      // live PC
  reg [15:0] target_table [0:7];  // target PC
  reg [1:0]  predictor_table [0:7];
  reg [2:0]  match_idx;
  reg [7:0]  valid_table;
  
  assign icache_rd_o = fetch_valid_i & icache_rd;
  assign instr_q = icache_instr_i;
  
  
  always @(*) begin
      instr_r = fetch_instr_o;
      pc_r    = 0;
      instr_valid_r  =  icache_valid_i;  // normal cases
      if (fetch_valid_i && icache_valid_i) begin
          if (predictor_true_q && match_branch_q) //match and branch pred only then
            pc_r = predictor_pc_q;
          else if (branch_valid_i && !match_already_q) // no record found and branch has to be taken
            pc_r = fetch_branch_pc_i;
          else if (!branch_valid_i && match_already_q && branch_type_i) // when Branch NOT TAKEN, 
            pc_r = opcode_pc_i + 16'd1;                                  // but had a record of taking
          else 
            pc_r = fetch_pc_o + 16'd1; // normal pc cunt
        if (!rst_i) begin icache_pc_o = (pc_r << 1); //send two byte addr to mem
                          instr_r = instr_q;
                          icache_rd = 1'b1;
                    end
        else    icache_rd = 1'b0;
        end
      else begin
        instr_r = fetch_instr_o;
        pc_r    = fetch_pc_o;
      end    
end
// SEquential pipeline psuh
    always @(posedge clk_i) begin
    if (rst_i) begin
      fetch_pc_o     <= 16'd0;
      fetch_instr_o  <= 16'd0;
      instr_valid_o  <= 1'b0;
      icache_pc_o    <= 16'd0;
    end 
    else begin
      fetch_instr_o <= instr_w;
      fetch_pc_o    <= pc_w ;
      instr_valid_o <= instr_valid_w;
      end
    end
    
assign instr_w = instr_r; // auxilary wires
assign pc_w = pc_r;
assign instr_valid_w = instr_valid_r;

  // BHT mux out logic deal
    always @(*) begin
    match_branch_q = 1'b0;
    match_idx = 3'd0; //find if any match record of the live branch pc
    match_already_q = pc_table [0] == opcode_pc_i ? 1 :
                      pc_table [1] == opcode_pc_i ? 1 :
                      pc_table [2] == opcode_pc_i ? 1 :
                      pc_table [3] == opcode_pc_i ? 1 :
                      pc_table [4] == opcode_pc_i ? 1 :
                      pc_table [5] == opcode_pc_i ? 1 :
                      pc_table [6] == opcode_pc_i ? 1 :
                      pc_table [7] == opcode_pc_i ? 1 : 0;
    
    // match for the first time in the records 
    if (valid_table[0] && pc_table[0] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd0;
    end else if (valid_table[1] && pc_table[1] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd1;
    end else if (valid_table[2] && pc_table[2] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd2;
    end else if (valid_table[3] && pc_table[3] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd3;
    end else if (valid_table[4] && pc_table[4] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd4;
    end else if (valid_table[5] && pc_table[5] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd5;
    end else if (valid_table[6] && pc_table[6] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd6;
    end else if (valid_table[7] && pc_table[7] == fetch_pc_o) begin
      match_branch_q = 1'b1;
      match_idx = 3'd7;
    end 
    // find the predictor value if >2
    if (match_branch_q && predictor_table[match_idx] >= 2'b10) begin
        predictor_true_q = 1'b1;
        predictor_pc_q = target_table[match_idx];
    end
    if (match_branch_q && predictor_table[match_idx] <= 2'b01) begin
        predictor_true_q = 1'b0;
    end
  end
  
reg        update_match_q;
reg  [2:0] update_match_idx;

// MAKE ENTRY TO THE BHT if new record comes
always @(*) begin
  update_match_q   = 1'b0;
  update_match_idx = 3'd0;

  if (valid_table[0] && pc_table[0] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd0;
  end else if (valid_table[1] && pc_table[1] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd1;
  end else if (valid_table[2] && pc_table[2] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd2;
  end else if (valid_table[3] && pc_table[3] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd3;
  end else if (valid_table[4] && pc_table[4] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd4;
  end else if (valid_table[5] && pc_table[5] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd5;
  end else if (valid_table[6] && pc_table[6] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd6;
  end else if (valid_table[7] && pc_table[7] == opcode_pc_i) begin
    update_match_q = 1'b1; update_match_idx = 3'd7;
  end
end  

  reg [2:0] fifo_ptr;
//fifo for replacement policy if we have more than 8 branch record
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      fifo_ptr <= 3'd0;
      pc_table[0] <= 16'd0; target_table[0] <= 16'd0; predictor_table[0] <= 2'b01; valid_table[0] <= 1'b0;
      pc_table[1] <= 16'd0; target_table[1] <= 16'd0; predictor_table[1] <= 2'b01; valid_table[1] <= 1'b0;
      pc_table[2] <= 16'd0; target_table[2] <= 16'd0; predictor_table[2] <= 2'b01; valid_table[2] <= 1'b0;
      pc_table[3] <= 16'd0; target_table[3] <= 16'd0; predictor_table[3] <= 2'b01; valid_table[3] <= 1'b0;
      pc_table[4] <= 16'd0; target_table[4] <= 16'd0; predictor_table[4] <= 2'b01; valid_table[4] <= 1'b0;
      pc_table[5] <= 16'd0; target_table[5] <= 16'd0; predictor_table[5] <= 2'b01; valid_table[5] <= 1'b0;
      pc_table[6] <= 16'd0; target_table[6] <= 16'd0; predictor_table[6] <= 2'b01; valid_table[6] <= 1'b0;
      pc_table[7] <= 16'd0; target_table[7] <= 16'd0; predictor_table[7] <= 2'b01; valid_table[7] <= 1'b0;
    end else begin
    predictor_true_q <= 1'b0;
    predictor_pc_q   <= 16'd0;
    
// actual predictor logic here
    if (branch_valid_i) begin
     if (update_match_q) begin
        target_table[update_match_idx] <= fetch_branch_pc_i;
        if (fetch_branch_pc_i == target_table[update_match_idx]) begin
            predictor_table[update_match_idx] <= 
                (predictor_table[update_match_idx] == 2'b11) ? 2'b11 :
                predictor_table[update_match_idx] + 1;
        end 
        else begin
            predictor_table[update_match_idx] <= 
                (predictor_table[update_match_idx] == 2'b00) ? 2'b00 :
                predictor_table[update_match_idx] - 1;
        end
       end 
       else begin
        // insert new entry
        pc_table[fifo_ptr]        <= opcode_pc_i;
        target_table[fifo_ptr]    <= fetch_branch_pc_i;
        predictor_table[fifo_ptr] <= 2'b10;
        valid_table[fifo_ptr]     <= 1'b1;
        fifo_ptr <= fifo_ptr + 1;
       end
    end 
    else if (!branch_valid_i && update_match_q && branch_type_i) begin
    predictor_table[update_match_idx] <= 
        (predictor_table[update_match_idx] == 2'b00) ? 2'b00 :
        predictor_table[update_match_idx] - 1;
    end
  end
end
endmodule