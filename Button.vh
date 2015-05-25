`timescale 1ns / 1ps
module Button // after Door, Director, before Lift
  (
   input         clk,
   input         reset,
   input [2:0]   currentFloor,
   input [1:0]   currentDirection,
   input [13:0]  floorButton,
   input [9:1]   currentButton,
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
        if (reset == 1)
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
                       nextFloorButton[i] <= (i/2 == currentFloor)?
                                   floorButton[i] & ~currentDirection[i-i/2*2]:
                                   floorButton[i];
                    end
                  for (integer i = 1; i < 10; i = i + 1)
                    begin
                       nextButton[i] <= (i == currentFloor-1)?
                                   0 : currentButton[i];
                    end
               end // if (doorState == OPEN)
             else
               begin
                  for (integer i = 1; i < 10; i = i + 1)
                    begin
                       nextButton[i] <= (i == currentFloor-1)?
                                   0 : currentButton[i];
                    end
               end // else: !if(doorState == OPEN)
          end // else: !if(reset == 1)
     end // always @ (posedge clk)
endmodule // Button
