`include "defines.v"

module id(
	input wire rst,
	input wire [`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	input wire[`RegBus] reg1_data_i,
	input wire[`RegBus] reg2_data_i,

    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,
	input wire ex_ld,

	input wire[`RegAddrBus] mem_wd,
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,
	
	output reg [`InstAddrBus] pc_o,
	output reg reg1_read_o,
	output reg reg2_read_o,
	output reg[`RegAddrBus] reg1_addr_o,
	output reg[`RegAddrBus] reg2_addr_o,

    output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
    output reg[`RegBus] reg1_o,
    output reg[`RegBus] reg2_o,
	output reg[`RegBus] offset_o,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
	output wire id_flag
);

	wire[6:0] opcode = inst_i[6:0];
	wire[4:0] rd = inst_i[11:7];
	wire[2:0] funct3 = inst_i[14:12];
	wire[6:0] funct7 = inst_i[31:25];
	wire[4:0] rs1 = inst_i[19:15];
	wire[4:0] rs2 = inst_i[24:20];
	wire[11:0] I_imm = inst_i[31:20];
	wire[19:0] U_imm = inst_i[31:12];
	wire[11:0] S_imm = {inst_i[31:25], inst_i[11:7]};
	wire[19:0] UJ_imm = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};
	wire[11:0] SB_imm = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
	reg[31:0] imm;

	reg flag1, flag2;
	assign id_flag = flag1 | flag2;

	always @(*) begin

		reg1_read_o = `False;
		reg2_read_o = `False;
		reg1_addr_o = rs1;
		reg2_addr_o = rs2;
   		wd_o = rd;
		wreg_o = `False;
		alusel_o = `Sel_Nor;
		aluop_o = `EX_NOP;
		imm = `ZeroWord;
		pc_o = `ZeroWord;

		if(rst != `True) begin
			pc_o = pc_i;
			case (opcode)
				`OP_IMM: begin
					alusel_o = `Sel_Nor;
					wreg_o = `True;
					reg1_read_o = `True;
					reg2_read_o = `False;
					imm = {{20{I_imm[11]}}, I_imm[11:0]};
					case (funct3)
						`F3_OR:		aluop_o = `EX_OR;
						`F3_AND:	aluop_o = `EX_AND;
						`F3_XOR:	aluop_o = `EX_XOR;
						`F3_ADD_SUB:aluop_o = `EX_ADD;
						`F3_SLT:	aluop_o = `EX_SLT;
						`F3_SLTU:	aluop_o = `EX_SLTU;
						`F3_SLL: begin
							aluop_o = `EX_SLL;
							imm = {27'h0, I_imm[4:0]};
						end
						`F3_SRL_SRA: begin
							case (funct7)
								`F7_SRL: begin
									aluop_o = `EX_SRL;
									imm = {27'h0, I_imm[4:0]};
								end
								`F7_SRA: begin
									aluop_o = `EX_SRA;
									imm = {27'h0, I_imm[4:0]};
								end
							endcase
						end
					endcase
				end

				`OP: begin
					alusel_o = `Sel_Nor;
					wreg_o = `True;
					reg1_read_o = `True;
					reg2_read_o = `True;
					imm = `ZeroWord;
					case (funct3) 
						`F3_OR:		aluop_o = `EX_OR;
						`F3_AND:	aluop_o = `EX_AND;
						`F3_XOR:	aluop_o = `EX_XOR;
						`F3_SLT:	aluop_o = `EX_SLT;
						`F3_SLTU:	aluop_o = `EX_SLTU;
						`F3_SLL:	aluop_o = `EX_SLL;
						`F3_ADD_SUB: begin
							case (funct7) 
								`F7_ADD: aluop_o = `EX_ADD;
								`F7_SUB: aluop_o = `EX_SUB;
							endcase
						end
						`F3_SRL_SRA: begin
							case (funct7)
								`F7_SRL: aluop_o = `EX_SRL;
								`F7_SRA: aluop_o = `EX_SRA;
							endcase
						end
					endcase
				end

				`LUI: begin
					alusel_o = `Sel_Nor;
					aluop_o = `EX_OR; //
					wreg_o = `True;
					imm = {U_imm,12'h0};
				end

				`AUIPC: begin
					alusel_o = `Sel_Nor;
					aluop_o = `EX_AUIPC;
					wreg_o = `True;
					imm = {U_imm,12'h0};
				end

				`JAL: begin
					alusel_o = `Sel_Jmp;
					aluop_o = `EX_JAL;
					wreg_o = `True;
					imm = {{11{UJ_imm[19]}},UJ_imm,1'h0};
				end

				`JALR: begin
					alusel_o = `Sel_Jmp;
					aluop_o = `EX_JALR;
					wreg_o = `True;
               		reg1_read_o = `True;
					imm = {{20{I_imm[11]}},I_imm};
				end

				`BRANCH: begin
					alusel_o = `Sel_Br;
					wreg_o = `False;
					reg1_read_o = `True;
                    reg2_read_o = `True;
                    imm = {{19{SB_imm[11]}},SB_imm,1'b0};
					case(funct3)
						`F3_BEQ:	aluop_o = `EX_BEQ;
						`F3_BNE:	aluop_o = `EX_BNE;
						`F3_BLT:	aluop_o = `EX_BLT;
						`F3_BLTU:	aluop_o = `EX_BLTU;
						`F3_BGE:	aluop_o = `EX_BGE;
						`F3_BGEU:	aluop_o = `EX_BGEU;
					endcase
				end

				`LOAD: begin
					alusel_o = `Sel_LD;
					wreg_o = `True;
					reg1_read_o = `True;
                    reg2_read_o = `False;
					imm = {{20{I_imm[11]}},I_imm[11:0]};
					case (funct3)
						`F3_LB:		aluop_o = `EX_LB;
						`F3_LH:		aluop_o = `EX_LH;
						`F3_LW:		aluop_o = `EX_LW;
						`F3_LBU:	aluop_o = `EX_LBU;
						`F3_LHU:	aluop_o = `EX_LHU;
					endcase
				end

				`STORE: begin
					alusel_o = `Sel_SD;
					wreg_o = `False;
                    reg1_read_o = `True;
                    reg2_read_o = `True;
                    imm = {{20{S_imm[11]}},S_imm[11:0]};
					case (funct3)
						`F3_SB:		aluop_o = `EX_SB;
						`F3_SH:		aluop_o = `EX_SH;
						`F3_SW:		aluop_o = `EX_SW;
					endcase
				end
			endcase
		end

	end

	always @(*) begin
		flag1 = `False;
        reg1_o = `ZeroWord;
		if(rst == `True) begin
			reg1_o = `ZeroWord;
		end else if(reg1_read_o == `True)begin
			//forwarding
			if(ex_wreg == `True && ex_wd == rs1) begin
				if(ex_ld == `True) flag1 = `True;
				else reg1_o = ex_wdata;
			end else if(mem_wreg == `True && mem_wd == rs1) begin
				reg1_o = mem_wdata;
			end else begin
				reg1_o = reg1_data_i;
			end
		end else if(reg1_read_o == `False) begin
			reg1_o = imm;
		end else begin
			reg1_o = `ZeroWord;
		end
	end

	always @(*) begin
		flag2 = `False;
        reg2_o = `ZeroWord;
		if(rst == `True) begin
			reg2_o = `ZeroWord;
		end else if(reg2_read_o == `True)begin
			//forwarding
			if(ex_wreg == `True && ex_wd == rs2) begin
				if(ex_ld == `True) flag2 = `True;
				else reg2_o = ex_wdata;
			end else if(mem_wreg == `True && mem_wd == rs2) begin
				reg2_o = mem_wdata;
			end else begin
				reg2_o = reg2_data_i;
			end
		end else if(reg2_read_o == `False) begin
			reg2_o = imm;
		end else begin
			reg2_o = `ZeroWord;
		end
	end

	always @(*) begin
		if(rst == `True) begin
			offset_o = `ZeroWord;
		end else begin
			offset_o = imm;
		end
	end

endmodule
