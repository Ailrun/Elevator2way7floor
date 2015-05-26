`timescale 1ns / 1ps
module Button
  ( //last
    input         clk,
    input         reset,
    input [2:0]   currentFloor,
    input [1:0]   currentDirection,
    input [1:0]   currentFloorButton,
    input [9:1]   internalButton,
    input         doorState,
    output [13:0] nextFloorButton,
    output [9:1]  nextButton
    );

   localparam NO_FB = 14'b0, NO_B = 9'b0,
     OPEN = 1'b1, CLOSE = 1'b0,
     ON = 1'b1, OFF = 1'b0;

   reg [13:0]    nextFloorButton;
   reg [9:1]     nextButton;

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             nextFloorButton <= NO_FB;
             nextButton <= NO_B;
          end
        else
          begin
             if (doorState == OPEN)
               begin
                  for (integer i = 0; i < 14; i = i + 1)
                    begin
                       nextFloorButton[i] <= (i/2 == currentFloor-1)?
                                   floorButton[i] & ~currentDirection[i-i/2*2]:
                                   floorButton[i];
                    end
                  for (integer i = 1; i < 10; i = i + 1)
                    begin
                       nextButton[i] <= (i == currentFloor)?
                                   OFF : internalButton[i];
                    end
               end // if (doorState == OPEN)
             else if (move == HOLD)
               begin
                  for (integer i = 1; i < 10; i = i + 1)
                    begin
                       nextButton[i] <= (i == currentFloor)?
                                   OFF : internalButton[i];
                    end
               end
          end // else: !if(reset == ON)
     end // always @ (posedge clk)
endmodule // Button
