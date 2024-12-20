`timescale 1ns / 1ps


// fsm to generate ADSR envelop

// start (trigger) signal:
//     - starts the "attack" when asserted
//     - restarts the epoch if aseerted before the current epoch ends 

// amplitudes:
//     - 32-bit unsigned   
//     - use 32 bits to accommodate the needed resolution for "step"
//     - intepreted as Q1.31 format:
//     - range artificially limited between 0.0 and 1.0
//     - i.e., 0.0...0 to 1.0...0 (1.0)
//     - 1.1xx...x not allowed

// output: Q2.14 for range (-1.0 to 1.0)

// special atk_step values
//     - atk_step = 11..11: bypass adsr; i.e., envelop=1.0
//     - atk_step = 00..00: output 0; i.e., envelop = 0.0

// Width selection: 
//   max attack time = 2^31 * clock period = 2^31 *(1/100e6) = 21,47483648 seconds

// Attack_time
// t_attack desired attack time
// t_sys sytem clock period
// maximum amplitude Amax
// need t_attack / t_sys clock cycles in the attact segment
// the counter must be incremented (Amax - 0)/(t_attack - t_sys) each clock cycle to reach A_max from zero in t_attack

// Decrementing amount in decay segment for t_decay
// t_decay and A_sus.  (A_max-A_sus) / (t_sustain / t_sys)
// 

// Decrementing amount in release segment
// (A_sus - 0)/(t_release - t_sys)

// The amplitude is constant in the sustain segment
// There are are tsustain / t_sys cycles in the sustain segment

// Amax  |    /\
//       |   /  \
//       |  /    \
// Asus  | /      ------------
//       |/                   \
//       ---------------------------
//        | attack
//             | decay
//                | sustain
//                            | release


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