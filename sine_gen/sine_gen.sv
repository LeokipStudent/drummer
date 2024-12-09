module clkDivider(clk, reset, out);
    input clk, reset;
    output out;

reg [7:0] count;

bit [7:0] stop;

    stop <= 8'b00100000;

always @(posedge reset)
    begin
        reg <= 8'b0;
    end

always @(posedge clk)
    begin
        if(count == stop)
            begin
            count <= 8'b0;
            out = ~out;
            end
        else
            count <= count + 1;
    end
endmodule