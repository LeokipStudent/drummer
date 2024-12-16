module drummer(
    input [9:0] SW,
    input MAX10_CLK1_50, 
    output [35:0] GPIO
    );

    wire [7:0] connect;
    wire reset;
    wire [7:0] sound_out;
    assign reset = SW[0];

    sine_gen sine(
        .reset(reset),
        .sine_out(connect),
        .clkIn(MAX10_CLK1_50));

    noise_gen noise(
        .in(connect),
        .reset(reset),
        .out(sound_out),
        .clk(MAX10_CLK1_50);

    assign GPIO[7:0] = sound_out;
endmodule

// Modules for -----Noise_gen____
module noise_gen (in, reset, out, clk);
    input [7:0] in;
    input reset;
    input clk;
    output reg [7:0] out;

    wire [4:0] noise;

   random ran1(clk, noise, reset);
    
    always_comb
    begin
    if(noise[0])
        if(in + noise > 9'b111111111)
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

module random #(parameter WIDTH = 5)
(clk, q, reset);
	input clk, reset;
	output q;

	reg [WIDTH - 1:0] q;

	always @(posedge clk or posedge reset)
		begin
			if(reset) 
            begin
				q[0] <= 1;
                q[1] <= 1;
                q[2] <= 0;
                q[3] <= 0;
                q[4] <= 1;
            end
            else 
				q[0] <= q[WIDTH -1] ^ q[WIDTH - 3];
				for(int i = 1; i <= WIDTH-1; i++) q[i] <= q[i-1];
 		end
endmodule
//-----Noise_gen------




//------sine_gen------
module sine_gen(
	input reset ,
	output [7:0] sine_out,
	input clkIn);
	
	reg [7:0] out;
    reg [7:0] state;
	wire clk;
    
   clkDivider clkM (MAX10_CLK1_50, reset, clk);
	 
	 always @ (posedge clk or posedge reset)
        begin
        if(reset) 
				state <= 8'b0;
		  else if (state == 8'b00011111) 
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

    assign sine_out = out;
endmodule




// It seems like the internal clk we use is running at 1.55 MHz 
// Remember that freq = 2 x stop

module clkDivider(clk, reset, out);
    input clk, reset;
    output out;
	
reg [31:0] count;
reg [31:0] stop = 32'hF1b85;
reg outReg;

always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            count <= 32'b0;
            outReg <= 0;
         end

        else if(count == stop)
            begin
            count <= 32'b0;
            outReg <= ~outReg;
            end
        else
            count <= count + 1;
    end

assign out = outReg;
endmodule
//----sine_gen-----