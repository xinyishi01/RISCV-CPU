`include  "defines.v"

module id_ex(
	input wire clk,
	input wire rst,
	input wire id_stall,
	input wire id_clear,
	
	input wire[`InstAddrBus] id_pc,
	input wire[`AluSelBus] id_alusel,
	input wire[`AluOpBus] id_aluop,
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
	input wire[`RegBus] id_offset,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,

	output reg[`InstAddrBus] ex_pc,
	output reg[`AluSelBus] ex_alusel,
	output reg[`AluOpBus] ex_aluop,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
	output reg[`RegBus] ex_offset,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,

	input wire[`BrIndexBus] id_br_index,
	input wire id_prd_jmp,

	output reg[`BrIndexBus] ex_br_index,
	output reg ex_prd_jmp
);

	always @(posedge clk) begin
		if(rst == `True || id_clear == `True) begin
			ex_pc <= `ZeroWord;
			ex_alusel <= `Sel_Nor;
			ex_aluop <= `EX_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPAddr;
			ex_wreg <= `False;
			ex_offset <= `ZeroWord;
			ex_br_index <= `ZeroWord;
			ex_prd_jmp <= `False;
		end else if(id_stall == `False) begin
			ex_pc <= id_pc;
			ex_alusel <= id_alusel;
			ex_aluop <= id_aluop;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;
			ex_offset <= id_offset;
			ex_br_index <= id_br_index;
			ex_prd_jmp <= id_prd_jmp;
		end
	end
endmodule