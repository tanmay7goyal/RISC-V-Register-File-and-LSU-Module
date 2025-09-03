
module bitwise_nand(
    input [15:0] a,b,  
    output [15:0] y
 );
 
 genvar i;
 generate
    for (i=0; i<16; i=i+1)begin
        assign y[i] = ~(a[i] & b[i]);
    end 
 endgenerate
endmodule