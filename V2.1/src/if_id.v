`include "defines.v"

module if_id(
	input wire clk,
	input wire rst,
	
	input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,
	input wire if_stall,
	input wire if_clear,

	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst,

	input wire[`BrIndexBus] if_br_index,
	input wire if_prd_jmp,

	output reg[`BrIndexBus] id_br_index,
	output reg id_prd_jmp
);

	always @(posedge clk) begin
		if(rst == `True || if_clear == `True) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
			id_br_index <= `ZeroWord;
			id_prd_jmp <= `False;
		end else if(if_stall == `False) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
			id_br_index <= if_br_index;
			id_prd_jmp <= if_prd_jmp;
		end
	end
endmodule