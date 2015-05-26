`timescale 1ns / 1ps

module Button
  ( //last
    input             clk,
    input             enable,
    input             reset,
    input [2:0]       currentFloor,
    input [1:0]       currentDirection,
    input [13:0]      currentFloorButton,
    input [9:1]       internalButton,
    input             doorState,
    input             move,
    output reg [13:0] nextFloorButton,
    output reg [9:1]  nextInternalButton
    );

   localparam NO_FB = 14'b0, NO_B = 9'b0,
     OPEN = 1'b1, CLOSE = 1'b0,
     ON = 1'b1, OFF = 1'b0,
     MOVE = 1'b1, HOLD = 1'b0;

   integer       ind0, ind1, ind2;

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             nextFloorButton <= NO_FB;
             nextInternalButton <= NO_B;
          end
        else if (enable == ON)
          begin
             if (doorState == OPEN)
               begin
                  for (ind0 = 0; ind0 < 14; ind0 = ind0 + 1)
                    begin
                       nextFloorButton[ind0] <= (ind0/2 == currentFloor-1)?
                           currentFloorButton[ind0] & ~currentDirection[ind0-ind0/2*2]:
                           currentFloorButton[ind0];
                    end
                  for (ind1 = 1; ind1 < 10; ind1 = ind1 + 1)
                    begin
                       nextInternalButton[ind1] <= (ind1 == currentFloor)?
                           OFF : internalButton[ind1];
                    end
               end // if (doorState == OPEN)
             else if (move == HOLD)
               begin
                  for (ind2 = 1; ind2 < 10; ind2 = ind2 + 1)
                    begin
                       nextInternalButton[ind2] <= (ind2 == currentFloor)?
                           OFF : internalButton[ind2];
                    end
               end
          end // else: !if(reset == ON)
     end // always @ (posedge clk)
endmodule // Button
