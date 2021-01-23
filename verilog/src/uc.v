`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    20:14:45 11/26/2011
// Design Name:
// Module Name:    uc
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
module uc(
        clk,
        rst,
        ri,
        ind,
        regs_addr,
        regs_oe,
        regs_we,
        alu_oe,
        alu_carry,
        alu_opcode,
        ram_oe,
        ram_we,
        io_oe,
        io_we,
        cp_oe,
        cp_we,
        ind_sel,
        ind_oe,
        ind_we,
        am_oe,
        am_we,
        aie_oe,
        aie_we,
        t1_oe,
        t1_we,
        t2_oe,
        t2_we,
        ri_oe,
        ri_we,
        disp_state
    );

parameter word_width =          16;
parameter state_width =         16;

`define ADC                     0
`define SBB1                    1
`define SBB2                    2
`define NOT                     3
`define AND                     4
`define OR                      5
`define XOR                     6
`define SHL                     7
`define SHR                     8
`define SAR                     9

`define RA                      0
`define RB                      1
`define RC                      2
`define IS                      3
`define XA                      4
`define XB                      5
`define BA                      6
`define BB                      7

input                           clk;
input                           rst;
input [word_width-1 : 0]        ri;
input [word_width-1 : 0]        ind;
output reg                      alu_oe;
output reg                      alu_carry;
output reg[3 : 0]               alu_opcode;
output reg                      ram_oe;
output reg                      ram_we;
output reg                      io_oe;
output reg                      io_we;
output reg[2 : 0]               regs_addr;
output reg                      regs_oe;
output reg                      regs_we;
output reg                      cp_oe;
output reg                      cp_we;
output reg                      ind_sel;        // controls IND register input (0 = bus, 1 = alu flags)
output reg                      ind_oe;
output reg                      ind_we;
output reg                      am_oe;
output reg                      am_we;
output reg                      aie_oe;
output reg                      aie_we;
output reg                      t1_oe;
output reg                      t1_we;
output reg                      t2_oe;
output reg                      t2_we;
output reg                      ri_oe;          // controls RI register output which generates the offset for Jcond instructions
output reg                      ri_we;
output[state_width-1 : 0]       disp_state;

wire [0:6]                      cop;
wire                            d;
wire [0:1]                      mod;
wire [0:2]                      rg;
wire [0:2]                      rm;

assign cop  = {ri[0], ri[1], ri[2], ri[3], ri[4], ri[5], ri[6]};
assign d    = {ri[7]};
assign mod  = {ri[8], ri[9]};
assign rg   = {ri[10], ri[11], ri[12]};
assign rm   = {ri[13], ri[14], ri[15]};

`define reset                   'h00            // reset state
`define fetch                   'h10            // load instruction to instruction register
`define decode                  'h20            // analyze loaded instruction
`define addr_sum                'h30            // computes address of the form [By+Xz] with y,z in {A, B}
`define addr_reg                'h34            // computes address of the form [yz] with y in {X, B} and z in {A, B}
`define load_src_reg            'h40            // load source operand from register
`define load_src_mem            'h44            // load source operand from memory
`define load_dst_reg            'h50            // load destination operand from register
`define load_dst_mem            'h54            // load destination operand from memory
`define exec_1op                'h60            // execute 1 operand instructions
`define exec_2op                'h64            // execute 2 operand instructions
`define store_reg               'h70            // store result to register
`define store_mem               'h74            // store result to memory
`define inc_cp                  'h80            // increment program counter
`define push                    'h85            // push element to the stack
`define pop                     'h90            // extract the last element from the stack, store it in memory or regs
`define inc_is                  'h100           // IS=IS++
`define dec_is                  'h105           // IS=IS--
`define call                    'h110           // function to call another routine
`define ret                     'h115           // return from a routine
`define jmp                     'h120           // jump to another section in memory
`define je                      'h121           // jump if ==
`define jne                     'h122           // jump if !=
`define jle                     'h123           // jump if <=
`define incr                    'h125           // mod 11, rm=0XX
`define decr                    'h127           // mod 11, rm=10X
`define depls                   'h131           // mod 11, rm=11X
`define sumt                    'h136           // T1 <- T1 + T2 in the scope of mod 11
`define inc_xx                  'h137           // X?++, in the scope of incr
`define mov                     'h140           //moves one operator into another spot
`define movimd                  'h150           //mov but with an immediate operator

