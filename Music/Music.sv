
/*
    Send hardcoded sine wave forms. 
	 Have 32 states (6 bits) to cycle through and print the associated hex value
*/

module Music (
    input wire clk,           // Clock signal
    input wire reset,         // Reset signal
    input wire start,         // Trigger signal
    output wire [15:0] audio_out  // Output audio signal
);
    // Internal signals
    wire [15:0] sine_out;          // Sine wave output from SineWaveGenerator
    reg [1:0] current_wave;        // State: which sine wave to play (0, 1, or 2)
    reg [31:0] timer;              // Timer to track 2-second intervals

    // Frequencies for the sine waves (parameterized)
    parameter FREQ1 = 440;         // First sine wave frequency (Hz)
    parameter FREQ2 = 880;         // Second sine wave frequency (Hz)
    parameter FREQ3 = 1320;        // Third sine wave frequency (Hz)
    parameter CLOCK_FREQ = 48000;  // Sampling frequency (48 kHz)

    // Phase increment based on frequency
    reg [31:0] phase_inc;
    always @(*) begin
        case (current_wave)
            2'd0: phase_inc = (FREQ1 * (1 << 24)) / CLOCK_FREQ;
            2'd1: phase_inc = (FREQ2 * (1 << 24)) / CLOCK_FREQ;
            2'd2: phase_inc = (FREQ3 * (1 << 24)) / CLOCK_FREQ;
            default: phase_inc = 0;
        endcase
    end

    // Timer logic to track 2-second intervals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer <= 0;
            current_wave <= 0;  // Start with the first sine wave
        end else if (timer >= CLOCK_FREQ * 2) begin
            timer <= 0;  // Reset timer after 2 seconds
            current_wave <= current_wave + 1;  // Move to the next wave
            if (current_wave == 2'd2) begin
                current_wave <= 0;  // Loop back to the first wave
            end
        end else begin
            timer <= timer + 1;
        end
    end

    // Instantiate the SineWaveGenerator
    SineWaveGenerator sine_gen (
        .clk(clk),
        .reset(reset),
        .phase_inc(phase_inc),
        .sine_out(sine_out)
    );

    // Connect the output
    assign audio_out = sine_out;

endmodule




module sine_gen(
	input reset,
	output [7:0] dout,
	input clk);
	
	reg [7:0] out;
   reg [7:0] state;
	 
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

    assign dout = out;
endmodule




// It seems like the internal clk we use is running at 1.55 MHz 
// Remember that freq = 2 x stop

module clkDivider(clk, reset, out, stop);
    input clk, reset, stop;
    output out;
	
reg [31:0] count = 32'b0;
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