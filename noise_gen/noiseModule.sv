//  Module that adds noise to an 8 bit input signal by adding or subtracting a pseudo random 4 bit value to the signal.
//  Use reset on startup to ensure proper function

module Noise_gen_out(SW, GPIO, MAX10_CLK1_50);
	input [9:0] SW;
	input MAX10_CLK1_50;
	output[35:0] GPIO;

	wire reset;
	wire [7:0] in;
	wire [7:0] out;
	wire clk;

	assign reset = SW[0];
	assign in = 8'b10000000;
	
	clkDivider clkM (MAX10_CLK1_50, reset, clk);
	
	noise_gen noise(in, out, clk, reset);
	
	assign GPIO [7:0] = out;
	assign GPIO [35:8] = 28'b0;
endmodule

module noise_gen (in, out, clk, reset);
    input [7:0] in;
    input clk;
	 input reset;
    output reg [7:0] out;
	 wire [7:0] noise;
    random ran1(clk, noise, reset);
    
    always_comb
    begin
    if(noise[0])
        if(in + noise > 9'b011111111)
            out = 8'b11111111;
        else 
            out = in + noise;
    
    else if(in > noise)
        out = in - noise;
    
    else 
        out = 8'b00000000;

    end

endmodule


//  module that produces a five bit pseudo random value using a 5 bit register and an xor function
//  Can be asyncronously reset using the reset input

module random #(parameter WIDTH = 8)
(clk, q, reset);
	input clk, reset;
	output q;

	reg [WIDTH - 1:0] q = 8'b10101101;

	always @(posedge clk or posedge reset)
		begin
			if(reset) 
            begin
				q = 8'b10101101;
				end
            else 
				q[0] <= q[WIDTH -1] ^ q[WIDTH - 3];
				for(int i = 1; i <= WIDTH-1; i++) q[i] <= q[i-1];
 		end
endmodule





// Output frequency is = 2 x stop 
// Remember that sinewave takes 32 clock cycles for one wave 

module clkDivider(clk, reset, out);
    input clk, reset;
    output out;
	
reg [31:0] count = 32'b0;
reg [31:0] stop = 32'hF1b85;
reg outReg = 0;

always @(posedge clk)
    begin
        if(count == stop)
            begin
            count <= 32'b0;
            outReg <= ~outReg;
            end
        else
            count <= count + 1;
    end

assign out = outReg;
endmodule