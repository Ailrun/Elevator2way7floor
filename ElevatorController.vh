`timescale 1ns / 1ps

`include "Elevator.vh"

module ElevatorController#(parameter CLK_PER_OPEN = 100000000, CLK_PER_MOVE = 200000000, CLK_PER_HOLD = 2000000)
   (
    input         clk,
    input         reset,
    input [11:0]  realFloorButton,
    input [9:1]   realInternalButton1,
    input [9:1]   realInternalButton2,
    output [11:0] nextRealFloorButton,
    output [9:1]  nextRealInternalButton1,
    output [9:1]  nextRealInternalButton2,
    output [2:0]  nextFloor1,
    output [2:0]  nextFloor2,
    output [1:0]  nextDirection1,
    output [1:0]  nextDirection2,
    output        doorState1,
    output        doorState2.
    output        move1,
    output        move2
    );

   localparam ON = 1'b1, OFF = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     OPEN = 1'b1, CLOSE = 1'b0,
     INIT = 2'b00, COUNT_MAX = 2'b11;

   reg [13:0]     unusedFloorButton;
   reg [13:0]     floorButton1;
   reg [13:0]     floorButton2;
   reg [9:1]      internalButton1;
   reg [9:1]      internalButton2;

   wire [13:0]    nextUnusedFloorButton = (unusedFloorButton |
                                           {0, realFloorButton, 0});
   wire [13:0]     nextFloorButton1;
   wire [13:0]     nextFloorButton2;
   wire [9:1]      nextInternalButton1;
   wire [9:1]      nextInternalButton2;

   reg [1:0]       counter;

   integer         i;

   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele1(clk, reset, floorButton1, internalButton1,
        nextFloor1, nextDirection1, nextFloorButton1, nextInternalButton1,
        doorState1, move1);
   Elevator#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   ele2(clk, reset, floorButton2, internalButton2,
        nextFloor2, nextDirection2, nextFloorButton2, nextInternalButton2,
        doorState2, move2);

   always @(posedge clk)
     begin
        if (reset == 1)
          begin
             unusedFloorButton <= 14'0;
             floorButton1 <= 14'b0;
             floorButton2 <= 14'b0;
             internalButton1 <= 9'b0;
             internalButton2 <= 9'b0;
             counter <= INIT;
          end
        else if (counter == INIT)
          begin
             internalButton1 <= nextInternalButton1 | realInternalButton1;
             internalButton2 <= nextInternalButton2 | realInternalButton2;
             for (i = 1; i < 8; i = i + 1)
               begin
                  if (move1 == STOP && doorState1 == )
                  floorButton1[2*i-1] <= (i==7)?0:
                      (nextFloorButton1[2*i-1] && ());
                  floorButton1[2*i-2] <= (i==1)?0:
                                         (nextFloorButton1[2*i-2] && ());
                  floorButton2[2*i-1] <= (i==7)?0:
                                         (nextFloorButton2[2*i-1] && ());
                  floorButton2[2*i-2] <= (i==1)?0:
                                         (nextFloorButton2[2*i-2] && ());
               end
          end // else: !if(reset == 1)
     end // always @ (posedge clk)

   function [13:0] setUpper

   function isIn;
      input [1:0] currentDirection;
      input [1:0] currentFloorButton;
      begin
         case (currentDirection)
           STOP   : isIn = (currentFloorButton == STOP);
           UP     : isIn = (currentFloorButton == UP
                            || currentFloorButton == UPDOWN);
           DOWN   : isIn = (currentFloorButton == DOWN
                            || currentFloorButton == UPDOWN);
           UPDOWN : $display("ERROR in Door!");
         endcase // case (currentDirection)
      end
   endfunction // isIn

endmodule // ElevatorController
