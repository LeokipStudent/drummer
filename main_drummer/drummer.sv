module counter2(SW, HEX0, KEY);
input [9:0] SW;
input [0:1] KEY;
output [0:6] HEX0;
wire UD, Re, clk;
wire [3:0] num;
wire [1:0] display;
assign clk = KEY[1];
assign UD = SW[0];
assign Re = ~KEY[0];
count(UD, Re, clk, num);
display(num, HEX0);
endmodule

module count(UD, Re, clk, q);
input UD, Re, clk;
output [3:0] q;



typedef enum logic [3:0] {s0, s1, s2, s3, s4, s5, s6, s7, s8, s9} statetype;
statetype state, nextstate;
always_ff @ (posedge clk, posedge Re)
begin
if(Re) state <= s0;
else state <= nextstate;
end
always_comb
if(UD)
begin
case(state)
s0: nextstate = s1;
s1: nextstate = s2;
s2: nextstate = s3;
s3: nextstate = s4;
s4: nextstate = s5;
s5: nextstate = s6;
s6: nextstate = s7;
s7: nextstate = s8;
s8: nextstate = s9;
s9: nextstate = s0;
default: nextstate = s0;
endcase
end
else
begin
case(state)
s0: nextstate = s9;
s1: nextstate = s0;
s2: nextstate = s1;
s3: nextstate = s2;
s4: nextstate = s3;
s5: nextstate = s4;
s6: nextstate = s5;
s7: nextstate = s6;
s8: nextstate = s7;
s9: nextstate = s8;
default: nextstate = s0;
endcase
end
assign q = state;
endmodule

module display(num, HEX);
input [3:0] num;
output [6:0] HEX;
always_comb
case(num)
4'b0000: HEX = 7'b0000001;
4'b0001: HEX = 7'b1001111;
4'b0010: HEX = 7'b0010010;
4'b0011: HEX = 7'b0000110;
4'b0100: HEX = 7'b1001100;
4'b0101: HEX = 7'b0100100;
4'b0110: HEX = 7'b0100000;
4'b0111: HEX = 7'b0001111;
4'b1000: HEX = 7'b0000000;
4'b1001: HEX = 7'b0000100;
default: HEX = 7'b0000001;
endcase 
endmodule
