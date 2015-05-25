`timescale 1ns / 1ps
module Elevator(
                input        reset,
                input [8:0]  Button,
                input [3:0]  TargetFloor,
                input        clk,
                output [2:0] FloorCurrent,
                output [1:0] DirectCurrent,
                output       DoorCurrent,
                output       TargetOff  //Signal for Change a Target Floor
                );

   parameter CLK_DELAY_OPEN = 50,
     CLK_DELAY_CLOSE = 50,
     CLK_DELAY_MOVE = 1000,
     OPEN = 1'b1, CLOSE = 1'b0,
     UP = 2'b10, DOWN = 2'b01;

   reg [2:0]                 Floor; // Invalid, 1, 2, 3, 4, 5, 6, 7
   reg [1:0]                 Direct; // {Up?, Down?}
   reg                       DoorState; // Open?
   reg [31:0]                counter; //Clock counter

   always @ (posedge clk)
     begin
        if (reset == 1)
          begin
             Floor     = 3'b001;
             Direct    = 2'b00;
             DoorState = 1'b0;
             counter   = 32'b0000_0000__0000_0000__0000_0000__0000_0000;
          end
        if (counter == 0)
          begin
             if (Direct == 2'b00)
               begin
                  if (TargetFloor != 4'b0000)
                    begin
                       Direct <= {(TargetFloor > Floor), (TargetFloor < Floor)};
                    end
                  if (TargetFloor == Floor)
                    begin
                       DoorState <= OPEN;
                       counter <= CLK_DELAY_OPEN;
                    end
               end // if (Direct == 2'b00)
          end // if (counter == 0)
        else
          begin
             counter <= counter - 1;
          end // else: !if(counter == 0)
     end // always @ (posedge clk)

endmodule // Elevator
