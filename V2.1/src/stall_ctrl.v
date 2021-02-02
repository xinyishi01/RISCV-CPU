`include "defines.v"

module stall_ctrl(
	input wire if_in,
	input wire id_in,
	input wire mem_in,
	input wire jmp,
	input wire rdy,
	
	output reg pc_stall,
	output reg if_stall,
	output reg if_clear,
	output reg id_stall,
	output reg id_clear,
	output reg ex_stall,
	output reg mem_stall,
	output reg mem_clear
);

	always @(*) begin
		pc_stall = `False;
		if_stall = `False;
		if_clear = `False;
		id_stall = `False;
		id_clear = `False;
		ex_stall = `False;
		mem_stall = `False;
		mem_clear = `False;
		if(rdy == `False) begin
			pc_stall = `True;
			if_stall = `True;
			id_stall = `True;
			ex_stall = `True;
			mem_stall = `True;
		end else begin
			//if mem & id(if) stall, then id(if) stall, do not clear
			if(mem_in == `True) begin 
				pc_stall = `True;
				if_stall = `True;
				id_stall = `True;
				ex_stall = `True;
				mem_clear = `True;
				if(jmp == `True) 
					if_clear = `True;
			end else if(jmp == `True) begin
				if_clear = `True;
				id_clear = `True;
			end else if(id_in == `True) begin
				pc_stall = `True;
				if_stall = `True;
				id_clear = `True;
			end else if(if_in == `True) begin
				pc_stall = `True;
				if_clear = `True;
			end
		end
	end
endmodule