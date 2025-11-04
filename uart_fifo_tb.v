`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 12:25:22 AM
// Design Name: 
// Module Name: uart_fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module uart_fifo_tb;

    reg clk;
    reg reset;
    reg uart_rx;
    wire uart_tx;
    wire [7:0] led;

    uart_fifo uut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .led(led)
    );

    // Clock generation: 50 MHz
    initial clk = 0;
    always #10 clk = ~clk; // 20 ns period = 50 MHz

    initial begin
        // Initialize signals
        reset = 1;
        uart_rx = 1;

        // Release reset after a few cycles
        #50 reset = 0;

        // Send a byte: ASCII 'A' = 8'h41
        send_uart_byte(8'h41);

        // Wait some time
        #10000;

        // Send another byte: ASCII 'B' = 8'h42
        send_uart_byte(8'h42);

        // Wait enough time for simulation
        #20000;

        $stop;
    end

    // Task to simulate UART transmission (LSB first, 1 start bit, 1 stop bit)
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            uart_rx = 0;
            #(104166); // 1/9600 baud with 50MHz clk -> ~10416 clk cycles (adjust for simulation time scale)
            
            // Send 8 data bits LSB first
            for(i=0; i<8; i=i+1) begin
                uart_rx = data[i];
                #(104166);
            end

            // Stop bit
            uart_rx = 1;
            #(104166);
        end
    endtask

endmodule

