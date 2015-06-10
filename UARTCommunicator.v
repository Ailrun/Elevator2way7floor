`timescale 1ns / 1ps

module UARTSender#(parameter CLKFRQ = 100000000, BAUDRATE = 9600)
  (
   input       clk,
   input       reset,
   input [7:0] data,
   input       en,
   output reg  tx,
   output reg  ready
   );

   localparam CLK_PER_BAUD = CLKFRQ/BAUDRATE,
     INIT = 16'b0;

   reg [15:0] tx_counter;
   reg [3:0]  tx_index;
   reg        tx_on;
   reg [7:0]  savedData;

   always @(posedge clk)
     begin
        if (reset)
          begin
             tx <= 1'b1;
             ready <= 1'b1;
             tx_counter <= INIT;
             tx_index <= 4'b0;
             tx_on <= 1'b0;
             savedData <= 8'b1111_1111;
          end
        else
          begin
             if (tx_counter == INIT)
               begin
                  if (en && ready)
                    begin
                       ready <= 1'b0;
                       tx_on <= 1'b1;
                       tx <= 1'b0;
                       tx_counter <= CLK_PER_BAUD;
                       tx_index <= 4'b0;
                       savedData <= data;
                    end
                  else if (tx_on)
                    begin
                       if (tx_index != 4'b1000)
                         begin
                            tx <= savedData[tx_index];
                            tx_index <= tx_index + 1;
                         end
                       else
                         begin
                            tx <= 1'b1;
                            tx_on <= 1'b0;
                         end
                       tx_counter <= CLK_PER_BAUD;
                    end // if (tx_on)
                  else
                    begin
                       ready <= 1'b1;
                    end // else: !if(tx_on)
               end // if (tx_counter == INIT)
             else
               begin
                  if (!tx_on)
                    ready <= 1'b1;
                  tx_counter <= tx_counter - 1;
               end // else: !if(tx_counter == INIT)
          end // else: !if(reset)
     end // always @ (posedge clk)

endmodule // UARTCommunicator

module UARTReceiver#(parameter CLKFRQ = 100000000, BAUDRATE = 9600)
   (
    input            clk,
    input            reset,
    input            rx,
    output reg [7:0] data,
    output reg       receiveAll
    );

   localparam CLK_PER_BAUD = CLKFRQ/BAUDRATE,
     INIT = 16'b0;

   reg [15:0]        rx_counter;
   reg [3:0]         rx_index;
   reg               rx_on;
   reg [7:0]         receiveData;

   always @(posedge clk)
     begin
        if (reset)
          begin
             data <= 8'b0;
             receiveAll <= 1'b0;
             rx_counter <= INIT;
             rx_index <= 4'b0;
             rx_on <= 1'b0;
             receiveData <= 8'b1111_1111;
          end
        else
          begin
             if (rx_counter == INIT)
               begin
                  if (!rx && !rx_on)
                    begin
                       rx_on <= 1'b1;
                       rx_index <= 4'b0;
                       rx_counter <= CLK_PER_BAUD;
                       receiveAll <= 1'b0;
                    end
                  else if (rx_on)
                    begin
                       if (rx_index != 4'b1000)
                         begin
                            receiveData[rx_index] <= rx;
                            rx_index <= rx_index + 1;
                         end
                       else
                         begin
                            data <= receiveData;
                            receiveAll <= 1'b1;
                            rx_on <= 0;
                         end // else: !if(rx_index != 4'b1000)
                       rx_counter <= CLK_PER_BAUD;
                    end // if (rx_on)
                  else
                    begin
                       receiveAll <= 1'b0;
                    end // else: !if(rx_on)
               end // if (rx_counter == INIT)
             else
               begin
                  receiveAll <= 1'b0;
                  rx_counter <= rx_counter - 1;
               end // else: !if(rx_counter == INIT)
          end // else: !if(reset)
     end // always @ (posedge clk)

endmodule // UARTReceiver
