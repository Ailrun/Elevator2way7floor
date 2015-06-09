`timescale 1ns / 1ps

module EleCon2Ard#(parameter CLKFRQ = 100000000, BAUDRATE = 9600)
  (
   input        clk,
   input        reset,
   input [2:0]  currentFloor1,
   input [2:0]  currentFloor2,
   input [2:0]  currentFloor3,
   input [1:0]  currentDirection1,
   input [1:0]  currentDirection2,
   input [1:0]  currentDirection3,
   input [11:0] currentRealFloorButton,
   input [9:1]  currentInternalButton1,
   input [9:1]  currentInternalButton2,
   input [9:1]  currentInternalButton3,
   input        doorState1,
   input        doorState2,
   input        doorState3,
   output       tx
   );

   wire [56:0]  serial;
   wire [119:0] hammedSerial;

   EleConSerializer eleConS(.currentRealFloorButton(currentRealFloorButton),
                            .currentInternalButton1(currentInternalButton1),
                            .currentFloor1(currentFloor1),
                            .currentDirection1(currentDirection1),
                            .doorState1(doorState1),
                            .currentInternalButton2(currentInternalButton2),
                            .currentFloor2(currentFloor2),
                            .currentDirection2(currentDirection2),
                            .doorState2(doorState2),
                            .currentInternalButton3(currentInternalButton3),
                            .currentFloor3(currentFloor3),
                            .currentDirection3(currentDirection3),
                            .doorState3(doorState3),
                            .serial(serial));

   SerialHammingEncoder#(57) serialHammingE(.data(serial),
                                            .hammedData(hammedSerial));

   reg [119:8]  savedSerial;
   reg [3:0]    counter;
   reg [7:0]    data;
   reg          en;
   wire         ready;

   UARTSender#(CLKFRQ, BAUDRATE) uartS(.clk(clk), .reset(reset),
                                       .data(data), .en(en),
                                       .tx(tx), .ready(ready));

   always @(posedge clk)
     begin
        if (reset)
          begin
             savedSerial <= 112'b0;
             counter <= 15;
             data <= 8'b0;
             en <= 1'b0;
          end
        else
          begin
             if (counter == 15)
               begin
                  savedSerial <= hammedSerial[119:8];
                  data <= hammedSerial[7:0];
                  counter <= 7'b1;
               end
             else if (ready)
               begin
                  case (counter)
                    4'b0001 : data <= savedSerial[15:8];
                    4'b0010 : data <= savedSerial[23:16];
                    4'b0011 : data <= savedSerial[31:24];
                    4'b0100 : data <= savedSerial[39:32];
                    4'b0101 : data <= savedSerial[47:40];
                    4'b0110 : data <= savedSerial[55:48];
                    4'b0111 : data <= savedSerial[63:56];
                    4'b1000 : data <= savedSerial[71:64];
                    4'b1001 : data <= savedSerial[79:72];
                    4'b1010 : data <= savedSerial[87:80];
                    4'b1011 : data <= savedSerial[95:88];
                    4'b1100 : data <= savedSerial[103:96];
                    4'b1101 : data <= savedSerial[111:104];
                    4'b1110 : data <= savedSerial[119:112];
                  endcase
                  en <= 1'b1;
                  counter <= counter + 1;
               end
             else
               en <= 1'b0;
          end // else: !if(reset)
     end // always @ (posedge clk)

endmodule // EleCon2Ard
