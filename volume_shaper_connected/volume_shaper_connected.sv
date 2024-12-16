module combined (
	input [9:0] Sw,
	output [35:0] GPIO,
	input MAX10_CLK1_50); 
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
 module volume_shaper(
input logic clk,
input logic reset,
input logic start, // generate a pulse to start the envelope generation
input logic [7:0] attack_step_value, // precalculated (Amax - 0)/(t_attack - t_sys) steps for the attack segment
input logic [7:0] decay_step_value,  // precalculated (A_max-A_sus) / (t_sustain / t_sys) steps for the decay segment
input logic [7:0] sustain_level, // amplitude for the sustain segment
input logic [7:0] release_step_value,  // precalculated (A_sus - 0)/(t_release - t_sys) steps fot the release segment
input logic [7:0] sustain_time, // tsustain / t_sys steps for the sustain
output logic [3:0] envelope,
output logic adsr_idle

    );
    
    // constants
    localparam MAX = 8'hFF
	 ;
    localparam BYPASS = 8'hff;
    localparam ZERO = 8'h00;
    
    // fsm state type
    typedef enum {idle, launch, attack, decay, sustain, rel} state_type;
    
    // declaration
    state_type state_reg;
    state_type state_next;
    logic [7:0] amplitude_counter_reg;
    logic [7:0] amplitude_counter_next;
    logic [7:0] sustain_time_reg;
    logic [7:0] sustain_time_next;
    logic [7:0] n_tmp;
    logic fsm_idle;
    logic [7:0] envelope_i;
    // state and data registers
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset) 
          begin
            state_reg <= idle;
            amplitude_counter_reg <= 8'b0;
            sustain_time_reg <= 8'b0;
          end
         else
         begin
            state_reg <= state_next;
            amplitude_counter_reg <= amplitude_counter_next;
            sustain_time_reg <= sustain_time_next;
         end
    end
    
    // fsmd next-state logic and data path logic
    always_comb
    begin
    state_next = state_reg;
    amplitude_counter_next = amplitude_counter_reg;
    sustain_time_next = sustain_time_reg;
    fsm_idle = 1'b0;        
    n_tmp = amplitude_counter_reg;   
        case (state_reg)         
            idle: begin
                fsm_idle = 1'b1;
                if (start) begin
                    state_next = launch;
                  end
              end
            launch: begin
                state_next = attack;
                amplitude_counter_next = 8'b0;
              end  
            attack: begin
                if(start) begin
                    state_next = launch;
                end else begin
                    n_tmp = amplitude_counter_reg + attack_step_value;
                    if (n_tmp < MAX) begin
                        amplitude_counter_next = n_tmp;
                    end else begin
                        state_next = decay;
                    end
                 end
              end
            decay: begin
                if (start) begin
                    state_next = launch;
                end else begin
                    n_tmp = amplitude_counter_reg - decay_step_value;
                    if(n_tmp > sustain_level) begin
                        amplitude_counter_next = n_tmp;
                    end else begin
                        amplitude_counter_next = sustain_level;
                        state_next = sustain;
                        sustain_time_next = 8'b0;  // start timer
                    end
                 end
              end              
            sustain: begin
                if (start) begin
                    state_next = launch;
                end else begin
                    if(sustain_time_reg < sustain_time) begin
                        sustain_time_next = sustain_time_next + 1;
                    end else begin
                        state_next = rel;
                    end
                 end
              end              
             default: begin
                if (start) begin
                    state_next = launch;
                  end else begin
                    if(amplitude_counter_reg > release_step_value) begin
                        amplitude_counter_next = amplitude_counter_reg - release_step_value;
                    end else begin
                        state_next = idle;
                    end
                  end
               end    
        endcase

    end
    
    assign adsr_idle = fsm_idle;
    
assign envelope_i = 8'((attack_step_value == BYPASS) ? MAX :
                       (attack_step_value == ZERO) ? 8'h00 :
                       amplitude_counter_reg);

                   
    assign envelope = {1'b0, envelope_i[7:5]};
endmodule