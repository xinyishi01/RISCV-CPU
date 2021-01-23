`include "defines.v"

module if_id(
	input wire clk,
	input wire rst,
	
	input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,
	input wire if_stall,
	input wire if_clear,

	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
);

	always @(posedge clk) begin
		if(rst == `True || if_clear == `True) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(if_stall == `False) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
	end
endmodule