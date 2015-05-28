`timescale 1ns / 1ps

`include "Director.vh"
`include "Door.vh"
`include "Button.vh"
`include "Lift.vh"

module Elevator#(parameter CLK_PER_OPEN = 5, CLK_PER_MOVE = 10, CLK_PER_HOLD = 10)
   (
    input wire         clk,
    input wire         reset,
    input wire [13:0]  floorButton,
    input wire [9:1]   internalButton,
    output [2:0]  nextFloor,
    output [1:0]  nextDirection,
    output [13:0] nextFloorButton,
    output [9:1]  nextInternalButton,
    output        doorState,
    output        move,
         output [1:0]  sequenceChecker
    );

   localparam ON = 1'b1, OFF = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     OPEN = 1'b1, CLOSE = 1'b0,
     MOVE = 1'b1, HOLD = 1'b0,
     DIREC_STAGE = 2'b00, DOOR_STAGE = 2'b01, BUTTON_STAGE = 2'b10, LIFT_STAGE = 2'b11;

   reg [1:0]     sequenceChecker;

   Director
   director(clk, (sequenceChecker == DIREC_STAGE), reset,
            nextFloor, nextDirection, floorButton, internalButton[7:1],
            doorState, move,
            nextDirection);

   Door#(CLK_PER_OPEN)
   door(clk, (sequenceChecker == DOOR_STAGE), (reset || move),
        nextFloor, nextDirection,
        getCurrent(floorButton, nextFloor), internalButton,
        doorState);

   Button
   button(clk, (sequenceChecker == BUTTON_STAGE), reset,
          nextFloor, nextDirection,
          floorButton, internalButton, doorState, move,
          nextFloorButton, nextInternalButton);

   Lift#(CLK_PER_MOVE, CLK_PER_HOLD)
   lift(clk, (sequenceChecker == LIFT_STAGE), reset,
        doorState, nextFloor, nextDirection,
        nextFloor, move);

   always @(posedge clk or posedge reset)
     begin
        if (reset == ON)
          begin
             sequenceChecker <= DIREC_STAGE;
          end
        else
          begin
             sequenceChecker <= sequenceChecker + 1;
          end
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
