`include "defines.v"

module pc(
	input wire clk,
	input wire rst,
	input wire pc_stall,
	input wire jmp,
	input wire[`InstAddrBus] pc_i,

	output reg[`InstAddrBus] pc_o
);

	always @(posedge clk) begin
		if(rst == `True) begin
			pc_o <= `ZeroWord;
		end else if(jmp == `True) begin
			pc_o <= pc_i;
		end else if(pc_stall == `False) begin
			pc_o <= pc_o + 4;
		end
	end
endmodule