`timescale 1ns / 1ps

module Lift#(parameter CLK_PER_MOVE = 1000000000, CLK_PER_HOLD = 10000000)
   ( //third
     input            clk,
     input            reset,
     input            doorState,
     input [2:0]      currentFloor,
     input [1:0]      currentDirection,
     output reg [2:0] nextFloor,
     output reg       move
     );

   localparam ON = 1'b1, OFF = 1'b0,
     STOP = 2'b00, UP = 2'b10, DOWN = 2'b01, UPDOWN = 2'b11,
     INIT = 32'b0,
     F_FST = 3'b1;

   reg [31:0]    counter;

   /*
    when move is on, nextFloor is a 'post' Floor of Ele.
    (Not a past Floor)
    */

   always @(posedge clk)
     begin
        if (reset == ON)
          begin
             nextFloor <= F_FST;
             move <= OFF;
             counter <= INIT;
          end
        else
          begin
             if (counter == INIT)
               begin
                  if (doorState == ON)
                    begin
                       nextFloor <= currentFloor;
                       move <= OFF;
                       counter <= CLK_PER_HOLD;
                    end
                  else if (move == ON)
                    begin
                       nextFloor <= currentFloor;
                       move <= OFF;
                       counter <= CLK_PER_HOLD;
                    end
                  else
                    begin
                       case (currentDirection)
                         STOP :
                           begin
                              nextFloor <= currentFloor;
                              move <= OFF;
                           end
                         UP :
                           begin
                              if (currentFloor < 7)
                                begin
                                   nextFloor <= currentFloor + 1;
                                   move <= ON;
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
                                   move <= ON;
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
     end // always @ (posedge clk)
endmodule // Lift
