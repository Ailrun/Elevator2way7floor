`timescale 1ns / 1ps

module ElevatorControlWCommunicator#(parameter CLKFRQ = 100000000,
                                     BAUDRATE = 9600,
                                     CLK_PER_OPEN = 5,
                                     CLK_PER_MOVE = 10,
                                     CLK_PER_HOLD = 5)
   (
    input  clk,
    input  reset,
    input  en,
    input  rx,
    output tx
    );

   wire [11:0] currentRealFloorButton;
   wire [9:1]  currentInternalButton1, currentInternalButton2,
               currentInternalButton3;
   wire [2:0]  currentFloor1, currentFloor2, currentFloor3;
   wire [1:0]  currentDirection1, currentDirection2, currentDirection3;
   wire        doorState1, doorState2, doorState3;

   wire [11:0] newRealFloorButton;
   wire [9:1]  newInternalButton1, newInternalButton2, newInternalButton3;

   EleCon2Ard#(CLKFRQ, BAUDRATE)
   eleCon2Ard(.clk(clk), .reset(reset), .tx(tx),
              .currentRealFloorButton(currentRealFloorButton),
              .currentInternalButton1(currentInternalButton1),
              .currentFloor1(currentFloor1),
              .currentDirection1(currentDirection1),
              .doorState1(doorState1),
              .currentInternalButton2(currentInternalButton2),
              .currentFloor2(currentFloor2),
              .currentDirection2(currentDirection2),
              .doorState2(doorState2),
              .currentInternalButton3(currentInternalButton3),
              .currentFloor3(currentFloor3),
              .currentDirection3(currentDirection3),
              .doorState3(doorState3));

   Ard2EleCon#(CLKFRQ, BAUDRATE)
   ard2EleCon(.clk(clk), .reset(reset), .en(en) .rx(rx),
              .newRealFloorButton(newRealFloorButton),
              .newInternalButton1(newInternalButton1),
              .newInternalButton2(newInternalButton2),
              .newInternalButton3(newInternalButton3));

   ElevatorController#(CLK_PER_OPEN, CLK_PER_MOVE, CLK_PER_HOLD)
   eleCon(.clk(clk), .reset(reset),
          .newRealFloorButton(newRealFloorButton),
          .newInternalButton1(newInternalButton1),
          .newInternalButton2(newInternalButton2),
          .newInternalbutton3(newInternalbutton3)
          .currentRealFloorButton(currentRealFloorButton),
          .currentInternalButton1(currentInternalButton1),
          .currentFloor1(currentFloor1),
          .currentDirection1(currentDirection1),
          .doorState1(doorState1),
          .currentInternalButton2(currentInternalButton2),
          .currentFloor2(currentFloor2),
          .currentDirection2(currentDirection2),
          .doorState2(doorState2)
          .currentInternalButton3(currentInternalButton3),
          .currentFloor3(currentFloor3),
          .currentDirection3(currentDirection3),
          .doorState3(doorState3));

endmodule // ElevatorControlWCommunicator
