`include "defines.v"

module mem_wb (
    input wire clk,
    input wire rst,
	input wire mem_stall,
	input wire mem_clear,

    input wire[`RegAddrBus] mem_wd,
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,

	output reg[`RegAddrBus] wb_wd,
    output reg wb_wreg,
    output reg[`RegBus] wb_wdata
);

	always @(posedge clk) begin
		if(rst == `True || mem_clear == `True) begin
			wb_wd <= `NOPAddr;
			wb_wreg <= `False;
			wb_wdata <= `ZeroWord;
		end else if(mem_stall == `False) begin
			wb_wd <= mem_wd;
			wb_wreg <= mem_wreg;
			wb_wdata <= mem_wdata;
		end
	end

endmodule