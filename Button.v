`timescale 1ns / 1ps

module Button
  ( //last
    input wire        clk,
    input wire        enable,
    input wire        reset,
    input wire [2:0]  currentFloor,
    input wire [1:0]  currentDirection,
    input wire [13:0] currentFloorButton,
    input wire [9:1]  internalButton,
    input wire        doorState,
    input wire        move,
    output reg [13:0] nextFloorButton,
    output reg [9:1]  nextInternalButton
    );

   localparam NO_FB = 14'b0, NO_B = 9'b0,
     OPEN = 1'b1, CLOSE = 1'b0,
     ON = 1'b1, OFF = 1'b0,
     MOVE = 1'b1, HOLD = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11;

   integer            ind0, ind1, ind2;


   always @(posedge clk or posedge reset)
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
                  if (currentDirection & UPDOWN)
                    begin
                       for (ind0 = 0; ind0 < 14; ind0 = ind0 + 1)
                        begin
                           nextFloorButton[ind0] <= (ind0/2 == currentFloor-1)?
                                   currentFloorButton[ind0] &
                                   ~currentDirection[ind0-ind0/2*2] :
                                   currentFloorButton[ind0];
                        end
                    end
                  else
                    begin
                       for (ind0 = 0; ind0 < 14; ind0 = ind0 + 1)
                         begin
                            nextFloorButton[ind0] <= (ind0/2 == currentFloor-1)?
                                   currentFloorButton[ind0] &
                                   ((ind0-ind0/2*2)?
                                    currentFloorButton[ind0-1]:
                                    OFF):
                                   currentFloorButton[ind0];
                         end
                    end // else: !if(currentDirection & UPDOWN)
                  for (ind1 = 1; ind1 < 10; ind1 = ind1 + 1)
                    begin
                       nextInternalButton[ind1] <= (ind1 == currentFloor ||
                                                    ind1 == 9)?
                              OFF : internalButton[ind1];
                    end
               end // if (doorState == OPEN)
             else if (move == HOLD)
               begin
                  nextFloorButton <= currentFloorButton;
                  for (ind2 = 1; ind2 < 10; ind2 = ind2 + 1)
                    begin
                       nextInternalButton[ind2] <= (ind2 == currentFloor ||
                                                    ind2 == 8)?
                              OFF : internalButton[ind2];
                    end
               end
             else
               begin
                  nextFloorButton <= currentFloorButton;
                  nextInternalButton[7:1] <= internalButton[7:1];
                  nextInternalButton[9:8] <= 0;
               end // else: !if(move == HOLD)
          end // else: !if(reset == ON)
        else
          begin
             nextFloorButton <= currentFloorButton;
             nextInternalButton <= internalButton;
          end // else: !if(enable == ON)
     end // always @ (posedge clk)
endmodule // Button
