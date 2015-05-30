`timescale 1ns / 1ps

module GiveFloorButton
  (
   input         clk,
   input         reset,
   input [2:0]   currentFloor1,
   input [2:0]   currentFloor2,
   input [13:0]  newFloorButton,
   input [13:0]  currentFloorButton1,
   input [13:0]  currentFloorButton2,
   input [13:0]  unusedFloorButtonIn,
   input [1:0]   direction1,
   input [1:0]   direction2,
   output [13:0] nextFloorButton1,
   output [13:0] nextFloorButton2,
   output [13:0] unusedFloorButtonOut
   );

   localparam STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     ON = 1'b1, OFF = 1'b0;

   reg           sameDis = 0;

   SubGive sub1(clk, reset, sameDis, 3'b001, currentFloor1, currentFloor2,
                newFloorButton[1:0],
                currentFloorButton1[1:0], currentFloorButton2[1:0],
                unusedFloorButtonIn[1:0],
                direction1, direction2,
                nextFloorButton1[1:0], nextFloorButton2[1:0],
                unusedFloorButtonOut[1:0]);
   SubGive sub2(clk, reset, ~sameDis, 3'b010, currentFloor1, currentFloor2,
                newFloorButton[3:2],
                currentFloorButton1[3:2], currentFloorButton2[3:2],
                unusedFloorButtonIn[3:2],
                direction1, direction2,
                nextFloorButton1[3:2], nextFloorButton2[3:2],
                unusedFloorButtonOut[3:2]);
   SubGive sub3(clk, reset, sameDis, 3'b011, currentFloor1, currentFloor2,
                newFloorButton[5:4],
                currentFloorButton1[5:4], currentFloorButton2[5:4],
                unusedFloorButtonIn[5:4],
                direction1, direction2,
                nextFloorButton1[5:4], nextFloorButton2[5:4],
                unusedFloorButtonOut[5:4]);
   SubGive sub4(clk, reset, ~sameDis, 3'b100, currentFloor1, currentFloor2,
                newFloorButton[7:6],
                currentFloorButton1[7:6], currentFloorButton2[7:6],
                unusedFloorButtonIn[7:6],
                direction1, direction2,
                nextFloorButton1[7:6], nextFloorButton2[7:6],
                unusedFloorButtonOut[7:6]);
   SubGive sub5(clk, reset, sameDis, 3'b101, currentFloor1, currentFloor2,
                newFloorButton[9:8],
                currentFloorButton1[9:8], currentFloorButton2[9:8],
                unusedFloorButtonIn[9:8],
                direction1, direction2,
                nextFloorButton1[9:8], nextFloorButton2[9:8],
                unusedFloorButtonOut[9:8]);
   SubGive sub6(clk, reset, ~sameDis, 3'b110, currentFloor1, currentFloor2,
                newFloorButton[11:10],
                currentFloorButton1[11:10], currentFloorButton2[11:10],
                unusedFloorButtonIn[11:10],
                direction1, direction2,
                nextFloorButton1[11:10], nextFloorButton2[11:10],
                unusedFloorButtonOut[11:10]);
   SubGive sub7(clk, reset, sameDis, 3'b111, currentFloor1, currentFloor2,
                newFloorButton[13:12],
                currentFloorButton1[13:12], currentFloorButton2[13:12],
                unusedFloorButtonIn[13:12],
                direction1, direction2,
                nextFloorButton1[13:12], nextFloorButton2[13:12],
                unusedFloorButtonOut[13:12]);

   always @(posedge clk)
     begin
        sameDis <= ~sameDis; // determine each Elevator's custom.
     end

endmodule // GiveFloorButton

module SubGive
  (
   input        clk,
   input        reset,
   input        sameDis, //set each Elevator's behavior
   input [2:0]  buttonFloor,
   input [2:0]  currentFloor1,
   input [2:0]  currentFloor2,
   input [1:0]  newFloorButton,
   input [1:0]  currentFloorButton1,
   input [1:0]  currentFloorButton2,
   input [1:0]  unusedFloorButtonIn,
   input [1:0]  direction1,
   input [1:0]  direction2,
   output [1:0] nextFloorButton1,
   output [1:0] nextFloorButton2,
   output [1:0] unusedFloorButtonOut
   );

   localparam STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     ON = 1'b1, OFF = 1'b0;

   wire [1:0] wholeButton = newFloorButton |
              currentFloorButton1 |
              currentFloorButton2 |
              unusedFloorButtonIn;

   wire [1:0] loseButton1 = STOP;
   wire [1:0] loseButton2 = STOP;
   wire [1:0] getButton1 = STOP;
   wire [1:0] getButton2 = unusedFloorButtonIn;

   assign nextFloorButton1 = reset?0:
                             (currentFloorButton1 | getButton1) & ~loseButton1;
   assign nextFloorButton2 = reset?0:
                             (currentFloorButton2 | getButton2) & ~loseButton2;

   assign unusedFloorButtonOut = reset?0:
                                 (unusedFloorButtonIn | newFloorButton) &
                                 ~(nextFloorButton1 | nextFloorButton2);

endmodule // SubGive
