/*
    Send hardcoded sine wave forms. 
	 Have 32 states (6 bits) to cycle through and print the associated hex value
*/

module sine_gen(
	input [9:0] SW ,
	output [35:0] GPIO,
	input MAX10_CLK1_50);
	
	reg [7:0] out;
   reg [7:0] state;
	wire clk;
	wire reset;
	
	assign reset = SW[0];
    
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

    assign GPIO [7:0] = out;
endmodule




// It seems like the internal clk we use is running at 1.55 MHz 
// Remember that freq = 2 x stop

module clkDivider(clk, reset, out);
    input clk, reset;
    output out;
	
reg [31:0] count;
reg [31:0] stop = 32'hF23;
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