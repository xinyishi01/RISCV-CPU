`include "defines.v"

module pc(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire pc_stall,
	input wire jmp,
	input wire[`InstAddrBus] pc_i,

	output reg[`InstAddrBus] pc_o
);

	reg ok;

	always @(posedge clk) begin
		if(rst == `True) begin
			pc_o <= `ZeroWord;
			ok <= `False;
		end else if(rdy == `False) begin
			ok <= `False;
		end else if(jmp == `True) begin
			pc_o <= pc_i;
		end else if(pc_stall == `False && ok == `True) begin
			pc_o <= pc_o + 4;
		end else begin
			ok <= `True;
		end
	end
endmodule