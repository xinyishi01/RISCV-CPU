`include "defines.v"

module mem_ctrl (
	input wire clk,
	input wire rst,

	input wire[`InstAddrBus] pc_i,
	input wire inst_enable,

	input wire r_enable,
	input wire w_enable,
	input wire[`MemAddrBus] mem_addr_i,
	input wire[`RegBus] wdata,
	input wire[`LenBus] len,

	output reg[`InstBus] inst_o,
	output reg inst_ok,
	output reg[`RegBus] rdata,
	output reg mem_ok,

	input wire io_buffer_full,
	input wire[`MemBus] mem_din,
    output reg[`MemBus] mem_dout,
    output reg[`MemAddrBus] mem_addr_o,
    output reg mem_wr
);

	reg inst_busy;
	reg mem_busy;
	reg[`LenBus] now;
	reg[`MemBus] data[3:0];

	always @(posedge clk) begin
		if(rst == `True) begin
			inst_o <= `ZeroWord;
			inst_ok <= `False;
			rdata <= `ZeroWord;
			mem_ok <= `False;
			mem_dout <= 8'b0;
			mem_addr_o <= `ZeroWord;
			mem_wr <= `Read;
			inst_busy <= `False;
			mem_busy <= `False;
			now <= 3'b000;
			data[0] <= 8'b0; data[1] <= 8'b0;
			data[2] <= 8'b0; data[3] <= 8'b0;
		end else if(mem_busy) begin
			inst_ok <= `False;
			if(w_enable == `True) begin
				if(now == len) begin
					mem_ok <= `True;
					mem_busy <= `False;
					now <= 0;
					mem_wr <= `Read;
					mem_addr_o <= `ZeroWord;
				end else if(io_buffer_full == `False) begin
					mem_wr <= `Write;
					mem_addr_o <= mem_addr_i + now;
					mem_dout <= data[now];
					now <= now + 1;
				end else begin
					mem_wr <= `Read;
					mem_addr_o <= `ZeroWord;
				end
			end
			if(r_enable == `True) begin
				if(now == len) begin
					case(len) 
						3'b100: rdata <= {mem_din, data[2], data[1], data[0]}; //
						3'b010: rdata <= {16'b0, mem_din, data[0]};
						3'b001: rdata <= {24'b0, mem_din};
					endcase
					mem_ok <= `True;
					mem_busy <= `False;
					mem_addr_o <= `ZeroWord;
					now <= 0;
				end else begin
					if(now != 0) data[now - 1] <= mem_din;
					if(now < len - 1) mem_addr_o <= mem_addr_i + now + 1;
					now <= now + 1;
				end
			end
		end else if(inst_busy) begin
			mem_ok <= `False;
			if(inst_enable == `False) begin
				inst_o <= `ZeroWord;
				inst_ok <= `False;
				inst_busy <= `False;
				mem_addr_o <= `ZeroWord;
				now <= 0;
			end else if(now == 4) begin
				inst_o <= {mem_din, data[2], data[1], data[0]};
				inst_ok <= `True;
				inst_busy <= `False;
				mem_addr_o <= `ZeroWord;
				now <= 0;
			end else begin
				if(now != 0) data[now - 1] <= mem_din;
				if(now < 3) mem_addr_o <= pc_i + now + 1;
				now <= now + 1;
			end
		end else begin
			if(w_enable && io_buffer_full == `False && mem_ok == `False) begin
				case(len) 
					3'b100: begin
						data[3] <= wdata[31:24];
						data[2] <= wdata[23:16];
						data[1] <= wdata[15:8];
						data[0] <= wdata[7:0];
					end
					3'b010: begin
						data[1] <= wdata[15:8];
						data[0] <= wdata[7:0];
					end
					3'b001: begin
						data[0] <= wdata[7:0];
					end
				endcase
				now <= 1;
				mem_addr_o <= mem_addr_i;
				mem_dout <= wdata[7:0];
				mem_wr <= `Write;
				inst_ok <= `False;
				mem_ok <= `False;
				mem_busy <= `True;
			end else if(r_enable && mem_ok == `False) begin
				now <= 0;
				mem_wr <= `Read;
				mem_dout <= 8'b0;
				inst_ok <= `False;
				mem_addr_o <= mem_addr_i;
				mem_ok <= `False;
				data[0] <= 8'b0; data[1] <= 8'b0;
				data[2] <= 8'b0; data[3] <= 8'b0;
				mem_busy <= `True;
			end else if(inst_enable && inst_ok == `False) begin
				now <= 0;
				mem_wr <= `Read;
				mem_dout <= 8'b0;
				mem_ok <= `False;
				inst_ok <= `False;
				mem_addr_o <= pc_i;
				data[0] <= 8'b0; data[1] <= 8'b0;
				data[2] <= 8'b0; data[3] <= 8'b0;
				inst_busy <= `True;
			end else begin
				now <= 0;
				mem_wr <= `Read;
				mem_dout <= 8'b0;
				mem_addr_o <= `ZeroWord;
				inst_busy <= `False;
				mem_busy <= `False;
				inst_ok <= `False;
				mem_ok <= `False;
			end
		end
	end

endmodule