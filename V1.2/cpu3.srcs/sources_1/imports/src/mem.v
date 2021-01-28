`include  "defines.v"

module mem(
	input wire rst,
	
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,
	input wire[`MemAddrBus] mem_addr_i,
	input wire[`AluOpBus] aluop,

	output reg r_enable,
	output reg w_enable,
	output reg[`MemAddrBus] mem_addr_o,
	output reg[`RegBus] wdata,
	output reg[`LenBus] len,

	input wire[`RegBus] rdata,
	input wire mem_ok,
	
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
	output reg mem_flag
);

	always @(*) begin
		
		r_enable = `False;
		w_enable = `False;
		mem_addr_o = `ZeroWord;
		wdata = `ZeroWord;
		len = 3'b0;

		wd_o = `ZeroWord;
		wreg_o = `False;
		wdata_o = `ZeroWord;
		mem_flag = `False;

		if(rst == `False) begin
			wd_o = wd_i;
			wreg_o = wreg_i;
			wdata_o = wdata_i;
			mem_addr_o = mem_addr_i;
			if(aluop != `EX_NOP) begin
				case(aluop) 
					`EX_LW: begin
						len = 3'b100;
						r_enable = `True;
						wdata_o = rdata;
					end
					`EX_LH: begin
						len = 3'b010;
						r_enable = `True;
						wdata_o = {{16{rdata[15]}}, rdata[15:0]};
					end
					`EX_LHU: begin
						len = 3'b010;
						r_enable = `True;
						wdata_o = {16'b0, rdata[15:0]};
					end
					`EX_LB: begin
						len = 3'b001;
						r_enable = `True;
						wdata_o = {{24{rdata[7]}}, rdata[7:0]};
					end
					`EX_LBU: begin
						len = 3'b001;
						r_enable = `True;
						wdata_o = {24'b0, rdata[7:0]};
					end
					`EX_SW: begin
						len = 3'b100;
						w_enable = `True;
						wdata = wdata_i;
					end
					`EX_SH: begin
						len = 3'b010;
						w_enable = `True;
						wdata = {16'b0, wdata_i[15:0]};
					end
					`EX_SB: begin
						len = 3'b001;
						w_enable = `True;
						wdata = {24'b0, wdata_i[7:0]};
					end
				endcase
				mem_flag = !mem_ok;
			end
		end
	end

endmodule