`timescale 1ns / 1ps
module Door#(parameter CLK_PER_OPEN=500000000)
   (
    input        clk,
    input        reset,
    input [2:0]  currentFloor,
    input [1:0]  currentDirection,
    input [1:0]  currentFloorButton,
    input [9:1]  internalButton,
    output       doorState
    );

   /*reset signal also act a role of moving detector
     (When Ele is moving, reset of door is on)*/



   localparam OPEN_B = 9, CLOSE_B = 8,
     ON = 1'b1, OFF = 1'b0,
     OPEN = 1'b1, CLOSE = 1'b0,
     INIT = 32'b0,
     STOP = 2'b00;

   reg          doorState;
   reg [31:0]   counter;

   /*
    close condition ::
   1. close button is on.
   2. counter goes INIT when door is opened.

    open condition  ::
   1. open button is on when Ele is stoped or door is opened.
   2. currentFloorButton is same with currentDirection, except 2'b00
   3. internalButton is set on this floor when Ele is not stoped.
    */

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             doorOpen <= CLOSE;
             counter  <= INIT;
          end
        else
          begin
             if (currentDirection != STOP
                 && (isIn(currentDirection, currentFloorButton)
                     || internalButton[currentFloor] == ON))
               begin
                  doorState <= OPEN;
                  counter <= CLK_PER_OPEN;
               end
             else if (counter == INIT)
               begin
                  if (doorOpen == OPEN)
                    doorState <= CLOSE;
               end
             else
               begin
                  if (internalButton[OPEN_B] == ON)
                    counter <= CLK_PER_OPEN;
                  else if (internalButton[CLOSE_B] == ON)
                    counter <= INIT;
                  else
                    counter <= counter - 1;
               end // else: !if(counter == INIT)
          end // else: !if(reset == 1)
     end // always @ (posedge clk)
endmodule // Door
