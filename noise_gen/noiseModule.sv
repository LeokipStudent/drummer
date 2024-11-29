module noiseModule (in, out, clk);
    input [7:0] in;
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


module random #(parameter WIDTH = 5)
(clk, q, reset);
	input clk, reset;
	output q;

	reg [WIDTH - 1:0] q;

	always_ff @(posedge clk or posedge reset)
		begin
			if(reset) 
				q = 5'b11001;
			else 
				q[0] <= q[WIDTH -1] ^ q[WIDTH - 3];
				for(int i = 1; i <= WIDTH-1; i++) q[i] <= q[i-1];
 		end
endmodule