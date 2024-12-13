`timescale 1ns / 1ps

module volume_shaper_tb;

    // Signals
    reg clk;
    reg reset;
    reg start;
    reg [7:0] attack_step_value, decay_step_value, sustain_level, release_step_value, sustain_time;
    wire [3:0] envelope;
    wire adsr_idle;

    // Instantiate the volume_shaper
    volume_shaper uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .attack_step_value(attack_step_value),
        .decay_step_value(decay_step_value),
        .sustain_level(sustain_level),
        .release_step_value(release_step_value),
        .sustain_time(sustain_time),
        .envelope(envelope),
        .adsr_idle(adsr_idle)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        start = 0;
        attack_step_value = 8'h01;  // Example step value
        decay_step_value = 8'h02;
        sustain_level = 8'h40;  // Example sustain level
        release_step_value = 8'h01;
        sustain_time = 8'hFF;  // Example sustain time
        
        // Apply reset
        reset = 1;
        #10 reset = 0;

        // Start ADSR envelope
        start = 1;
        #10 start = 0;
        
        // Run the simulation for enough time to observe the envelope change
        #200;  
        
        // Stop the simulation
        $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("At time %t, envelope = %b, state = %b, amplitude_counter = %d", $time, envelope, uut.state_reg, uut.amplitude_counter_reg);
    end
endmodule