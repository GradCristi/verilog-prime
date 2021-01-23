`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:       UPB
// Engineer:      Dan Dragomir
//
// Create Date:   13:32:41 12/20/2013
// Design Name:   tester tema3
// Module Name:   tester
// Project Name:  tema3
// Target Device: ISim
// Tool versions: 14.6
// Description:   tester for homework 3: calculatorul didactic
////////////////////////////////////////////////////////////////////////////////

module tester;

parameter early_exit = 0;                   // boolean; bail on first error
parameter show_output = 1;                  // boolean; show what is being tested

reg [16*8-1:0] test_name;
real test_value;
real test_penalty;
integer first_instr;                        // first instruction that counts for grading
integer max_instr_count;                    // number of instructions to execute for grading
integer max_instr_cycles;                   // maximum cycles for an instruction
integer ignore_ind;                         // ignore IND mismatches

integer config_file;
initial begin
    config_file = $fopen("test.config", "r");
    if(!config_file) begin
        $write("error opening config file\n");
        $finish;
    end
    if($fscanf(config_file, "name=%16s\n", test_name) != 1) begin
        $write("error reading test name\n");
        $finish;
    end
    if($fscanf(config_file, "value=%f\n", test_value) != 1) begin
        $write("error reading test value\n");
        $finish;
    end
    if($fscanf(config_file, "penalty=%f\n", test_penalty) != 1) begin
        $write("error reading test penalty\n");
        $finish;
    end
    if($fscanf(config_file, "first_instr=%d\n", first_instr) != 1) begin
        $write("error reading first instruction counted for grading\n");
        $finish;
    end
    if($fscanf(config_file, "max_instr_count=%d\n", max_instr_count) != 1) begin
        $write("error reading number of instructions to execute\n");
        $finish;
    end
    if($fscanf(config_file, "max_instr_cycles=%d\n", max_instr_cycles) != 1) begin
        $write("error reading number of cycles to allow for a instruction\n");
        $finish;
    end
    if($fscanf(config_file, "ignore_ind=%d\n", ignore_ind) != 1) begin
        $write("error reading flag for ignoring IND mismatches\n");
        $finish;
    end
    $fclose(config_file);
end

// Tester
reg clk;                                    // master clock
reg rst;                                    // master reset
wire disp_clk;                              // clock used for display ports

// Instantiate the Unit Under Test (UUT)
wire tst_clk;
wire tst_io_oe;
wire tst_io_we;
wire [7:0] tst_io_port;
wire [15:0] tst_io_in;
reg [15:0] tst_io_out = 0;
reg [11:0] tst_addr;
reg [11:0] tst_reg_addr;
wire [15:0] tst_data;
wire [15:0] tst_reg_data;
wire [15:0] tst_state;
wire [15:0] tst_cp;
wire [15:0] tst_ind;
wire [15:0] tst_am;
wire [15:0] tst_aie;
wire [15:0] tst_t1;
wire [15:0] tst_t2;
wire [15:0] tst_ri;
wire [15:0] tst_mag;
calc_didactic uut (
    .clk(tst_clk),
    .rst(rst),
    .io_oe(tst_io_oe),
    .io_we(tst_io_we),
    .io_port(tst_io_port),
    .io_in(tst_io_in),
    .io_out(tst_io_out),
    .disp_clk(disp_clk),
    .disp_addr(tst_addr),
    .disp_data(tst_data),
    .disp_reg_addr(tst_reg_addr),
    .disp_reg_data(tst_reg_data),
    .disp_state(tst_state),
    .disp_cp(tst_cp),
    .disp_ind(tst_ind),
    .disp_am(tst_am),
    .disp_aie(tst_aie),
    .disp_t1(tst_t1),
    .disp_t2(tst_t2),
    .disp_ri(tst_ri),
    .disp_mag(tst_mag)
);

// Instantiate reference implementation
wire ref_clk;
wire ref_io_oe;
wire ref_io_we;
wire [7:0] ref_io_port;
wire [15:0] ref_io_in;
reg [15:0] ref_io_out = 0;
reg [11:0] ref_addr;
reg [11:0] ref_reg_addr;
wire [15:0] ref_data;
wire [15:0] ref_reg_data;
wire [15:0] ref_state;
wire [15:0] ref_cp;
wire [15:0] ref_ind;
wire [15:0] ref_am;
wire [15:0] ref_aie;
wire [15:0] ref_t1;
wire [15:0] ref_t2;
wire [15:0] ref_ri;
wire [15:0] ref_mag;
ref_calc_didactic ref (
    .clk(ref_clk),
    .rst(rst),
    .io_oe(ref_io_oe),
    .io_we(ref_io_we),
    .io_port(ref_io_port),
    .io_in(ref_io_in),
    .io_out(ref_io_out),
    .disp_clk(disp_clk),
    .disp_addr(ref_addr),
    .disp_data(ref_data),
    .disp_reg_addr(ref_reg_addr),
    .disp_reg_data(ref_reg_data),
    .disp_state(ref_state),
    .disp_cp(ref_cp),
    .disp_ind(ref_ind),
    .disp_am(ref_am),
    .disp_aie(ref_aie),
    .disp_t1(ref_t1),
    .disp_t2(ref_t2),
    .disp_ri(ref_ri),
    .disp_mag(ref_mag)
);

// Tester
reg [15:0] tst_prev_cp;                     // previous value of tst_cp
reg [15:0] tst_prev_ri;                     // previous value of tst_ri
reg [15:0] ref_prev_ri;                     // previous value of ref_ri

integer state;                              // tester FSM state
`define RUN         0                       // execute instruction
`define CHECK_REGS  1                       // check values in register file
`define CHECK_RAM   2                       // check values in RAM
`define NEXT        3                       // prepare for next instruction
`define RESULT      4                       // write results

