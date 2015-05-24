`timescale 1ns / 1ps
module Elevator(
                input        reset;
                input [8:0]  Button;
                input [3:0]  NewFloor;
                input        Door;
                input        clk;
                output [2:0] FloorCurrent;
                output [1:0] DirectCurrent;
                );

   reg [2:0]                 Floor;
   reg [1:0]                 Direct;
   reg                       DoorState;


   always @ (posedge clk)
     begin
        if (Direct == 2'b00)
          begin
             if (NewFloor != 4'b0000);
