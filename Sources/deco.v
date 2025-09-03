`timescale 1ns/1ps
`include "def_iitb25.v"

module decoder(
  input wire        clk_i,
  input wire        rst_i,
  input wire        instr_valid_i,
  input wire [15:0] fetch_pc_i,
  input wire [15:0] fetch_instr_i,
  //output reg        fetch_valid_o,
  output wire fetch_valid_w,
  output reg        opcode_valid_o,
  output reg [15:0] opcode_pc_o,
  output reg [15:0] opcode_instr_o,
  output reg [25:0] one_hot_o,
  output reg [2:0]  rd_idx_o, ra_idx_o, rb_idx_o,
  output reg [15:0] imm_val_o,

  //input wire        exec_stall_i,
  input wire        mem_stall_i
);

  reg [15:0] imm_val;
  reg [15:0] opcode_pc_r, opcode_instr_r;
  reg [25:0] one_hot_r;
  reg [2:0] rd_idx_r, ra_idx_r, rb_idx_r;
  reg [3:0] state;
  reg valid_r;
  wire [3:0] opcode = fetch_instr_i[15:12];
  wire [2:0] CCZ    = fetch_instr_i[2:0];
  reg        fetch_valid_o, opcode_valid_r;
  parameter IDLE = 4'd15, SINGLE = 4'd10, MS7 = 4'd7, MS6 = 4'd6,
            MS5 = 4'd5, MS4 = 4'd4, MS3 = 4'd3, MS2 = 4'd2,
            MS1 = 4'd1, MS0 = 4'd0;

  // Immediate Extraction
  always @(*) begin
    case (opcode)
      4'b0100, 4'b0101: //ADI LW SW
        imm_val = {{10{fetch_instr_i[5]}}, fetch_instr_i[5:0]};
      4'b0001, 4'b1000, 4'b1001, 4'b1010, 4'b1100: // BEQ BLE BLT JLR
         imm_val = ({{10{fetch_instr_i[5]}}, fetch_instr_i[5:0]});
      4'b1011, 4'b1101: //JAL JRI
        imm_val = ({7'b0, fetch_instr_i[8:0]});
      4'b0011: //LLI
        imm_val = {7'b0, fetch_instr_i[8:0]};
      4'b0110, 4'b0111: //LM SM
        imm_val = {8'b0, fetch_instr_i[7:0]};
      default:
        imm_val = 16'd0;
    endcase
  end

  // Combinational decode logic
  always @(*) begin
    opcode_pc_r    = fetch_pc_i;
    opcode_instr_r = fetch_instr_i;
    one_hot_r      = 26'd0;
    valid_r        = instr_valid_i;
    state          = SINGLE;
    opcode_valid_r = 0;

    case (opcode)
      4'b0000: begin // ADD Family
      opcode_valid_r = 1;
        ra_idx_r = fetch_instr_i[8:6];
        rb_idx_r = fetch_instr_i[5:3];
        rd_idx_r = fetch_instr_i[11:9];
        case (CCZ)
          3'b000: one_hot_r = `ADA;
          3'b010: one_hot_r = `ADC;
          3'b001: one_hot_r = `ADZ;
          3'b011: one_hot_r = `AWC;
          3'b100: one_hot_r = `ACA;
          3'b110: one_hot_r = `ACC;
          3'b101: one_hot_r = `ACZ;
          3'b111: one_hot_r = `ACW;
        endcase
      end
      4'b0001: begin // ADI
      opcode_valid_r = 1;
        rd_idx_r = fetch_instr_i[11:9];
        ra_idx_r = fetch_instr_i[8:6];
        one_hot_r = `ADI;
      end
      4'b0010: begin // NAND Family
      opcode_valid_r = 1;
        ra_idx_r = fetch_instr_i[8:6];
        rb_idx_r = fetch_instr_i[5:3];
        rd_idx_r = fetch_instr_i[11:9];
        case (CCZ)
          3'b000: one_hot_r = `NDU;
          3'b010: one_hot_r = `NDC;
          3'b001: one_hot_r = `NDZ;
          3'b100: one_hot_r = `NCU;
          3'b110: one_hot_r = `NCC;
          3'b101: one_hot_r = `NCZ;
        endcase
      end
      4'b0011: begin
      opcode_valid_r = 1;
        rd_idx_r = fetch_instr_i[11:9];
        one_hot_r = `LLI;
      end
      4'b0100: begin
      opcode_valid_r = 1;
        rd_idx_r = fetch_instr_i[11:9];
        rb_idx_r = fetch_instr_i[8:6];
        one_hot_r = `LW;
      end
      4'b0101: begin
      opcode_valid_r = 1;
        ra_idx_r = fetch_instr_i[11:9];
        rb_idx_r = fetch_instr_i[8:6];
        one_hot_r = `SW;
      end
      4'b0110: begin
        rb_idx_r = fetch_instr_i[11:9];
        one_hot_r = `LM;
        opcode_valid_r = (imm_val == 0) ? 0 : 1;
        state = imm_val[7] ? MS7 :
                imm_val[6] ? MS6 :
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE;    
      end
      4'b0111: begin
        rb_idx_r = fetch_instr_i[11:9];
        one_hot_r = `SM;
        opcode_valid_r = (imm_val == 0) ? 0 : 1;
        state = imm_val[7] ? MS7 : //priority en/decoding
                imm_val[6] ? MS6 :
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
      end
      4'b1000: begin
      opcode_valid_r = 1; 
      ra_idx_r = fetch_instr_i[11:9]; 
      rb_idx_r = fetch_instr_i[8:6]; 
      one_hot_r = `BEQ; 
      end
      4'b1001: begin opcode_valid_r = 1;
      ra_idx_r = fetch_instr_i[11:9]; 
      rb_idx_r = fetch_instr_i[8:6]; 
      one_hot_r = `BLT; 
      end
      4'b1010: begin 
      opcode_valid_r = 1;
      ra_idx_r = fetch_instr_i[11:9]; 
      rb_idx_r = fetch_instr_i[8:6]; 
      one_hot_r = `BLE; 
      end
      4'b1011: begin 
      opcode_valid_r = 1;
      rd_idx_r = fetch_instr_i[11:9]; 
      one_hot_r = `JAL; 
      end
      4'b1100: if (fetch_instr_i[5:0] == 6'b000000) begin
      opcode_valid_r = 1;
      rd_idx_r = fetch_instr_i[11:9]; 
      rb_idx_r = fetch_instr_i[8:6]; 
      one_hot_r = `JLR; 
      end
      4'b1101: begin 
      opcode_valid_r = 1;
      rd_idx_r = fetch_instr_i[11:9]; 
      one_hot_r = `JRI; 
      end
      
      default: opcode_valid_r = 0;
    endcase
  end

  // FSM: decode, including LM/SM support
  always @(posedge clk_i) begin
    if (rst_i) begin
      if (one_hot_r == `SM | one_hot_r == `LM)
            state <= imm_val[7] ? MS7 :
                imm_val[6] ? MS6 :
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE;
            else
            state <= SINGLE;
      opcode_valid_o   <= 1'b0;
      fetch_valid_o    <= 1'b1;
      opcode_pc_o   <= 0;
      opcode_instr_o   <= 0;
      ra_idx_o   <= 0;
      rb_idx_o   <= 0;
      rd_idx_o   <= 0;
      imm_val_o   <= 0;
      one_hot_o   <=0;
      
    end else if (!mem_stall_i) begin
        fetch_valid_o <= fetch_valid_w;
        if (one_hot_r == `SM | one_hot_r == `LM)
            state <= imm_val[7] ? MS7 :
                imm_val[6] ? MS6 :
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE;
            else
            state <= SINGLE;
            
      case (state)
        SINGLE: begin
          if (instr_valid_i) begin
            imm_val_o       <= imm_val;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            one_hot_o       <= one_hot_r;
            rd_idx_o        <= rd_idx_r;
            ra_idx_o        <= ra_idx_r;
            rb_idx_o        <= rb_idx_r;
            fetch_valid_o   <= 1'b1;
            opcode_valid_o  <= opcode_valid_r;
            if (one_hot_r == `SM | one_hot_r == `LM)
            state <= imm_val[7] ? MS7 :
                imm_val[6] ? MS6 :
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE;
            else
            state <= SINGLE;
          end
         end

        MS7: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd7;
            else ra_idx_o <= 3'd7;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[6] ? MS6 :
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
          end
        
        MS6: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd6;
            else ra_idx_o <= 3'd6;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[5] ? MS5 :
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
          end
          MS5: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd5;
            else ra_idx_o <= 3'd5;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[4] ? MS4 :
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
          end
        
        MS4: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd4;
            else ra_idx_o <= 3'd4;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[3] ? MS3 :
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
          end
          MS3: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd3;
            else ra_idx_o <= 3'd3;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[2] ? MS2 :
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
          end
        
        MS2: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd2;
            else ra_idx_o <= 3'd2;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[1] ? MS1 :
                imm_val[0] ? MS0 : SINGLE; 
          end
          MS1: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd1;
            else ra_idx_o <= 3'd1;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            state <= 
                imm_val[0] ? MS0 : SINGLE; 
          end
        
        MS0: begin
            rb_idx_o        <= rb_idx_r;
            if(one_hot_r == `LM) rd_idx_o <= 3'd0;
            else ra_idx_o <= 3'd0;
            one_hot_o       <= one_hot_r;
            opcode_pc_o     <= opcode_pc_r;
            opcode_instr_o  <= opcode_instr_r;
            imm_val_o       <= imm_val;
            opcode_valid_o  <= opcode_valid_r;
            //state <= SINGLE; 
          end

       
      endcase
    end
  end
// only valid if the last Multiple has been served and other normal cases
assign fetch_valid_w = rst_i ? 0 : 
                       mem_stall_i ? 0 : 
                      (state == SINGLE) ? 1 :
                      (state == MS7 && imm_val[6:0] == 0) ? 1 :
                      (state == MS6 && imm_val[5:0] == 0) ? 1 :
                      (state == MS5 && imm_val[4:0] == 0) ? 1 :
                      (state == MS4 && imm_val[3:0] == 0) ? 1 :
                      (state == MS3 && imm_val[2:0] == 0) ? 1 :
                      (state == MS2 && imm_val[1:0] == 0) ? 1 :
                      (state == MS1 && imm_val[0] == 0) ? 1 :
                      (state == MS0) ? 1 : 0;
                        
endmodule