integer instr_ok;                           // true if instruction was executed correcly
integer instr_cycles;                       // cycles used by tst for current instruction
integer instr_count;                        // number of instructions executed correctly

reg signed [9:0] done_instr;                // number of graded instructions executed correctly
reg signed [9:0] total_instr;               // total number of graded instructions

real result;                                // test passed percentage
integer file;                               // results file

initial begin
    // initialize inputs
    clk = 0;
    rst = 0;
    state = `RUN;

    tst_prev_ri = 0;
    tst_prev_cp = 0;
    ref_prev_ri = 0;

    instr_ok = 1;
    instr_cycles = 0;
    instr_count = 0;

    tst_addr = 0;
    tst_reg_addr = 0;
    ref_addr = 0;
    ref_reg_addr = 0;

    rst = 1;
    #40
    rst = 0;
end

always #5 clk = !clk;

// tst clock is active until tst RI changes
assign tst_clk = (tst_ri == tst_prev_ri) ? clk : 0;

// ref clock is active until ref RI changes
assign ref_clk = (ref_ri == ref_prev_ri) ? clk : 0;

// display port clock is always active
assign disp_clk = clk;

always @(posedge clk) begin
    case(state)
        `RUN: begin
            if(tst_ri == tst_prev_ri)
                instr_cycles <= instr_cycles + 1;

            if(tst_ri != tst_prev_ri && ref_ri != ref_prev_ri) begin
                if(ref_prev_ri != 0) begin
                    if(show_output) $write(" done in %0d cycles\n", instr_cycles);
                end
                else begin
                    $write("--------------------------------------------------------------------------------\n");
                end

                state <= `CHECK_REGS;

                if(tst_cp !== ref_cp) begin
                    $write("\tCPs diverged: found %x, expected %x\n", tst_cp, ref_cp);
                    $write("\t\tat instr count: %0d, instr addr: %x, instr: %x\n", instr_count, tst_prev_cp, tst_prev_ri);

                    instr_ok <= 0;
                    if(early_exit) begin
                        instr_count <= instr_count - 1;
                        state <= `RESULT;
                    end
                end

                if(tst_ind !== ref_ind) begin
                    $write("\tINDs differ: found (");
                    if(tst_ind[4])
                        $write("P");
                    if(tst_ind[3])
                        $write("S");
                    if(tst_ind[2])
                        $write("Z");
                    if(tst_ind[1])
                        $write("O");
                    if(tst_ind[0])
                        $write("C");
                    $write("), expected (");
                    if(ref_ind[4])
                        $write("P");
                    if(ref_ind[3])
                        $write("S");
                    if(ref_ind[2])
                        $write("Z");
                    if(ref_ind[1])
                        $write("O");
                    if(ref_ind[0])
                        $write("C");
                    $write(")\n");
                    $write("\t\tat instr count: %0d, instr addr: %x, instr: %x\n", instr_count, tst_prev_cp, tst_prev_ri);

                    if(!ignore_ind) begin
                        instr_ok <= 0;
                        if(early_exit) begin
                            instr_count <= instr_count - 1;
                            state <= `RESULT;
                        end
                    end
                end
            end
            else if(instr_cycles == max_instr_cycles) begin
                if(show_output) $write("\n");

                $write("\ttimeout after %0d cycles\n", instr_cycles);
                $write("\t\tat instr count: %0d, instr addr: %x, instr: %x\n", instr_count, tst_cp, tst_ri);

                instr_ok <= 0;
                instr_count <= instr_count - 1;
                state <= `RESULT;
            end
        end

        `CHECK_REGS: begin
            tst_reg_addr <= (tst_reg_addr + 1) % 8;
            ref_reg_addr <= (ref_reg_addr + 1) % 8;

            if(tst_reg_addr == 7)
                state <= `CHECK_RAM;

            if(ref_reg_data !== tst_reg_data) begin
                $write("\treg %0d differs, found: %x, expected: %x\n", tst_reg_addr, tst_reg_data, ref_reg_data);
                $write("\t\tat instr count: %0d, instr addr: %x, instr: %x\n", instr_count, tst_prev_cp, tst_prev_ri);

                instr_ok <= 0;
                if(early_exit) begin
                    instr_count <= instr_count - 1;
                    state <= `RESULT;
                end
            end
        end

        `CHECK_RAM: begin
            tst_addr <= tst_addr + 1;
            ref_addr <= ref_addr + 1;

            if(tst_addr == 1024) begin
                tst_addr <= 0;
                ref_addr <= 0;
                state <= `NEXT;
            end

            if(tst_addr != 0 && ref_data !== tst_data) begin
                $write("\tram addr %x differs, found: %x, expected: %x\n", tst_addr - 1, tst_data, ref_data);
                $write("\t\tat instr count: %0d, instr addr: %x, instr: %x\n", instr_count, tst_prev_cp, tst_prev_ri);

                instr_ok <= 0;
                if(early_exit) begin
                    instr_count <= instr_count - 1;
                    state <= `RESULT;
                end
            end
        end

        `NEXT: begin
            if(!instr_ok) begin
                instr_count <= instr_count - 1;
                state <= `RESULT;
            end
            else if(instr_count == max_instr_count) begin
                $write("test ok\n");
                state <= `RESULT;
            end
            else begin
                tst_prev_cp <= tst_cp;
                tst_prev_ri <= tst_ri;
                ref_prev_ri <= ref_ri;
                instr_ok <= 1;
                instr_count <= instr_count + 1;
                instr_cycles <= 0;
                state <= `RUN;

                if(show_output) $write("instr count: %0d, instr addr: %x, instr: %x", instr_count + 1, ref_cp, ref_ri);
            end
        end

        `RESULT: begin
            $write("--------------------------------------------------------------------------------\n");

            total_instr = (max_instr_count - first_instr + 1);
            done_instr = (instr_count - first_instr + 1);
            done_instr = done_instr < 0 ? 0 : done_instr;
            result = done_instr * 1.0 / total_instr;

            file = $fopen("result.tester");
            $fwrite(file, "%5.2f: %d out of %d instructions (%6.2f%% completed) test %0s\n", test_value * (result - test_penalty), done_instr, total_instr, 100.0 * result, test_name);
            $fclose(file);
            $finish;
        end
    endcase
end

endmodule
