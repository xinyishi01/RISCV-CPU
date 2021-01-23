`include "defines.v"

module regfile(
	input wire clk,
	input wire rst,

	input wire we,
	input wire[`RegAddrBus] waddr,
	input wire[`RegBus] wdata,

	input wire re1,
	input wire[`RegAddrBus] raddr1,
	output reg[`RegBus] rdata1,

	input wire re2,
	input wire[`RegAddrBus] raddr2,
	output reg[`RegBus] rdata2
);

    reg[`RegBus] regs[0:`RegNum - 1];
	integer i;

	always @(posedge clk) begin
		if(rst == `True) begin
			for (i = 0; i < `RegNum; i = i + 1) begin
				regs[i] <= `ZeroWord;
			end
		end else if(we == `True) begin
			if(waddr != `NOPAddr) begin
				regs[waddr] <= wdata;
			end
		end
	end

	always @(*) begin
		if(rst == `True || re1 == `False) begin
			rdata1 = `ZeroWord;
		end else begin
			if(raddr1 == `NOPAddr) begin
				rdata1 = `ZeroWord;
			end else begin
				if((raddr1 == waddr) && we == `True) begin
					rdata1 = wdata;
				end else begin
					rdata1 = regs[raddr1];
				end
			end
		end
	end

	always @(*) begin
		if(rst == `True || re2 == `False) begin
			rdata2 = `ZeroWord;
		end else begin
			if(raddr2 == `NOPAddr) begin
				rdata2 = `ZeroWord;
            end else begin
                if((raddr2 == waddr) && we == `True) begin
                    rdata2 = wdata;
                end else begin
                    rdata2 = regs[raddr2];
                end
            end
        end
	end
endmodule