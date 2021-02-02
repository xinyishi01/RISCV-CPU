`include "defines.v"

module If(
	input wire clk,
	input wire rst,
	input wire rdy,
	input wire jmp,
	input wire[`InstAddrBus] pc_i,

	input wire[`InstBus] inst_i,
	input wire inst_ok,

	output reg[`InstAddrBus] pc_o,
	output reg inst_enable,
	output reg [`InstBus] inst_o,
	output reg if_flag,
	
	input wire[`BrIndexBus] br_index_i,
	input wire prd_jmp_i,

	output reg[`BrIndexBus] br_index_o,
	output reg prd_jmp_o
);
    
    wire[`IndexBus] index;
	assign index = pc_i[8:2];
	reg[`InstBus] data[`MapBus];
	reg[9:0] tag[`MapBus];
	reg vl[`MapBus];
	integer i;

	always @(posedge clk) begin
		if(rst == `True || rdy == `False) begin
			for (i = 0; i <= `MapSize; i = i + 1) begin
				data[i] <= `ZeroWord;
				tag[i] <= `ZeroWord;
				vl[i] <= `False;
			end
		end else if(inst_ok) begin
			data[index] <= inst_i;
			tag[index] <= pc_i[18:9];
			vl[index] <= `True;
		end
	end

	always @(*) begin
		if(rst == `True || rdy == `False || jmp) begin
			pc_o = `ZeroWord;
			inst_o = `ZeroWord;
			inst_enable = `False;
			if_flag = `False;
			br_index_o = `ZeroWord;
			prd_jmp_o = `False;
		end
		else begin
			br_index_o = br_index_i;
			prd_jmp_o = prd_jmp_i;
			if(tag[index] == pc_i[18:9] && vl[index] == `True) begin
				pc_o = pc_i;
				inst_o = data[index];
				if_flag = `False;
				inst_enable = `False;
			end else begin
				pc_o = pc_i;
				inst_o = inst_i;
				if_flag = !inst_ok;
				inst_enable = `True;
			end
		end
	end
endmodule