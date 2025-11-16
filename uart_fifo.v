`timescale 1ns / 1ps

module fifo #(parameter WIDTH=8, DEPTH=16)(
    input clk,
    input reset,
    input wr_en,
    input rd_en,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output empty,
    output full
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] count;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            dout <= 0;
        end else begin
            if(wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end
            
            if(rd_en && !empty) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end
    
    assign empty = (count == 0);
    assign full = (count == DEPTH);
endmodule

module uart #(parameter CLK_FREQ=50000000, BAUD=115200)(
    input clk,
    input reset,
    input rx,
    output reg tx,
    input [7:0] tx_data,
    input tx_start,
    output reg tx_busy,
    output reg [7:0] rx_data,
    output reg rx_ready
);
    localparam CLOCKS_PER_BIT = CLK_FREQ / BAUD;
    
    reg [15:0] tx_counter;
    reg [3:0] tx_bit_count;
    reg [9:0] tx_shift;
    
    reg [15:0] rx_counter;
    reg [3:0] rx_bit_count;
    reg [9:0] rx_shift;
    reg rx_active;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            tx <= 1;
            tx_busy <= 0;
            tx_counter <= 0;
            tx_bit_count <= 0;
        end else begin
            if(tx_start && !tx_busy) begin
                tx_shift <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1;
                tx_bit_count <= 0;
                tx_counter <= 0;
            end
            
            if(tx_busy) begin
                if(tx_counter == CLOCKS_PER_BIT-1) begin
                    tx_counter <= 0;
                    tx <= tx_shift[0];
                    tx_shift <= tx_shift >> 1;
                    tx_bit_count <= tx_bit_count + 1;
                    
                    if(tx_bit_count == 9) begin
                        tx_busy <= 0;
                    end
                end else begin
                    tx_counter <= tx_counter + 1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            rx_data <= 0;
            rx_ready <= 0;
            rx_active <= 0;
            rx_counter <= 0;
            rx_bit_count <= 0;
        end else begin
            rx_ready <= 0;
            
            if(!rx_active) begin
                if(rx == 1'b0) begin
                    rx_active <= 1;
                    rx_counter <= 0;
                    rx_bit_count <= 0;
                end
            end else begin
                if(rx_counter == CLOCKS_PER_BIT-1) begin
                    rx_counter <= 0;
                    rx_shift <= {rx, rx_shift[9:1]};
                    rx_bit_count <= rx_bit_count + 1;
                    
                    if(rx_bit_count == 9) begin
                        rx_data <= rx_shift[8:1];
                        rx_ready <= 1;
                        rx_active <= 0;
                    end
                end else begin
                    rx_counter <= rx_counter + 1;
                end
            end
        end
    end
endmodule

module uart_fifo(
    input clk,
    input reset,
    input uart_rx,
    output uart_tx,
    output [7:0] led
);
    wire [7:0] fifo_out;
    wire fifo_empty;
    wire fifo_full;
    wire fifo_rd;
    
    wire [7:0] uart_rx_data;
    wire uart_rx_ready;
    wire uart_tx_busy;
    
    reg fifo_wr;
    reg [7:0] uart_tx_data;
    reg uart_tx_start;

    fifo fifo_inst (
        .clk(clk),
        .reset(reset),
        .wr_en(fifo_wr),
        .rd_en(fifo_rd),
        .din(uart_rx_data),
        .dout(fifo_out),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    uart uart_inst (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .tx(uart_tx),
        .tx_data(uart_tx_data),
        .tx_start(uart_tx_start),
        .tx_busy(uart_tx_busy),
        .rx_data(uart_rx_data),
        .rx_ready(uart_rx_ready)
    );

    assign led = fifo_out;
    assign fifo_rd = !fifo_empty && !uart_tx_busy;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            fifo_wr <= 0;
            uart_tx_start <= 0;
            uart_tx_data <= 0;
        end else begin
            fifo_wr <= uart_rx_ready;
            
            if(uart_rx_ready) begin
                uart_tx_data <= uart_rx_data;
            end
            
            if(fifo_rd) begin
                uart_tx_start <= 1;
            end else begin
                uart_tx_start <= 0;
            end
        end
    end
endmodule
