# **UART with FIFO Buffer System**

This project implements a complete UART (Universal Asynchronous Receiver/Transmitter) communication system with FIFO (First-In-First-Out) buffer in Verilog, providing robust serial data handling with flow control.

## 🏗️ Architecture
- **Dual-Module Design**: UART transceiver with FIFO buffer
- **Baud Rate Generation**: Programmable baud rate support
- **Flow Control**: FIFO-based data buffering
- **Full-Duplex Operation**: Simultaneous transmit and receive

## 📋 System Components

### UART Transceiver
- **TX Module**: Parallel-to-serial conversion with start/stop bits
- **RX Module**: Serial-to-parallel conversion with synchronization
- **Baud Rate Control**: Configurable clock division
- **Frame Format**: 8 data bits, 1 stop bit, no parity

### FIFO Buffer
- **Configurable Depth**: 16-byte buffer size
- **Flow Control**: Empty/Full status flags
- **Circular Buffer**: Efficient memory utilization
- **Synchronous Operation**: Clock-based read/write operations

## 🎯 Key Features
- **Programmable Baud Rate**: 9600 baud (default) with configurable clock frequency
- **Data Buffering**: 16-byte FIFO prevents data loss
- **Status Indicators**: TX busy, RX ready, FIFO empty/full flags
- **Error Resilience**: Proper start bit detection and frame synchronization
- **Synthesizable Design**: Ready for FPGA implementation

## 🔧 Technical Specifications

### UART Parameters
- **Data Bits**: 8 bits
- **Stop Bits**: 1 bit
- **Parity**: None
- **Baud Rate**: 9600 (configurable)
- **Clock Frequency**: 50 MHz (configurable)

### FIFO Parameters
- **Width**: 8 bits
- **Depth**: 16 entries
- **Pointers**: 5-bit for wrap-around handling
- **Status Flags**: Empty, Full

## 📊 Signal Description

### Top Level I/O
- **clk**: System clock (50MHz)
- **reset**: System reset
- **uart_rx**: Serial data input
- **uart_tx**: Serial data output
- **led**: 8-bit output display (FIFO data)

### UART Interface
- **tx_data**: 8-bit transmit data
- **tx_start**: Transmit initiation
- **tx_busy**: Transmit in progress
- **rx_data**: 8-bit received data
- **rx_ready**: Data received and ready

### FIFO Interface
- **wr_en**: Write enable
- **rd_en**: Read enable
- **din**: Data input (8-bit)
- **dout**: Data output (8-bit)
- **empty**: FIFO empty status
- **full**: FIFO full status

## 📁 Project Structure
