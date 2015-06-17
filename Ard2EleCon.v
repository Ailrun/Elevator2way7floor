`timescale 1ns / 1ps

module Ard2EleCon#(parameter CLKFRQ = 100000000, BAUDRATE = 9600)
  (
   input         clk,
   input         reset,
   input         en,
   input         rx,
   output [11:0] newRealFloorButton,
   output [9:1]  newInternalButton1,
   output [9:1]  newInternalButton2,
   output [9:1]  newInternalButton3
   );

   reg [3:0]     counter;
   reg [71:0]    savedSerial;
   wire [7:0]    data;
   wire          receiveAll;

   UARTReceiver#(CLKFRQ, BAUDRATE) uartR(.clk(clk), .reset(reset),
                                         .data(data), .rx(rx),
                                         .receiveAll(receiveAll));

   reg [79:0]   reversedSerial;
   reg          en;

   always @(posedge clk)
     begin
        if (reset)
          begin
             counter <= 7'b0;
             savedSerial <= 72'b0;
             en <= 1'b0;
          end
        else
          begin
             if (receiveAll)
               begin
                  if (counter == 9)
                    begin
                       reversedSerial <= {data, savedSerial};
                       counter <= 0;
                       en <= 1'b1;
                    end
                  else
                    begin
                       case (counter)
                         4'b0000 : savedSerial[7:0] <= data;
                         4'b0001 : savedSerial[15:8] <= data;
                         4'b0010 : savedSerial[23:16] <= data;
                         4'b0011 : savedSerial[31:24] <= data;
                         4'b0100 : savedSerial[39:32] <= data;
                         4'b0101 : savedSerial[47:40] <= data;
                         4'b0110 : savedSerial[55:48] <= data;
                         4'b0111 : savedSerial[63:56] <= data;
                         4'b1000 : savedSerial[71:64] <= data;
                       endcase // case (counter)
                       counter <= counter + 1;
                       en <= 1'b0;
                    end
               end // if (receiveAll)
             else
               en <= 1'b0;
          end // else: !if(reset)
     end // always @ (posedge clk)

   wire [79:0] hammedSerial;

   genvar      i;
   generate
      for (i = 0; i < 80; i = i + 1)
        begin : gen0
           assign hammedSerial[i] = en?0:reversedSerial[79-i];
        end
   endgenerate

   wire [38:0] serial;

   SerialHammingDecoder#(39) serialHammingD(.hammedData(hammedSerial),
                                            .data(serial));

   ArdParallelizer ardP(.serial(serial),
                        .newRealFloorButton(newRealFloorButton),
                        .newInternalButton1(newInternalButton1),
                        .newInternalButton2(newInternalButton2),
                        .newInternalButton3(newInternalButton3));

endmodule // Ard2EleCon
