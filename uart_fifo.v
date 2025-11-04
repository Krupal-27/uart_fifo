`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 11:38:12 PM
// Design Name: 
// Module Name: uart_fifo
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


// -----------------------------
// Synthesizable FIFO Module
// -----------------------------
module fifo #(parameter WIDTH=8, DEPTH=16)(
    input clk,
    input reset,
    input wr_en,
    input rd_en,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output reg empty,
    output reg full
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [4:0] wr_ptr;
    reg [4:0] rd_ptr;
    reg [4:0] count;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            empty  <= 1;
            full   <= 0;
            dout   <= 0;
        end else begin
            if(wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= (wr_ptr + 1) % DEPTH;
                count <= count + 1;
            end
            if(rd_en && !empty) begin
                dout <= mem[rd_ptr];
                rd_ptr <= (rd_ptr + 1) % DEPTH;
                count <= count - 1;
            end
            empty <= (count == 0);
            full  <= (count == DEPTH);
        end
    end
endmodule

// -----------------------------
// Combined Synthesizable UART Module (TX + RX)
// -----------------------------
module uart #(parameter CLK_FREQ=50000000, BAUD=9600)(
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
    localparam integer BAUD_DIV = CLK_FREQ/BAUD;

    // TX signals
    reg [15:0] tx_baud_cnt;
    reg [3:0] tx_bit_cnt;
    reg [9:0] tx_shift_reg;

    // RX signals
    reg [15:0] rx_baud_cnt;
    reg [3:0] rx_bit_cnt;
    reg [9:0] rx_shift_reg;
    reg rx_busy;

    initial begin
        tx = 1;
        tx_busy = 0;
        rx_ready = 0;
        rx_busy = 0;
    end

    // ---------------- Transmitter ----------------
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            tx <= 1; tx_busy <= 0; tx_baud_cnt <= 0; tx_bit_cnt <= 0; tx_shift_reg <= 0;
        end else begin
            if(tx_start && !tx_busy) begin
                tx_shift_reg <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1;
                tx_bit_cnt <= 0;
                tx_baud_cnt <= 0;
            end
            if(tx_busy) begin
                if(tx_baud_cnt == BAUD_DIV-1) begin
                    tx_baud_cnt <= 0;
                    tx <= tx_shift_reg[0];
                    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
                    tx_bit_cnt <= tx_bit_cnt + 1;
                    if(tx_bit_cnt == 9) tx_busy <= 0;
                end else begin
                    tx_baud_cnt <= tx_baud_cnt + 1;
                end
            end
        end
    end

    // ---------------- Receiver ----------------
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            rx_data <= 0; rx_ready <= 0; rx_busy <= 0; rx_bit_cnt <= 0; rx_baud_cnt <= 0; rx_shift_reg <= 0;
        end else begin
            rx_ready <= 0;
            if(!rx_busy && rx == 0) begin
                rx_busy <= 1;
                rx_baud_cnt <= BAUD_DIV/2;
                rx_bit_cnt <= 0;
            end
            if(rx_busy) begin
                if(rx_baud_cnt == BAUD_DIV-1) begin
                    rx_baud_cnt <= 0;
                    rx_shift_reg <= {rx, rx_shift_reg[9:1]};
                    rx_bit_cnt <= rx_bit_cnt + 1;
                    if(rx_bit_cnt == 9) begin
                        rx_data <= rx_shift_reg[8:1];
                        rx_ready <= 1;
                        rx_busy <= 0;
                    end
                end else begin
                    rx_baud_cnt <= rx_baud_cnt + 1;
                end
            end
        end
    end
endmodule

// -----------------------------
// Top Module: UART + FIFO
// -----------------------------
module uart_fifo(
    input clk,
    input reset,
    input uart_rx,
    output uart_tx,
    output [7:0] led
);
    wire [7:0] fifo_out;
    wire fifo_empty, fifo_full;
    reg fifo_rd;
    reg [7:0] uart_tx_data;
    reg uart_tx_start;
    wire uart_tx_busy;

    wire [7:0] uart_rx_data;
    wire uart_rx_ready;
    reg fifo_wr;

    fifo #(8,16) fifo_inst (
        .clk(clk),
        .reset(reset),
        .wr_en(fifo_wr),
        .rd_en(fifo_rd),
        .din(uart_rx_data),
        .dout(fifo_out),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    uart #(.CLK_FREQ(50000000), .BAUD(9600)) uart_inst (
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

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            fifo_wr       <= 0;
            fifo_rd       <= 0;
            uart_tx_start <= 0;
            uart_tx_data  <= 0;
        end else begin
            fifo_wr <= uart_rx_ready;
            if(uart_rx_ready)
                uart_tx_data <= uart_rx_data;

            fifo_rd <= !fifo_empty && !uart_tx_busy;

            if(fifo_rd) begin
                uart_tx_data <= fifo_out;
                uart_tx_start <= 1;
            end else begin
                uart_tx_start <= 0;
            end
        end
    end
endmodule
