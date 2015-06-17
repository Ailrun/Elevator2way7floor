`timescale 1ns / 1ps

`include "Elevator.vh"
`include "GiveFloorbutton.vh"

module ElevatorController#(parameter CLK_PER_OPEN = 5, CLK_PER_MOVE = 10, CLK_PER_HOLD = 10)
   (
    input         clk,
    input         reset,
    input [11:0]  newRealFloorButton,
    input [9:1]   newInternalButton1,
    input [9:1]   newInternalButton2,
    input [9:1]   newInternalButton3,
    output [2:0]  currentFloor1,
    output [2:0]  currentFloor2,
    output [2:0]  currentFloor3,
    output [1:0]  currentDirection1,
    output [1:0]  currentDirection2,
    output [1:0]  currentDirection3,
    output [11:0] currentRealFloorButton,
    output [9:1]  currentInternalButton1,
    output [9:1]  currentInternalButton2,
    output [9:1]  currentInternalButton3,
    output        doorState1,
    output        doorState2,
    output        doorState3
    );

   reg [13:0]     unusedFloorButtonIn;

   wire [13:0]    newExtendedFloorButton = {1'b0, newRealFloorButton, 1'b0};
   wire [13:0]    currentFloorButton1;
   wire [13:0]    currentFloorButton2;
   wire [13:0]    currentFloorButton3;
   wire [13:0]    nextFloorButton1;
   wire [13:0]    nextFloorButton2;
   wire [13:0]    nextFloorButton3;
   wire [13:0]    unusedFloorButtonOut;
   wire [13:0]    currentExtendedFloorButton =
                  currentFloorButton1 |
                  currentFloorButton2 |
                  currentFloorButton3 |
                  unusedFloorButtonIn;
   assign currentRealFloorButton = currentExtendedFloorButton[12:1];


   wire [9:1]     nextInternalButton1;
   wire [9:1]     nextInternalButton2;
   wire [9:1]     nextInternalButton3;
   assign currentInternalButton1 = nextInternalButton1 | newInternalButton1;
   assign currentInternalButton2 = nextInternalButton2 | newInternalButton2;
   assign currentInternalButton3 = nextInternalButton3 | newInternalButton3;

   GiveFloorButton
     gFB(clk, reset,
         currentFloor1, currentFloor2, currentFloor3, newExtendedFloorButton,
         nextFloorButton1, nextFloorButton2, nextFloorButton3, unusedFloorButtonIn,
         currentDirection1, currentDirection2, currentDirection3,
         currentFloorButton1, currentFloorButton2, currentFloorButton3,
         unusedFloorButtonOut);

   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele1(clk, reset, currentFloorButton1, currentInternalButton1, currentFloor1,
        currentDirection1, nextFloorButton1, nextInternalButton1, doorState1);

   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele2(clk, reset, currentFloorButton2, currentInternalButton2, currentFloor2,
        currentDirection2, nextFloorButton2, nextInternalButton2, doorState2);

   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele3(clk, reset, currentFloorButton3, currentInternalButton3, currentFloor3,
        currentDirection3, nextFloorButton3, nextInternalButton3, doorState3);

   always @(posedge clk)
     begin
        unusedFloorButtonIn <= unusedFloorButtonOut;
     end

endmodule // ElevatorController
