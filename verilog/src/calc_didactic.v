`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    11:53:43 11/22/2011
// Design Name:
// Module Name:    calc_didactic
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
module calc_didactic(
        clk,
        rst,
        io_oe,
        io_we,
        io_port,
        io_in,
        io_out,
        disp_clk,
        disp_addr,
        disp_data,
        disp_reg_addr,
        disp_reg_data,
        disp_state,
        disp_cp,
        disp_ind,
        disp_am, disp_aie,
        disp_t1, disp_t2,
        disp_ri,
        disp_mag
    );

parameter addr_width = 12;
parameter port_width = 8;
parameter word_width = 16;

input                       clk;
input                       rst;
output                      io_oe;
output                      io_we;
output[port_width-1 : 0]    io_port;
output[word_width-1 : 0]    io_in;
input [word_width-1 : 0]    io_out;
input                       disp_clk;
input [addr_width-1 : 0]    disp_addr;
output[word_width-1 : 0]    disp_data;
input [addr_width-1 : 0]    disp_reg_addr;
output[word_width-1 : 0]    disp_reg_data;
output[word_width-1 : 0]    disp_state;
output[word_width-1 : 0]    disp_cp;
output[word_width-1 : 0]    disp_ind;
output[word_width-1 : 0]    disp_am, disp_aie;
output[word_width-1 : 0]    disp_t2, disp_t1;
output[word_width-1 : 0]    disp_ri;
output[word_width-1 : 0]    disp_mag;

// instantiate CP register and related connections
wire                        cp_oe;
wire                        cp_we;
wire[word_width-1 : 0]      cp_in;
wire[word_width-1 : 0]      cp_out;
register #(word_width) cp(clk, rst, cp_oe, cp_we, cp_in, cp_out, disp_cp);

// instantiate IND register and related connections
wire                        ind_oe;
wire                        ind_we;
wire[word_width-1 : 0]      ind_in;
wire[word_width-1 : 0]      ind_out;
register #(word_width) ind(clk, rst, ind_oe, ind_we, ind_in, ind_out, disp_ind);

// instantiate AM register and related connections
wire                        am_oe;
wire                        am_we;
wire[word_width-1 : 0]      am_in;
wire[word_width-1 : 0]      am_out;
register #(word_width) am(clk, rst, am_oe, am_we, am_in, am_out, disp_am);

// instantiate AIE register and related connections
wire                        aie_oe;
wire                        aie_we;
wire[word_width-1 : 0]      aie_in;
wire[word_width-1 : 0]      aie_out;
register #(word_width) aie(clk, rst, aie_oe, aie_we, aie_in, aie_out, disp_aie);

// instantiate T1 register and related connections
wire                        t1_oe;
wire                        t1_we;
wire[word_width-1 : 0]      t1_in;
wire[word_width-1 : 0]      t1_out;
register #(word_width) t1(clk, rst, t1_oe, t1_we, t1_in, t1_out, disp_t1);

// instantiate T2 register and related connections
wire                        t2_oe;
wire                        t2_we;
wire[word_width-1 : 0]      t2_in;
wire[word_width-1 : 0]      t2_out;
register #(word_width) t2(clk, rst, t2_oe, t2_we, t2_in, t2_out, disp_t2);

// instantiate RI register and related connections
wire                        ri_oe;
wire                        ri_we;
wire[word_width-1 : 0]      ri_in;
wire[word_width-1 : 0]      ri_out;
register #(word_width) ri(clk, rst, ri_oe, ri_we, ri_in, ri_out, disp_ri);

// instantiate ALU and related connections
wire                        alu_oe;
wire[3 : 0]                 alu_opcode;
wire                        alu_carry;
wire[word_width-1 : 0]      alu_out;
wire[4 : 0]                 alu_flags;
alu #(word_width, 5) alu(alu_oe, alu_opcode, t1_out, t2_out, alu_carry, alu_out, alu_flags);

// instantiate RAM and related connections
//synthesis attribute box_type ram "black_box"
wire                        ram_oe;
wire                        ram_we;
wire[word_width-1 : 0]      ram_in;
wire[word_width-1 : 0]      ram_out;
wire[word_width-1 : 0]      ram_tmp;
ram ram (
  .clka(clk),               // input clka
  .ssra(ram_oe),            // input ssra
  .wea(ram_we),             // input [0 : 0] wea
  .addra(am_out[9:0]),      // input [9 : 0] addra
  .dina(ram_in),            // input [15 : 0] dina
  .douta(ram_tmp),          // output [15 : 0] douta
  .clkb(disp_clk),          // input clkb
  .web(1'b0),               // input [0 : 0] web
  .addrb(disp_addr[9:0]),   // input [9 : 0] addrb
  .dinb(16'b0),             // input [15 : 0] dinb
  .doutb(disp_data)         // output [15 : 0] doutb
);
// it appears ssra does not work correctly in simulation so we need to implement RAM output enable manually
assign ram_out = ram_oe ? ram_tmp : 0;

// create the custom logic for IO port address output
assign io_port = aie_out[port_width-1 : 0];

// instantiate the register file and related connections
wire                        regs_oe;
wire                        regs_we;
wire[2 : 0]                 regs_addr;
wire[word_width-1 : 0]      regs_in;
wire[word_width-1 : 0]      regs_out;
registers #(word_width) regs(clk, regs_oe, regs_we, regs_addr, regs_in, regs_out, disp_reg_addr[2:0], disp_reg_data);

// create the custom logic for IND register input and necessary control signal
wire                        ind_sel;
wire[word_width-1 : 0]      ind_mag;
assign ind_in = ind_sel ? alu_flags : ind_mag;

// create the custom logic for conditional jump offset (RI[8:15]) generation
wire[word_width-1 : 0]      offset_out;
assign offset_out = {{8{ri_out[8]}}, ri_out[8], ri_out[9], ri_out[10], ri_out[11], ri_out[12], ri_out[13], ri_out[14], ri_out[15]};

// instatiate the bus that connects everything toghether
bus #(word_width) mag(alu_out, ram_out, ram_in, io_out, io_in, regs_out, regs_in, cp_out, cp_in, ind_out, ind_mag, am_in, aie_in, t1_in, t2_in, offset_out, ri_in, disp_mag);

// instantiate command unit
uc #(word_width) uc(clk, rst, disp_ri, disp_ind, regs_addr, regs_oe, regs_we, alu_oe, alu_carry, alu_opcode, ram_oe, ram_we, io_oe, io_we, cp_oe, cp_we, ind_sel, ind_oe, ind_we, am_oe, am_we, aie_oe, aie_we, t1_oe, t1_we, t2_oe, t2_we, ri_oe, ri_we, disp_state);

endmodule
