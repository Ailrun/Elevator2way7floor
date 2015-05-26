`timescale 1ns / 1ps
module Director
  ( //first
    input        clk,
    input        reset,
    input [2:0]  currentFloor,
    input [1:0]  currentDirection,
    input [13:0] floorButton,
    input [9:1]  internalButton,
    input        doorState,
    input        move,
    output [1:0] nextDirection
    );

   localparam ON = 1'b1, OFF = 1'b0,
     MOVE = 1'b1, HOLD = 1'b0,
     OPEN = 1'b1, CLOSE = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11;

   reg [1:0]    nextDirection;

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             nextDirection <= STOP;
          end
        else if (move == HOLD)
          begin
             if (doorState == CLOSE)
               case (currentDirection)
                 STOP :
                   begin
                      if (anyUpper == ON)
                        nextDirection <= UP;
                      else if (anyLower == ON)
                        nextDirection <= DOWN;
                   end
                 UP :
                   begin
                      if (anyUpper == OFF)
                        begin
                           if (anyLower == ON)
                             nextDirection <= DOWN;
                           else
                             nextDirection <= STOP;
                        end
                   end
                 DOWN :
                   begin
                      if (anyLower == OFF)
                        begin
                           if (anyUpper == ON)
                             nextDirection <= UP;
                           else
                             nextDirection <= STOP;
                        end
                   end
                 UPDOWN :
                   $display("ERROR in Director\n");
               endcase // case (currentDirection)
          end // if (move == HOLD)
     end // always @ (posedge clk)
endmodule // Director
