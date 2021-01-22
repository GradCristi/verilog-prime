`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:29:55 11/28/2011
// Design Name:
// Module Name:    registers
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module registers(
        clk,
        oe,
        we,
        addr,
        in,
        out,
        disp_addr,
        disp_out
    );

parameter width = 16;
parameter depth = 8;
parameter addr_width = 3;

input clk;
input oe;
input we;
input [addr_width-1 : 0]    addr;
input [width-1 : 0]         in;
output[width-1 : 0]         out;
input [addr_width-1 : 0]    disp_addr;
output[width-1 : 0]         disp_out;

reg [width-1 : 0]           regs[depth-1 : 0];

reg [addr_width : 0]        i;

initial begin
    for(i = 0; i < depth; i = i + 1)
        regs[i] <= 0;
end

always @(posedge clk) begin
    if(we)
        regs[addr] <= in;
end

assign out = oe ? regs[addr] : 0;
assign disp_out = regs[disp_addr];

endmodule
