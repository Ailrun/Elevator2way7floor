`timescale 1ns / 1ps

`include "Director.vh"
`include "Door.vh"
`include "Lift.vh"
`include "Button.vh"

module Elevator#(parameter CLK_PER_OPEN = 500000000, CLK_PER_MOVE = 1000000000, CLK_PER_HOLD = 10000000)
   (
    input         clk,
    input         reset,
    input [13:0]  floorButton,
    input [9:1]   internalButton,
    output [2:0]  nextFloor,
    output [1:0]  nextDirection,
    output [13:0] nextFloorButton,
    output [9:1]  nextInternalButton,
    output        doorState,
    output        move
    );

   localparam ON = 1'b1, OFF = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     OPEN = 1'b1, CLOSE = 1'b0,
     MOVE = 1'b1, HOLD = 1'b0,
     DIREC_STAGE = 2'b00, DOOR_STAGE = 2'b01, LIFT_STAGE = 2'b10, BUTTON_STAGE = 2'b11;

   reg [2:0]     currentFloor;
   reg [1:0]     currentDirection;
   reg           doorStateSave;
   reg           moveSave;
   reg [1:0]     sequenceChecker;

   Director#()
   director((clk && (sequenceChecker == 0)), reset,
            currentFloor, currentDirection, floorButton, internalButton,
            doorState, move,
            nextDirection);

   Door#(CLK_PER_OPEN)
   door((clk && (sequenceChecker == 1)), (reset || move),
        currentFloor, currentDirection,
        getCurrent(floorButton, currentFloor), internalButton,
        doorState);

   Lift#(CLK_PER_MOVE, CLK_PER_HOLD)
   lift((clk && (sequenceChecker == 2)), reset,
        doorState, currentFloor, currentDirection,
        nextFloor, move);

   Button#()
   button((clk && (sequenceChecker == 3)), reset,
          currentFloor, currentDirection,
          getCurrent(floorButton, currentFloor), internalButton, doorState, move,
          nextFloorButton, nextInternalButton);

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             currentFloor <= 1;
             currentDirection <= STOP;
             sequenceChecker <= DIREC_STAGE;
          end
        else
          sequenceChecker <= sequenceChecker + 1;
     end // always @ (posedge clk)

   function [1:0] getCurrent;
      input [13:0] floorButton;
      input [2:0]  currentFloor;
      begin
         getCurrent = (currentFloor == 1) ? floorButton[1:0] :
                      (currentFloor == 2) ? floorButton[3:2] :
                      (currentFloor == 3) ? floorButton[5:4] :
                      (currentFloor == 4) ? floorButton[7:6] :
                      (currentFloor == 5) ? floorButton[9:8] :
                      (currentFloor == 6) ? floorButton[11:10] :
                      (currentFloor == 7) ? floorButton[13:12] : 2'b00;
      end
   endfunction // getCurrent

endmodule
