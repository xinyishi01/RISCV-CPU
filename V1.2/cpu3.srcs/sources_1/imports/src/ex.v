`include  "defines.v"

module ex(
	input wire rst,
	
	input wire[`InstAddrBus] pc_i,
	input wire[`AluSelBus] alusel_i,
	input wire[`AluOpBus] aluop_i,
    input wire[`RegBus] reg1_i,
    input wire[`RegBus] reg2_i,
	input wire[`RegBus] offset_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
	output reg[`InstAddrBus] pc_o,
	output reg jmp,

	output reg[`MemAddrBus] mem_addr_o,
	output reg is_ld,
	output reg[`AluOpBus] aluop_o
);

	reg[`RegBus] norout;
	reg is_JAL;

	always @(*) begin
		norout = `ZeroWord;
		if(rst == `False && alusel_i == `Sel_Nor) begin
			case (aluop_i)
				`EX_OR:		norout = reg1_i | reg2_i;
				`EX_AND:	norout = reg1_i & reg2_i;
				`EX_XOR:	norout = reg1_i ^ reg2_i;
				`EX_ADD:	norout = reg1_i + reg2_i;
				`EX_SUB:	norout = reg1_i - reg2_i;
				`EX_SLT:	norout = $signed(reg1_i) < $signed(reg2_i);
				`EX_SLTU:	norout = reg1_i < reg2_i;
				`EX_SLL:	norout = reg1_i << (reg2_i[4:0]);
				`EX_SRL:	norout = reg1_i >> (reg2_i[4:0]);
				`EX_SRA:	norout = (reg1_i >> (reg2_i[4:0])) | ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]}));
				`EX_AUIPC:	norout = pc_i + offset_i;
			endcase
		end
	end

	wire[`InstAddrBus] tmp;
	assign tmp = reg1_i + reg2_i;

	always @(*) begin
		jmp = `False;
		is_JAL = `False;
		pc_o = `ZeroWord;
		if(rst == `False && alusel_i == `Sel_Jmp) begin
			case (aluop_i)
				`EX_JAL: begin
					is_JAL = `True;
					jmp = `True; pc_o = pc_i + offset_i;
				end
				`EX_JALR: begin
					is_JAL = `True;
					jmp = `True; pc_o = {tmp[31:1], 1'b0};
				end
			endcase
		end
		if(rst == `False && alusel_i == `Sel_Br) begin
			case (aluop_i)
				`EX_BEQ: begin
					if(reg1_i == reg2_i) begin
						jmp = `True; pc_o = pc_i + offset_i;
					end
				end
				`EX_BNE: begin
					if(reg1_i != reg2_i) begin
						jmp = `True; pc_o = pc_i + offset_i;
					end
				end
				`EX_BLT: begin
					if($signed(reg1_i) < $signed(reg2_i)) begin
						jmp = `True; pc_o = pc_i + offset_i;
					end
				end
				`EX_BGE: begin
					if ($signed(reg1_i) >= $signed(reg2_i)) begin
						jmp = `True; pc_o = pc_i + offset_i;
					end
				end
				`EX_BLTU: begin
					if(reg1_i < reg2_i) begin
						jmp = `True; pc_o = pc_i + offset_i;
					end
				end
				`EX_BGEU: begin
					if (reg1_i >= reg2_i) begin
						jmp = `True; pc_o = pc_i + offset_i;
					end
				end
			endcase
		end
	end

	always @(*) begin
		is_ld = `False;
		mem_addr_o = `ZeroWord;
		if(rst == `False && alusel_i == `Sel_LD) begin
			is_ld = `True;
			mem_addr_o = reg1_i + offset_i;
		end
		if(rst == `False && alusel_i == `Sel_SD) begin
			is_ld = `False;
			mem_addr_o = reg1_i + offset_i;
		end
	end

	always @(*) begin
		wd_o = `ZeroWord;
		wreg_o = `False;
		wdata_o = `ZeroWord;
		aluop_o = `EX_NOP;
		if(rst == `False) begin
			wd_o = wd_i;
			wreg_o = wreg_i;
			case(alusel_i) 
				`Sel_Nor: wdata_o = norout;
				`Sel_Jmp: wdata_o = pc_i + 4;
				`Sel_LD: aluop_o = aluop_i;
				`Sel_SD: begin
					wdata_o = reg2_i;
					aluop_o = aluop_i;
				end
			endcase
		end
	end

endmodule