

//Create a pseudo random 32 bit value and use that as the stop value for clockdivider, creating a signal of pseudo random frequeny

module noise_genII(
	input [9:0] SW ,
	output [35:0] GPIO,
	input MAX10_CLK1_50);

    wire reset;
    wire dout;
    wire ranClk;
    wire clk;
    wire stop;

    assign reset = SW[0];

    random ran(ranClk, stop, reset);

    sine_gen sine(clk, reset, dout);

    clkDivider clkdiv(MAX10_CLK1_50, reset, clk, stop);

endmodule

//  Module that adds noise to an 8 bit input signal by adding or subtracting a pseudo random 4 bit value to the signal.
//  Use reset on startup to ensure proper function

//  module that produces a five bit pseudo random value using a 5 bit register and an xor function
//  Can be asyncronously reset using the reset input

module random #(parameter WIDTH = 17)
(clk, q, reset);
	input clk, reset;
	output q;

	reg [WIDTH - 1:0] q = 17'b01001010010010101;

	always @(posedge clk or posedge reset)
		begin
			if(reset) 
                begin
                q <= 17'b01001010010010101;
				end
            else 
				q[0] <= q[WIDTH -1] ^ q[WIDTH - 3];
				for(int i = 1; i <= WIDTH-1; i++) q[i] <= q[i-1];

            if(q == 0)
                begin
                q <= 17'b00000000000000001;
                end
        end

endmodule

/*
    Send hardcoded sine wave forms. 
    1. Have 32 states (6 bits) to cycle through and print the associated hex value
    2. Have the hex value be the state value
*/

module sine_gen(clk, reset, dout);
    input clk, reset;
    output [7:0] dout;
    reg [7:0] state;

    reg [7:0] out;
    
    always @ (posedge clk or posedge reset)
        begin
        if(reset || state == 8'b00011111) 
            state <= 8'b0;
        else
            state <= state + 1;
        end

    always @ (posedge clk)
        begin
            case(state)
                8'h00 : out = 8'h80;
                8'h01 : out = 8'h98;
                8'h02 : out = 8'hB0;
                8'h03 : out = 8'hC7;
                8'h04 : out = 8'hDA;
                8'h05 : out = 8'hEA;
                8'h06 : out = 8'hF6;
                8'h07 : out = 8'hFD;
                8'h08 : out = 8'hFF;
                8'h09 : out = 8'hFB;
                8'h0a : out = 8'hF6;
                8'h0b : out = 8'hEA;
                8'h0c : out = 8'hDA;
                8'h0d : out = 8'hC7;
                8'h0e : out = 8'hB0;
                8'h0f : out = 8'h98;
                8'h10 : out = 8'h80;
                8'h11 : out = 8'h67;
                8'h12 : out = 8'h4F;
                8'h13 : out = 8'h38;
                8'h14 : out = 8'h25;
                8'h15 : out = 8'h15;
                8'h16 : out = 8'h9;
                8'h17 : out = 8'h2;
                8'h18 : out = 8'h0;
                8'h19 : out = 8'h2;
                8'h1a : out = 8'h9;
                8'h1b : out = 8'h15;
                8'h1c : out = 8'h25;
                8'h1d : out = 8'h38;
                8'h1e : out = 8'h4F;
                8'h1f : out = 8'h67;
                default : out  = 8'h80;
            endcase
        end

    assign dout = out;
endmodule





module clkDivider(clk, reset, out, stop);
    input clk, reset, stop;
    output out;
	
reg [31:0] count = 32'b0;
//reg [31:0] stop = 32'hf85;
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