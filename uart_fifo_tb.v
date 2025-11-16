`timescale 1ns / 1ps

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

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        uart_rx = 1;
        
        $display("Starting UART FIFO Test...");
        
        #200 reset = 0;
        #1000;
        
        $display("Sending character 'A' (0x41)...");
        send_byte(8'h41);
        
        #500000;
        
        $display("Sending character 'B' (0x42)...");
        send_byte(8'h42);
        
        #1000000;
        
        $display("Test completed!");
        $display("Final LED value: %h", led);
        $finish;
    end
    
    task send_byte(input [7:0] data);
        integer i;
        begin
            uart_rx = 0;
            #8681;
            
            for(i=0; i<8; i=i+1) begin
                uart_rx = data[i];
                #8681;
            end
            
            uart_rx = 1;
            #8681;
        end
    endtask

endmodule
