`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:       UPB
// Engineer:      Dan Dragomir
//
// Create Date:   12:34:41 12/20/2013
// Design Name:   tester tema3
// Module Name:   ram
// Project Name:  tema3
// Target Device: ISim
// Tool versions: 14.6
// Description:   tester for homework 3: calculatorul didactic
//
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module ram(
	clka,
	dina,
	addra,
	wea,
	ssra,
	douta,
	clkb,
	dinb,
	addrb,
	web,
	doutb);

input               clka;
input [15:0]        dina;
input [ 9:0]        addra;
input               wea;
input               ssra;
output reg[15:0]    douta;
input               clkb;
input [15:0]        dinb;
input [ 9:0]        addrb;
input               web;
output reg[15:0]    doutb;

reg [15:0] data[1023:0];

integer data_file, i, aux;
initial begin
    data_file = $fopen("test.coe", "r");
    if(!data_file) begin
        $write("error opening data file\n");
        $finish;
    end
    aux = $fscanf(data_file, "MEMORY_INITIALIZATION_RADIX=16;\n");
    aux = $fscanf(data_file, "MEMORY_INITIALIZATION_VECTOR=\n");
    for(i = 0; i < 1024 && !$feof(data_file); i = i + 1) begin
        if($fscanf(data_file, "%x,\n", data[i]) != 1) begin
            $write("error reading test data\n");
            $finish;
        end
    end
    $fclose(data_file);
end

always @(posedge clka, posedge clkb) begin
    if(clka) begin
        if(wea)
            data[addra] <= dina;
        douta <= data[addra];
    end
    
    if(clkb) begin
        if(web)
            data[addrb] <= dinb;
        doutb <= data[addrb];
    end
end

endmodule
