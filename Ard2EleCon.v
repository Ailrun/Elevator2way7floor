`timescale 1ns / 1ps

module Ard2EleCon#(parameter CLKFRQ = 100000000, BAUDRATE = 9600)
  (
   input         clk,
   input         reset,
   input         rx,
   output [11:0] newRealFloorButton,
   output [9:1]  newInternalButton1,
   output [9:1]  newInternalButton2,
   output [9:1]  newInternalButton3
   );

   reg [6:0]     counter;
   reg [71:0]    savedSerial;
   wire [7:0]    data;
   wire          receiveAll;

   UARTReceiver#(CLKFRQ, BAUDRATE) uartR(.clk(clk), .reset(reset),
                                         .en(1'b1), .data(data),
                                         .receiveAll(receiveAll));

   always @(posedge clk)
     begin
        if (reset)
          begin
             counter <= 7'b0;
             savedSerial <= 72'b0;
          end
        else
          begin
             if (counter == 15)
               begin
                  counter <= 1;
               end
          end // else: !if(reset)
     end // always @ (posedge clk)

   wire [39:0] serial;

   SerialHammingDecoder#(39) serialHammingD(.hammedData(hammedSerial),
                                       .data(serial));

   ArdParallelizer ardP(.serial(serial),
                        .newRealFloorButton(newRealFloorButton),
                        .newInternalButton1(newInternalButton1),
                        .newInternalButton2(newInternalButton2),
                        .newInternalButton3(newInternalButton3));

endmodule // Ard2EleCon