reg [state_width-1 : 0] state = `reset, state_next;
reg [state_width-1 : 0] decoded_src, decoded_src_next;      // stores decoded source operand load state
reg [state_width-1 : 0] decoded_dst, decoded_dst_next;      // stores decoded destination operand load state
reg [state_width-1 : 0] decoded_exec, decoded_exec_next;    // stores decoded execute state
reg [state_width-1 : 0] decoded_store, decoded_store_next;  // stores decoded store state
reg decoded_d, decoded_d_next;                              // stores decoded direction bit

// FSM - sequential part
always @(posedge clk) begin
    state <= `reset;

    if(!rst) begin
        state <= state_next;

        if(state == `decode) begin
            decoded_src <= decoded_src_next;
            decoded_dst <= decoded_dst_next;
            decoded_exec <= decoded_exec_next;
            decoded_store <= decoded_store_next;
            decoded_d <= decoded_d_next;
        end
    end
end

// FSM - combinational part
always @(*) begin
    state_next = `reset;
    decoded_src_next = `reset;
    decoded_dst_next = `reset;
    decoded_exec_next = `reset;
    decoded_store_next = `reset;
    decoded_d_next = 0;
    alu_oe = 0;
    alu_carry = 0;
    alu_opcode = 0;
    ram_oe = 0;
    ram_we = 0;
    io_oe = 0;
    io_we = 0;
    regs_addr = 0;
    regs_oe = 0;
    regs_we = 0;
    cp_oe = 0;
    cp_we = 0;
    ind_sel = 0;
    ind_oe = 0;
    ind_we = 0;
    am_oe = 0;
    am_we = 0;
    aie_oe = 0;
    aie_we = 0;
    t1_oe = 0;
    t1_we = 0;
    t2_oe = 0;
    t2_we = 0;
    ri_oe = 0;
    ri_we = 0;

    case(state)
        `reset: state_next = `fetch;

        `fetch: begin // CP <- AM
            cp_oe = 1;
            am_we = 1;

            state_next = `fetch + 1;
        end

        `fetch + 'd1: begin // RAM <- AM
            am_oe = 1;

            state_next = `fetch + 2;
        end

        `fetch + 'd2: begin // RI <- RAM
            ram_oe = 1;
            ri_we = 1;

            // RI now has the instruction code, so we need to decode it
            state_next = `decode;
        end
        
        `decode: begin // Decode RI
            // Decode operation type
            case (cop[0:3])
                4'b0000: begin // Data/Control Transfer, //! with effective address
                    case (cop[4:6])
                        3'b000: begin // MOV (op neimediat)
                            decoded_d_next = d;
                            //i thought we could do a sort of exec2op operation here
                            //with the exception that the actual exec phase shall equal 
                            //the two T1 and T2.
                            if ( mod == 2'b11 || d == 1 ) begin     
                                decoded_dst_next = `load_dst_reg;
                                decoded_src = `load_src_mem;
                                decoded_store_next = `store_reg;
                            end else begin
                                decoded_dst_next = `load_dst_mem;
                                decoded_src = `load_src_reg;
                                decoded_store_next = `store_mem;
                            end
                            decoded_exec_next= `mov;
                        end

                        3'b010: begin // PUSH
                            decoded_d_next     = 0;
                            decoded_exec_next  = `push;
                            decoded_store_next = `store_mem;
                            decoded_src_next   = (mod == 2'b11) ? `load_src_mem : `load_src_reg;
                            decoded_dst_next   = `decoded_exec_next;
                        end

                        3'b011: begin // POP
                            decoded_d_next = 0;
                            decoded_exec_next = `pop;
                            decoded_dst_next = decoded_exec_next;

                            //we skip the source bit, as this operation does not have a source
                            decoded_src_next = decoded_dst_next;
                            //since we only need to calculate the destination, which will be retained in T1, no source is neccesary
                        end

                        3'b100: begin // CALL
                            // we need to save the thing into T1(effective adress?)
                            decoded_d_next = 0;
                            
                            // the destination is either direct access or indirect
                            decpded_exec_next=`inc_cp;
                            decoded_dst_next = decoded_exec_next;
                            
                            //we skip the source bit, as this operation does not have a source                      
                            decoded_src_next = decoded_dst_next;
                        end

                        3'b101: begin // JMP
                            decoded_d_next     = 0;
                            decoded_store_next = 0; //! unused
                            decoded_exec_next  = `jmp;
                            decoded_dst_next   = `load_dst_reg; //? tinand cont de mod?
                            decoded_src_next   = `decoded_dst_next;
                        end

                        default: ;
                    endcase
                end

                4'b0001: begin // 1 op instructions
                    decoded_d_next      = 0;
                    decoded_dst_next    = (mod == 2'b11) ? `load_dst_reg : `load_dst_mem;
                    decoded_src_next    = decoded_dst_next;
                    decoded_store_next  = (mod == 2'b11) ? `store_reg : `store_mem;
                    decoded_exec_next   = `exec_1op;
                    
                end

                4'b0100: begin // 2 op instruction, with no store
                    decoded_d_next = d;

                    // if mod == 11, then we deal with regs and //!adresare directa
                    // operation structure: store <- dst [operand] src
                    // if d == 0, op looks like R/M <- R/M [operand] REG
                    // if d == 1, op looks like REG <- REG [operand] R/M
                    if ( mod == 2'b11 || d == 1 ) begin
                        decoded_dst_next = `load_dst_reg;
                        decoded_src = `load_src_mem;
                    end else begin
                        decoded_dst_next = `load_dst_mem;
                        decoded_src = `load_src_reg;
                    end
                    decoded_store_next  = `inc_cp;

                    decoded_exec_next   = `exec_2op;
                end

                4'b0010: begin
                    case (cop[4:6])
                        3'b100: begin // MOV (op imediat)
                            decoded_d_next= 0;// we dont need this i think
                            decoded_exec_next=`inc_cp;
                            decoded_dst_next= decoded_exec_next;
                            decoded_src_next=decoded_dst_next;
                            decoded_store_next  = mod == 2'b11 ? `store_reg : `store_mem;
                        end
                        default: ;
                    endcase
                    
                end

                4'b0101: begin // 2 op instruction, with store
                    decoded_d_next = d;

                    // if mod == 11, then we deal with regs and //!adresare directa
                    // operation structure: store <- dst [operand] src
                    // if d == 0, op looks like R/M <- R/M [operand] REG
                    // if d == 1, op looks like REG <- REG [operand] R/M
                    if ( mod == 2'b11 || d == 1 ) begin
                        decoded_dst_next = `load_dst_reg;
                        decoded_src = `load_src_mem;
                        decoded_store_next = `store_reg;
                    end else begin
                        decoded_dst_next = `load_dst_mem;
                        decoded_src = `load_src_reg;
                        decoded_store_next = `store_mem;
                    end

                    decoded_exec_next   = `exec_2op;
                end

                4'b1000: begin // Data/Control Transfer, //! without effective address
                    case (cop[4:6])
                        3'b100: begin // RET
                            //? do we really skip all steps here ?//
                            decoded_d = 0;
                            decoded_exec_next = `ret;
                            decoded_dst_next = decoded_exec_next;
                            decoded_src_next = decoded_dst_next;
                            decoded_store_next = 0; //! unused
                        end
                        default: ;
                    endcase
                end

                4'b1001: begin // JCOND
                    // These values are independend of the type of JCOND
                    decoded_d_next     = d;
                    decoded_store_next = 0; //! unused
                    decoded_dst_next   = `load_dst_reg;
                    decoded_src_next   = `decoded_dst_next;

                    case ({cop[4:6],d}) //? this ok ?//
                        4'b0010: decoded_exec_next = `jle;
                        4'b0100: decoded_exec_next = `je;
                        4'b1100: decoded_exec_next = `jne;
                        default: ;
                    endcase
                end
            endcase

            // decode address calculation mode
            case(mod)
                2'b00: begin //indirect method
                    // RM can contain either [XA/XB/BA/BB] (if RM = 0XX)
                    // or [BA/BB + XA/XB] (if RM = 1XX)
                    // so basically, if RM[0] == 0, addr has a reg
                    // if RM[0] == 1, addr has a sum of regs
                    state_next = rm[0] ? `addr_reg : `addr_sum;
                end

                2'b01: begin
                    case (rm[0:1])
                        2'b11: state_next = `depls;
                        2'b10: state_next = `decr;
                        default: state_next = `incr;
                    endcase
                end
                2'b11: begin //direct method
                    // in this case, RM contains regs (and not a sum of regs)
                    // so there is no need to branch off
                    state_next = decoded_src_next;
                end
            endcase
        end
        
        `addr_sum: begin // T1 <- BA/BB
            regs_addr = rm[1] ? `BB : `BA;
            regs_oe = 1;

            t1_we = 1;

            state_next = `addr_sum + 1;
        end

        `addr_sum + 'd1: begin // T2 <- XA/XB
            regs_addr = rm[2] ? `XB : `XA; // set the register address
            regs_oe = 1;

            t2_we = 1;

            state_next = `addr_sum + 2;
        end

        `addr_sum + 'd2: begin // T1/T2 <- T1 + T2
            // Load both [T1] and [T2] into ALU
            t1_oe = 1;
            t2_oe = 1;
            
            // Set the operation to be ADC (add with carry) and set carry to 0
            alu_carry = 0;
            alu_opcode = `ADC;

            // Extract the result of the operation either into [T1] or [T2], based on [decoded_d]
            alu_oe = 1;
            t2_we = decoded_d;
            t1_we = !decoded_d;

            state_next = decoded_src;
        end
        
        `addr_reg: begin // T1/T2 <- REGS[rm]
            regs_addr = rm;
            regs_oe = 1;
            
            t2_we = decoded_d;
            t1_we = !decoded_d;

            state_next = decoded_src;
        end

        `incr: begin // T1 <- BA/BB
            regs_addr = (rm[1]) ? `BB : `BA;
            regs_oe = 1;

            t1_we = 1;

            state_next = `incr + 'd1;
        end

        `incr + 'd1: begin // T2 <- XA/XB
            regs_addr = (rm[2]) ? `XB : `XA;
            regs_oe = 1;

            t2_we = 1;

            state_next = `sumt;
        end

        `decr: begin // T1 <- BA/BB
            regs_addr = (rm[2]) ? `BB : `BA;
            regs_oe = 1;

            t1_we = 1;

            state_next = `decr + 'd1;
        end

        `decr + 'd1: begin // T2 <- XA
            regs_addr = `XA;
            regs_oe = 1;

            t2_we = 1;

            state_next = `decr + 'd2;
        end

        `decr + 'd2: begin // XA <- T2 - 1
            t1_oe = 0;
            t2_oe = 1;

            alu_opcode = `SBB1;
            alu_carry = 1;
            alu_oe = 1;
            
            regs_addr = `XA;
            regs_we = 1;

            state_next = `decr + 'd3;
        end
        
        `decr + 'd3: begin // T2 <- XA
            regs_addr = `XA;
            regs_oe = 1;

            t2_we = 1;

            state_next = `sumt;
        end

        `depls: begin // T1 <- CP  //? identical with inc_cp ?//
            cp_oe = 1;
            t1_we = 1;

            state_next = `inc_cp + 'd1;
        end

        `depls + 'd1: begin // CP <- T1 + 1
            // Read from T1
            t1_oe = 1;

            // Set the opcode to be ADC (add with carry) and set the carry to 1 to increment
            alu_oe = 1;
            alu_carry = 1;
            alu_opcode = `ADC;
            
            // Write into CP
            cp_we = 1;

            state_next = `depls + 'd2;
        end
        //! inca o stare, muta CP in T1
        `depls + 'd2: begin // AM <- T1 OR 0 = T1  //? identical with load_dst_mem ?//
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `OR;
            alu_oe = 1;

            am_we = 1;

            state_next = `depls + 1;
        end

        `depls + 'd3: begin // RAM <- AM
            am_oe = 1;

            state_next = `depls + 2;
        end

        `depls + 'd4: begin // T2 <- RAM
            ram_oe = 1;
            t2_we = 1;

            state_next = `sumt;
        end

        `sumt: begin // T1 <- T1 + T2
            t1_oe = 1;
            t2_oe = 1;

            alu_opcode = `ADC;
            alu_carry = 0;
            alu_oe = 1;

            t1_we = 1;

            state_next = (rm[0] == 1) ? decoded_src : `inc_xx;
        end

        `inc_xx: begin // T1 <- XA/XB
            regs_addr = (rm[2] == 0) ? `XA : `XB;
            regs_oe = 1;

            t1_we = 1;

            state_next = `inc_xx + 'd1;
        end

        `inc_xx + 'd1: begin // XA/XB <- T1 + 1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `ADC;
            alu_carry = 1;
            alu_oe = 1;

            regs_addr = (rm[2] == 0) ? `XA : `XB;
            regs_We = 1;

            state_next = decoded_src;
        end

        `load_src_reg: begin // T2 <- REGS[rm/rg]
            regs_addr = decoded_d ? rm : rg;
            regs_oe = 1;
            
            t2_we = 1;

            state_next = decoded_dst;
        end
        
        `load_src_mem: begin // AM <- T2 OR 0 = T2
            t1_oe = 0;
            t2_oe = 1;

            alu_opcode = `OR;
            alu_oe = 1;
            
            am_we = 1;

            state_next = `load_src_mem + 1;
        end

        `load_src_mem + 'd1: begin // RAM <- AM
            am_oe = 1;

            state_next = `load_src_mem + 2;
        end

        `load_src_mem + 'd2: begin // T2 <- RAM
            ram_oe = 1;
            t2_we = 1;

            state_next = decoded_dst;
        end

        `load_dst_reg: begin // T1 <- REGS[rm/rg]
            regs_addr = decoded_d ? rg : rm;
            regs_oe = 1;

            t1_we = 1;

            state_next = decoded_exec;
        end
        
        `load_dst_mem: begin // AM <- T1 OR 0 = T1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `OR;
            alu_oe = 1;

            am_we = 1;

            state_next = `load_dst_mem + 1;
        end

        `load_dst_mem + 'd1: begin // RAM <- AM
            am_oe = 1;

            state_next = `load_dst_mem + 2;
        end

        `load_dst_mem + 'd2: begin // T1 <- RAM
            ram_oe = 1;
            t1_we = 1;

            state_next = decoded_exec;
        end

        `exec_1op: begin // T1 <- [operand] T1
            // Output from T1, to be used on the RHS
            t1_oe = 1;

            // Select the required [operand]
            case(cop[4:6])
                3'b000: begin               // INC
                    alu_carry = 1;
                    alu_opcode = `ADC;
                end
                3'b001: begin               // DEC
                    alu_carry = 1;
                    alu_opcode = `SBB1;
                end
                3'b010: begin               // NEG
                    alu_carry = 0;
                    alu_opcode = `SBB2;
                end
                3'b011: alu_opcode = `NOT;  // NOT
                3'b100: alu_opcode = `SHL;  // SHL/SAL
                3'b101: alu_opcode = `SHR;  // SHR
                3'b110: alu_opcode = `SAR;  // SAR
            endcase

            // enable writing to T1, for LHS
            alu_oe = 1;
            t1_we = 1;

            // Set flags
            ind_sel = 1;
            ind_we = 1;

            state_next = decoded_store;
        end
        
        `exec_2op: begin // T1 <- T1 [operand] T2
            // Enable outputs for RHS
            t1_oe = 1;
            t2_oe = 1;

            case(cop[4:6])
                3'b000: begin               // ADD
                    alu_carry = 0;
                    alu_opcode = `ADC;
                end
                3'b001: begin               // ADC
                    alu_carry = ind[0];
                    alu_opcode = `ADC;
                end
                3'b010: begin               // SUB/CMP
                    alu_carry = 0;
                    alu_opcode = `SBB1;
                end
                3'b011: begin               // SBB
                    alu_carry = ind[0];
                    alu_opcode = `SBB1;
                end
                3'b100: alu_opcode = `AND;  // AND/TEST
                3'b101: alu_opcode = `OR;   // OR
                3'b110: alu_opcode = `XOR;  // XOR
            endcase

            // Enablee writing into T1, for LHS
            alu_oe = 1;
            t1_we = 1;

            // Set flags
            ind_sel = 1;
            ind_we = 1;

            state_next = decoded_store;
        end

        `store_reg: begin // REGS[rm/rg] <- T1
            t1_oe = 1;
            t2_oe = 0;
            
            // They must be passed through an operation to be written. T1 doesnt have MAG access.
            // opcde is set to OR because (T1 OR 0) is always T1.
            alu_opcode = `OR;
            alu_oe = 1;

            // Store into regs
            regs_addr = decoded_d ? rg : rm;
            regs_we = 1;

            state_next = `inc_cp;
        end

        `store_mem: begin // M[AM] <- T1
            t1_oe = 1;
            t2_oe = 0;

            // They must be passed through an operation to be written. T1 doesnt have MAG access.
            // opcde is set to OR because (T1 OR 0) is always T1.
            alu_opcode = `OR;
            alu_oe = 1;

            //?
            am_oe = 1;
            ram_we = 1;

            state_next = `store_mem + 1;
        end

        `store_mem + 'd1: state_next = `inc_cp;

        `inc_cp: begin // T1 <- CP
            cp_oe = 1;
            t1_we = 1;

            state_next = `inc_cp + 1;
        end

        `inc_cp + 'd1: begin // CP <- T1 + 1 
            // Read from T1
            t1_oe = 1;

            // Set the opcode to be ADC (add with carry) and set the carry to 1 to increment
            alu_oe = 1;
            alu_carry = 1;
            alu_opcode = `ADC;
            
            // Write into CP
            //! can we do this in inc cp or do we have to write a sperate one for T2
            cp_we = 1;
            if(cop[0:6]== 7'b0000100)
                state_next= `dec_is;
            else if(cop[0:6]== 7'b0010100)
                    state_next=`movimd;
            else state_next= `fetch;
        end

        `push: begin // T1 <- IS
            regs_addr = `IS;
            regs_oe = 1;

            t1_we = 1;

            state_next = `push + 'd1;
        end

        `push + 'd1: begin // IS <- T1 - 1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `SBB1;
            alu_carry = 1;
            alu_oe = 1;

            regs_addr = `IS;
            regs_we = 1;

            state_next = `push + 'd2;
        end

        `push + 'd2: begin // T1 <- T2 OR 0 = T2
            t1_oe = 0;
            t2_oe = 1;

            alu_opcode = `OR;
            alu_carry = 0;
            alu_oe = 1;

            t1_we = 1;
             
            state_next = `push + 'd3;
        end
 
        `push + 'd3: begin // AM <- IS
            regs_addr = `IS;
            regs_oe = 1;

            am_we = 1;

            state_next = `decoded_store;
        end

        `ret: begin // T1 <- IS
            regs_addr = `IS;
            regs_oe = 1;

            t1_we = 1;

            state_next = `ret + 'd1;
        end

        `ret + 'd1: begin // AM <- T1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `OR;
            alu_oe = 1;

            am_we = 1;

            state_next = `ret + 'd2;
        end

        `ret + 'd2: begin // RAM <- AM
            am_oe = 1;

            state_next = `ret + 'd3;
        end

        `ret + 'd3: begin // CP <- RAM
            ram_oe = 1;
            cp_we = 1;

            state_next = `ret + 'd4;
        end

        `ret + 'd4: begin // IS <- T1 + 1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `ADC;
            alu_carry = 1;
            alu_oe = 1;

            regs_addr = `IS;
            regs_we = 1;

            state_next = `fetch;
        end

        `jmp: begin // CP <- T1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `OR;
            alu_oe = 1;

            cp_we = 1;

            state_next = `fetch;
        end
        //? daca se face operatia inainte sau o fac in cadrul Jcond
        `je: state_next = (ind[2] == 0) ? `jmp : `inc_cp;
        `jne: state_next = (ind[2] != 0) ? `jmp : `inc_cp;
        `jle: state_next = (ind[1] == 0) ? `jmp : `inc_cp;

        //? HOW IS THE STACK DEFINED

        `pop: begin // AM <- IS
            regs_addr = `IS;
            regs_oe = 1;

            am_we = 1;

            state_next = `pop + 'd1;
        end

        `pop + 'd1: begin // RAM <- AM
            am_oe = 1;

            state_next = `pop + 'd2;
        end

        `pop + 'd2: begin // T2 <- RAM
            ram_oe = 1;
            t2_we = 1;

            state_next = `pop + 3;
        end

        // (readying to write in DEST, AM must receive the effective adress, which is in T1)
        `pop + 'd3: begin // AM <- T1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `OR;
            alu_oe = 1;
            
            am_we = 1;

            state_next = `inc_is;
        end

        `inc_is : begin // T1 <- M[IS]
            regs_addr= `IS;
            regs_oe=1;

            t1_we=1;

            state_next= `inc_is +1;
        end

        `inc_is + 'd1: begin // M[IS] <- T1
            t1_oe = 1;
            t2_oe = 0;

            alu_opcode = `ADC;
            alu_carry = 1;
            alu_oe = 1;

            regs_addr= `IS;
            regs_we = 1;

            state_next = `pop + 3;
        end

        `pop + 'd3: begin // DEST <- T2
            t2_oe = 1;
            t1_oe = 0;

            alu_opcode = `OR;
            alu_oe = 1;

            if(mod == 11) begin //direct adress
                regs_addr = decoded_d ? rg : rm;  //we write in the reg the variable we need
                regs_we = 1;
            end
            else begin //indirect adress
                am_oe = 1;
                ram_we = 1;
            end
            stare_next = `inc_cp;
        end

        `dec_is: begin
            regs_addr = `IS;
            regs_oe = 1;

            t2_we = 1 ; // we decrement it into T2, cuz T1 has the effective adress(maybe)
            
            state_next = `dec_is + 1;
        end

        `dec_is + 'd1: begin
            t2_oe = 1;
            t1_oe = 0;

            alu_opcode = `SBB1;  //? maybe with DEC too
            alu_carry = 1;
            alu_oe = 1;

            regs_addr = `IS;
            regs_we = 1;

            state_next = `call;
        end

        `call: begin // AM <- M[IS]
            regs_addr = `IS;
            regs_oe = 1;

            am_we = 1;

            state_next = `call + 1;
        end

        `call + 'd1: begin //M[AM]<-CP or otherwise M[--IS]<-++CP
            am_oe = 1;
            cp_oe = 1;

            ram_we = 1;

            state_next = `jmp;
        end


        `mov: begin // T1 <- T2
            t1_oe = 0;
            t2_oe = 1;

            alu_opcode = `OR;
            alu_oe = 1;

            t1_we = 1;

            state_next = `decoded_store;
        end

        `movimd: begin // AM <- CP
            cp_oe = 1;
            am_we = 1;

            state_next = `movimd + 1;
        end

        `movimd + 'd1: begin // read AM
            am_oe = 1;
            
            state_next = `movimd + 2;
        end

        `movimd + 'd2: begin // T2 <- M[AM]
            ram_oe = 1;
            t2_we = 1;

            state_next= `movimd + 3;
        end

        `movimd + 'd3: begin // AM <- T1 (where our adress is)
            t1_oe = 1;
            t2_oe = 0;
            alu_opcode = `OR;
            alu_oe = 1;
            am_we = 1;

            state_next= `movimd + 4;
        end

        `movimd + 'd4: begin // T1 <- T2
            t1_oe = 0;
            t2_oe = 1;

            alu_opcode = `OR;
            alu_oe = 1;

            t1_we = 1;
            
            state_next = `decoded_store;
        end

        default: ;
    endcase
end

assign disp_state = state;

endmodule
