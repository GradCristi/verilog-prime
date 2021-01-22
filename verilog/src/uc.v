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
`define pop                     'h90            // extract the last element from the stack, memorize it in memory or regs
`define inc_is                  'h100           // IS=IS++
`define `dec+is                 `h105           //IS=IS--
`define call                    'h110           //function to call another routine

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
        `reset: begin
            state_next = `fetch;
        end

        `fetch: begin
            cp_oe = 1;                        //read Contor Program
            am_we = 1;                        //write into the AM part of RAM

            state_next = `fetch + 1;
        end

        `fetch + 'd1: begin
            am_oe = 1;                       //Output from AM into RAM

            state_next = `fetch + 2;
        end

        `fetch + 'd2: begin
            ram_oe = 1;                         //Send forth the info stored into the RAM
            ri_we = 1;                          //put it into RI(storage place for the instruction)

            state_next = `decode;               //we need to decode what is in RI now
        end
        //COP, d, MOD, REG, RM- all of these are RI 
        `decode: begin
            // decode location of operands and operation
            if(cop[0:3] == 4'b0001) begin                                           // one operand instructions
                decoded_d_next      = 0;                                            //for one operand instructions d will be 0
                decoded_dst_next    = mod == 2'b11 ? `load_dst_reg : `load_dst_mem; // is the mode direct adress? (visible confusion)
                decoded_src_next    = decoded_dst_next;
                decoded_exec_next   = `exec_1op;                                    //execute instruction block for 1 operand
                decoded_store_next  = mod == 2'b11 ? `store_reg : `store_mem;       //store based on adress method
            end
            else if(cop[0:2] == 3'b010) begin       // two operand instructions
                decoded_d_next      = d;                                            //d counts this time
                decoded_dst_next    = (mod == 2'b11) || (d == 1) ? `load_dst_reg : `load_dst_mem;
                decoded_src_next    = (mod == 2'b11) || (d == 0) ? `load_src_reg : `load_src_mem;  //?
                decoded_exec_next   = `exec_2op;                                    //execute instruction block for 2 operands
                decoded_store_next  = !cop[3] ? `inc_cp : ((mod == 2'b11) || (d == 1) ? `store_reg : `store_mem); //do we save the variable
            end
            else if(cop[0:3] == 3'b 0000) begin         //branch off in decided exec
                if(cop[4:6] == 3'b 011) begin                //pop (structure is pop destination)
                    decoded_d_next      = 0;                                            //for one operand instructions d will be 0
                    decoded_dst_next    = `pop;                                         // the destination is either direct access or indirect
                    decoded_src_next    = decoded_dst_next;                             //we skip the source bit, as this operation does not have a source
                    //since we only need to calculate the destination, which will be retained in T1, no source is neccesary
                end
                else if(cop[4:6]==3'b100) begin   //instructiunea CALL
                    decoded_d_next      = 0; // we need to save the thing into T1(effective adress?)
                    decoded_dst_next    = `inc_cp;                                         // the destination is either direct access or indirect
                    decoded_src_next    = decoded_dst_next;                             //we skip the source bit, as this operation does not have a source                      
                end
            end
           
            
            // decode address calculation mode
            case(mod)                                           //direct or indirect method?
                2'b00: begin                                    //indirect method
                    state_next = rm[0] ? `addr_reg : `addr_sum; //does RM contain one reg or a sum of regs, the first bit of RM lets us know
                end                                             // we also go to the addr calculation part of the indirect method
                
                2'b11: begin                                    //direct method
                    state_next = decoded_src_next;              // decoded source next( load_scr_ reg or mem) or dst reg, dst mem if only 1 operator
                end
            endcase
        end
        
        `addr_sum: begin                                        //each bit tells us which addition is BB or BA
            regs_addr = rm[1] ? `BB : `BA;
            regs_oe = 1;
            t1_we = 1;

            state_next = `addr_sum + 1;
        end

        `addr_sum + 'd1: begin                                  //+XB or XA
            regs_addr = rm[2] ? `XB : `XA;
            regs_oe = 1;
            t2_we = 1;

            state_next = `addr_sum + 2;
        end

        `addr_sum + 'd2: begin                                  //we bring both into ALU
            t1_oe = 1;
            t2_oe = 1;
            alu_carry = 0;
            alu_opcode = `ADC;                                  //and perform an add with carry on them
            alu_oe = 1;
            if(decoded_d)
                t2_we = 1;
            else
                t1_we = 1;

            state_next = decoded_src;                         //we carry on
        end
        
        `addr_reg: begin                                    // direct adress mode, one register
            regs_addr = rm;                                 //adress coincides with RM
            regs_oe = 1;
            if(decoded_d)                                   //weird how the didnt choose the other format
                t2_we = 1;                                  //we write t2 if d=1, otherwise we write in t1
            else
                t1_we = 1;

            state_next = decoded_src;
        end
        
        `load_src_reg: begin                                //loads t2 with the apropriate values in the variable determined by d, if d==1 or not
            regs_addr = decoded_d ? rm : rg;
            regs_oe = 1;
            t2_we = 1;

            state_next = decoded_dst;                       //depending on the value of decoded dst, we can move onto the next state
        end
        
        `load_src_mem: begin                                //one operator, we load it into ALU, we execute OR and We write it in AM
            t1_oe = 0;
            t2_oe = 1;
            alu_opcode = `OR;
            alu_oe = 1;
            am_we = 1;                                      //so we can read off the RAM

            state_next = `load_src_mem + 1;
        end

        `load_src_mem + 'd1: begin                          //we read from the RAM, to see what was at AM
            am_oe = 1;

            state_next = `load_src_mem + 2;
        end

        `load_src_mem + 'd2: begin
            ram_oe = 1;
            t2_we = 1;                                      //what we found gets deposited into T2

            state_next = decoded_dst;
        end

        `load_dst_reg: begin                                //loads t1 with the apropriate parameter, useful in 2 op situations
            regs_addr = decoded_d ? rg : rm;
            regs_oe = 1;
            t1_we = 1;

            state_next = decoded_exec;                      //execute for 1 op or 2 op
        end
        
        `load_dst_mem: begin                                //we get T1, pass it through ALU
            t1_oe = 1;
            t2_oe = 0;
            alu_opcode = `OR;
            alu_oe = 1;
            am_we = 1;

            state_next = `load_dst_mem + 1;
        end

        `load_dst_mem + 'd1: begin                          //Go in AM, Output it to RAM
            am_oe = 1;

            state_next = `load_dst_mem + 2;
        end

        `load_dst_mem + 'd2: begin                          //Output the RAM into T1 again
            ram_oe = 1;
            t1_we = 1;

            state_next = decoded_exec;
        end

        `exec_1op: begin                                    //operations for 1 operand
            t1_oe = 1;
            case(cop[4:6])
                3'b000: begin                               // INC
                    alu_carry = 1;
                    alu_opcode = `ADC;
                end
                3'b001: begin                               // DEC
                    alu_carry = 1;
                    alu_opcode = `SBB1;
                end
                3'b010: begin                               // NEG
                    alu_carry = 0;
                    alu_opcode = `SBB2;
                end
                3'b011: begin                               // NOT
                    alu_opcode = `NOT;
                end
                3'b100: alu_opcode = `SHL;                  // SHL/SAL
                3'b101: alu_opcode = `SHR;                  // SHR
                3'b110: alu_opcode = `SAR;                  // SAR
            endcase
            alu_oe = 1;
            t1_we = 1;
            ind_sel = 1;
            ind_we = 1;

            state_next = decoded_store;
        end
        
        `exec_2op: begin                                    //execute for 2 operands, the code specified by cop
            t1_oe = 1;
            t2_oe = 1;
            case(cop[4:6])
                3'b000: begin                               // ADD
                    alu_carry = 0;
                    alu_opcode = `ADC;
                end
                3'b001: begin                               // ADC
                    alu_carry = ind[0];
                    alu_opcode = `ADC;
                end
                3'b010: begin                               // SUB/CMP
                    alu_carry = 0;
                    alu_opcode = `SBB1;
                end
                3'b011: begin                               // SBB
                    alu_carry = ind[0];
                    alu_opcode = `SBB1;
                end
                3'b100: alu_opcode = `AND;                  // AND/TEST
                3'b101: alu_opcode = `OR;                   // OR
                3'b110: alu_opcode = `XOR;                  // XOR
            endcase
            alu_oe = 1;
            t1_we = 1;
            ind_sel = 1;                                    //write the things, set the indicators
            ind_we = 1;

            state_next = decoded_store;                     //decoded store, be it inc cp, or the actual store if we want to save the value
        end

        //HOW IS THE STACK DEFINED

        `pop: begin
                                        //AM-<ADR(IS);
            regs_addr= `IS;
            regs_oe=1;
            am_we=1;
          
           state_next= `pop+1;
        end

         `pop + d'1: begin              //T2<-M[AM]
            am_oe=1;

            state_next = `pop +2;
         end

         `pop + d'2: begin
            ram_oe=1;
            t2_we=1;

            state_next= `pop+ 3; //(could be done with load dst mem, with an additional if on the state_next)
         end

         //AM<-T1(readying to write in DEST, AM must receive the effective adress, which is in T1)
          `pop + 'd2: begin     
                t1_oe=1;
                t2_oe=0;
                alu_opcode=`OR;
                alu_oe=1;
                am_we=1;

                state_next= `inc_is;
          end

          `inc_is : begin               //T1<-M[IS]
            regs_addr= `IS;
            regs_oe=1;
            t1_we=1;

            state_next= `inc_is +1;
          end

          `inc_is + 'd1: begin          //M[IS]<-T1++
            t1_oe = 1;
            t2_oe=0;
            alu_oe = 1;                                 
            alu_carry = 1;                              
            alu_opcode = `ADC;
            regs_addr= `IS;
            regs_we=1;

            state_next= `pop +3;
          end

         `pop + 'd3: begin              //DEST<-T2
            t2_oe=1;
            t1_oe=0;
            alu_opcode= `OR;
            alu_oe=1;
            if(mod==11) begin           //direct adress
                regs_addr = decoded_d ? rg : rm;                //we write in the reg the variable we need
                regs_we = 1;
            end
            else begin                  //indirect adress
                am_oe=1;
                ram_we=1;
            end
            stare_next=`inc_cp;
         end

         `dec_is: begin
            regs_addr= `IS;
            regs_oe=1;
            t2_we=1;                    // we decrement it into T2, cuz T1 has the effective adress(maybe)
            
            state_next= `dec_is +1;
         end

         `dec_is + 'd1: begin
            t2_oe = 1;
            t1_oe=0;
            alu_oe = 1;                 //we put the result on the MAG
            alu_carry = 1;                              
            alu_opcode = `SBB1;         //maybe with DEC too
            regs_addr= `IS;
            regs_we=1;

            state_next= `call;
         end

         `call: begin                       //AM<-M[IS]
            regs_addr= `IS;
            regs_oe= 1;
            am_we=1;
            state_next= `call + 1;
         end
        
        `call+ 'd1: begin                  //M[AM]<-CP or otherwise M[--IS]<-++CP
            am_oe=1;
            cp_oe=1;
            ram_we=1;

            state_next= `call+2;
        end

        `call+ 'd2: begin                   //CP<-T1(effective adress)
           t1_oe=1
           t2_oe=0;
           alu_opcode= `OR;
           alu_oe=1;
           cp_we=1;

           state_next= `fetch;
        end


        `store_reg: begin                                   //we store the value contained in t1
            t1_oe = 1;
            t2_oe = 0;
            alu_opcode = `OR;                               //they must be passed through an operation to be able to be written, t1 doesnt have MAG access
            alu_oe = 1;                                     //we do OR because OR with 0 changes nothing
            regs_addr = decoded_d ? rg : rm;                //we write in the reg the variable we need
            regs_we = 1;

            state_next = `inc_cp;                           //get ready to increment the counter, to signal the operation is done
        end
        
        `store_mem: begin                                   //store t1 to memory
            t1_oe = 1;
            t2_oe = 0;
            alu_opcode = `OR;                               //needs to be passed through ALU since T1 doesnt have MAG access
            alu_oe = 1;
            am_oe = 1;
            ram_we = 1;

            state_next = `store_mem + 1;
        end

        `store_mem + 'd1: begin
            state_next = `inc_cp;
        end

        `inc_cp: begin                                  // we write CP into T1, for the increment purposes
            cp_oe = 1;
            t1_we = 1;

            state_next = `inc_cp + 1;
        end

        `inc_cp + 'd1: begin                            //we do an ALU operation by adding 1 with the carry
            t1_oe = 1;
            cp_we = 1;                                  //we open the cp to be rewritten
            alu_oe = 1;                                 //we put the result on the MAG
            alu_carry = 1;                              
            alu_opcode = `ADC;
            if(cop[0:6]==0000100) begin
                state_next= `dec_is;
            end
            else
            state_next = `fetch;                        //we return to fetch
        end

        default: ;
    endcase
end

assign disp_state = state;

endmodule
