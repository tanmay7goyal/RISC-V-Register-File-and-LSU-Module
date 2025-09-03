
module bkadder(
  input [15:0] a, b,
  input cin,
  output [15:0] s,
  output cout);
  
  wire [15:0] p0, g0;  // g0 p0 means only g0 p0
  wire [15:0] c;        // carries from each level used to evaluate sum
  wire [7:0] g1, p1;    // g1 p1 means g2i+1:2i p2i+1,2i
  wire [3:0] g2, p2;    // g2 p2 means g4i+3:4i p4i+3:4i
  wire [1:0] g3, p3;    // g3 p3 means g8i+7:8i p8i+7:8i
  wire g4, p4;          // simply g15:0 and p15:0
  
  // level 0 p&G
  assign p0 = a ^ b;
  assign g0 = a & b;
  
  genvar i;
  generate // level 1 p&G
    for(i=0; i<=7; i=i+1) begin:l1
      assign g1[i] = g0[2*i+1] | (p0[2*i+1] & g0[2*i]);
      assign p1[i] = p0[2*i+1] & p0[2*i];
    end
  endgenerate
  
  generate // level 2 p&G
    for(i=0; i<=3; i=i+1) begin:l2
      assign g2[i] = g1[2*i+1] | (p1[2*i+1] & g1[2*i]);
      assign p2[i] = p1[2*i+1] & p1[2*i];
    end
  endgenerate
  
  generate // level 3 p&G
    for(i=0; i<=1; i=i+1) begin:l3
      assign g3[i] = g2[2*i+1] | (p2[2*i+1] & g2[2*i]);
      assign p3[i] = p2[2*i+1] & p2[2*i];
    end
  endgenerate
  
  // level 4 p&G (final level for 16-bit)
  assign g4 = g3[1] | (p3[1] & g3[0]);
  assign p4 = p3[1] & p3[0];
  
  // carry generation
  assign c[0] = g0[0] | (p0[0] & cin);
  assign c[1] = g1[0] | (p1[0] & cin);
  assign c[3] = g2[0] | (p2[0] & cin);
  assign c[7] = g3[0] | (p3[0] & cin);
  assign c[15] = g4 | (p4 & cin);
  
  assign c[2] = g0[2] | (p0[2] & c[1]);
  
  assign c[4] = g0[4] | (p0[4] & c[3]);
  assign c[5] = g1[2] | (p1[2] & c[3]);
  assign c[6] = g0[6] | (p0[6] & c[5]);
  
  assign c[8] = g0[8] | (p0[8] & c[7]);
  assign c[9] = g1[4] | (p1[4] & c[7]);
  assign c[10] = g0[10] | (p0[10] & c[9]);
  assign c[11] = g2[2] | (p2[2] & c[7]);
  assign c[12] = g0[12] | (p0[12] & c[11]);
  assign c[13] = g1[6] | (p1[6] & c[11]);
  assign c[14] = g0[14] | (p0[14] & c[13]);
  
  assign s = p0 ^ {c[14:0], cin};  // final sum
  assign cout = c[15];             // carry out

endmodule