`timescale 1ns / 1ps

module Lift#(parameter CLK_PER_MOVE = 10, CLK_PER_HOLD = 10)
   ( //third
     input            clk,
     input            enable,
     input            reset,
     input            doorState,
     input [2:0]      currentFloor,
     input [1:0]      currentDirection,
     output reg [2:0] nextFloor,
     output reg       move
     );

   localparam ON = 1'b1, OFF = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     MOVE = 1'b1, HOLD = 1'b0,
     INIT = 32'b0,
     F_FST = 3'b1;

   reg [31:0]         counter;

   /*
    when move is on, nextFloor is a 'post' Floor of Ele.
    (Not a past Floor)
    */

   always @(posedge clk or posedge reset)
     begin
        if (reset == ON)
          begin
             nextFloor <= F_FST;
             move <= OFF;
             counter <= INIT;
          end
        else if (enable == ON)
          begin
             if (counter == INIT)
               begin
                  if (doorState == ON || move == MOVE)
                    begin
                       nextFloor <= currentFloor;
                       move <= HOLD;
                       counter <= CLK_PER_HOLD;
                    end
                  else
                    begin
                       case (currentDirection)
                         STOP :
                           begin
                              nextFloor <= currentFloor;
                              move <= HOLD;
                           end
                         UP :
                           begin
                              if (currentFloor < 7)
                                begin
                                   nextFloor <= currentFloor + 1;
                                   move <= MOVE;
                                   counter <= CLK_PER_MOVE;
                                end
                              else
                                $display("ERROR in Lift!(UP)\n");
                           end // case: UP
                         DOWN :
                           begin
                              if (currentFloor > 1)
                                begin
                                   nextFloor <= currentFloor - 1;
                                   move <= MOVE;
                                   counter <= CLK_PER_MOVE;
                                end
                              else
                                $display("ERROR in Lift!(DOWN)\n");
                           end // case: DOWN
                         UPDOWN :
                           begin
                              $display("ERROR in Lift!(UPDOWN)\n");
                           end
                       endcase // case (currentDirection)
                    end // else: !if(move == MOVE)
               end // if (counter == INIT)
             else
               begin
                  counter <= counter - 1;
               end // else: !if(counter == INIT)
          end // else: !if(reset == 1)
        else
          begin
             nextFloor <= currentFloor;
          end // else: !if(enable == ON)
     end // always @ (posedge clk)
endmodule // Lift
