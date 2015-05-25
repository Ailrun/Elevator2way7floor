`timescale 1ns / 1ps
module Elevator#(parameter CLK_DELAY_OPEN = 500000000, CLK_DELAY_MOVE = 1000000000)
   (
    input        clk,
    input        reset,
    input [9:1]  Button,
    input [2:0]  TargetFloor,
    input [1:0]  TargetDirect,
    output [2:0] FloorOut,
    output [1:0] DirectOut,
    output       DoorOut,
    );

   localparam OPEN = 1'b1, CLOSE = 1'b0, BUTTON_O = 9, BUTTON_C = 8,
     UP = 2'b10, DOWN = 2'b01,
     COUNTER_ZERO = 32'b0000_0000__0000_0000__0000_0000__0000_0000;

   reg [2:0]     Floor;     // Invalid, 1, 2, ..., 7
   reg [1:0]     Direct;    // {Up?, Down?}
   reg           DoorState; // Open?
   reg [31:0]    counter;   //Clock counter


   function maskMake;
      input [2:0] Floor;

      begin
         for (integer i = 0; i < NUM_FLOOR; i = i + 1)
           maskMake[i] <= (i != Floor);
      end
   endfunction


   function closestB;
      input [7:1] Button;
      input [2:0] Floor;

      begin
         if (Floor + 1 < 7)
           if (Button[Floor + 1] )
      end
   endfunction

   always @ (posedge clk)
     begin
        if (reset == 1)
          begin
             Floor           <= 3'b001;
             Direct          <= 2'b00;
             DoorState       <= 1'b0;
             counter         <= COUNTER_ZERO;
          end
        else
          begin
             if (counter == 0)
               begin
                  if (Direct == 2'b00)
                    begin
                       if ((Button[7:1] & maskMake(Floor) != 7'b000_0000)
                         begin
                            Direct <= {(closestB(Button[7:1], Floor) > Floor),
                                       (closestB(Button[7:1], Floor) < Floor)};
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
             else if (DoorState == OPEN && Button[BUTTON_O])
               begin
                  counter <= CLK_DELAY_OPEN;
               end
             else if (DoorState == OPEN && Button[BUTTON_C])
               begin
                  counter <= 0;
               end
             else
               begin
                  counter <= counter - 1;
               end // else: !if(counter == 0)
          end // else: !if(reset == 1)
     end // always @ (posedge clk)
endmodule // Elevator
