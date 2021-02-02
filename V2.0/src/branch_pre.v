`include "defines.v"

module branch_pre(
    input wire clk,
	input wire rst,
	input wire[`InstAddrBus] pc,
	input wire global,

	output wire[`BrIndexBus] index,
	output reg[`InstAddrBus] prd_pc,
	output reg prd_jmp,

	input wire is_branch,
	input wire[`BrIndexBus] index_i,
	input wire[11:0] br_tag_i,
	input wire[`InstAddrBus] jmp_pc_i,
	input wire branch_taken
);

	assign index = {global, pc[6:2]};

	reg[1:0] prd[`BrMapBus];
	reg[11:0] tag[`BrMapBus];
	reg[`InstAddrBus] jmp_pc[`BrMapBus];
	reg vl[`BrMapBus];
	integer i;

	always @(posedge clk) begin
		if(rst == `True) begin
			for (i = 0; i <= `BrSize; i = i + 1) begin
				prd[i] <= 1;
				tag[i] <= `ZeroWord;
				jmp_pc[i] <= `ZeroWord;
				vl[i] <= `False;
			end
		end else if(is_branch) begin
			if(vl[index_i] && tag[index_i] == br_tag_i) begin
				if(branch_taken == `True && prd[index_i] < 3) begin
					prd[index_i] <= prd[index_i] + 1;
				end
				if(branch_taken == `False && prd[index_i] > 0) begin
					prd[index_i] <= prd[index_i] - 1;
				end
			end else begin
				if(branch_taken == `True) prd[index_i] <= 2;
				else prd[index_i] <= 1; //
			end
			vl[index_i] <= `True;
			tag[index_i] <= br_tag_i;
			jmp_pc[index_i] <= jmp_pc_i;
		end
	end

	always @(*) begin
		if(rst == `True) begin
			prd_pc = `ZeroWord;
			prd_jmp = `False;
		end else begin
			if(vl[index] == `True && tag[index] == pc[18:7] && prd[index] > 1) begin
				prd_pc = jmp_pc[index];
				prd_jmp = `True;
			end else begin
				prd_pc = pc + 4;
				prd_jmp = `False;
			end
		end
	end

endmodule
