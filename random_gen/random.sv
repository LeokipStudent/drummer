module random #(parameter WIDTH = 8)
(trigg, width, clk, out, reset);
	input trigg, width, clk, reset;
	output out;

	reg [WIDTH - 1:0] q;

	always_ff @(posedge clk or posedge reset)
		begin
			if(reset) 
				q = 8'b11001001;
			else 
				q[0] <= q[WIDTH -1] ^ q[WIDTH - 3];
				for(int i = 1; i <= WIDTH-1; i++) q[i] <= q[i-1];
 		end

	assign out = q[WIDTH-1];
endmodule