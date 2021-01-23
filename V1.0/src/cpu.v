`include "defines.v"
// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

wire id_wreg, id_ex_wreg, ex_wreg, ex_mem_wreg, mem_wreg, mem_wb_wreg;
wire[`RegAddrBus] id_wd, id_ex_wd, ex_wd, ex_mem_wd, mem_wd, mem_wb_wd;
wire[`RegBus] ex_wdata, ex_mem_wdata, mem_wdata, mem_wb_wdata;

wire id_re1, id_re2;
wire[`RegAddrBus] id_raddr1, id_raddr2;
wire[`RegBus] reg_rdata1, reg_rdata2;

wire[`LenBus] len;

wire pc_stall, if_stall, id_stall, ex_stall, mem_stall;
wire if_clear, id_clear, mem_clear;
wire if_flag, id_flag, mem_flag;
wire jmp;
wire[`InstAddrBus] jmp_pc, pc, if_pc, if_id_pc, id_pc, id_ex_pc;
wire[`InstBus] mem_ctrl_inst, if_inst, if_id_inst;
wire mem_ctrl_inst_ok, mem_ctrl_mem_ok;
wire inst_enable, w_enable, r_enable;
wire[`RegBus] w_data, r_data;
wire[`MemAddrBus] ex_ma, ex_mem_ma, mem_ma;

wire ex_ld;

wire[`AluOpBus] id_aluop, id_ex_aluop, ex_aluop, ex_mem_aluop;
wire[`AluSelBus] id_alusel, id_ex_alusel;
wire[`RegBus] id_reg1, id_reg2, id_ex_reg1, id_ex_reg2;
wire[`RegBus] id_offset, id_ex_offset;


regfile regfile0(
	.clk(clk_in), .rst(rst_in),
	.we(mem_wb_wreg), .waddr(mem_wb_wd), .wdata(mem_wb_wdata),
	.re1(id_re1), .raddr1(id_raddr1), .rdata1(reg_rdata1),
	.re2(id_re2), .raddr2(id_raddr2), .rdata2(reg_rdata2)
);

mem_ctrl mem_ctrl0(
	.clk(clk_in), .rst(rst_in),
	.pc_i(if_pc), .inst_enable(inst_enable), 
	.r_enable(r_enable), .w_enable(w_enable), .mem_addr_i(mem_ma), .wdata(w_data), .len(len),
	.inst_o(mem_ctrl_inst), .inst_ok(mem_ctrl_inst_ok), .rdata(r_data), .mem_ok(mem_ctrl_mem_ok),
	.io_buffer_full(io_buffer_full), .mem_din(mem_din), .mem_dout(mem_dout), .mem_addr_o(mem_a), .mem_wr(mem_wr)
);

stall_ctrl stall_ctrl0(
	.if_in(if_flag), .id_in(id_flag), .mem_in(mem_flag), .jmp(jmp), .rdy(rdy_in),
	.pc_stall(pc_stall),
	.if_stall(if_stall), .if_clear(if_clear),
	.id_stall(id_stall), .id_clear(id_clear),
	.ex_stall(ex_stall),
	.mem_stall(mem_stall), .mem_clear(mem_clear)
);

pc pc0(
	.clk(clk_in), .rst(rst_in),
	.pc_stall(pc_stall), .jmp(jmp), .pc_i(jmp_pc),
	.pc_o(pc)
);

If if0(
	.clk(clk_in), .rst(rst_in), .jmp(jmp),
	.pc_i(pc), .inst_i(mem_ctrl_inst), .inst_ok(mem_ctrl_inst_ok),
	.pc_o(if_pc), .inst_enable(inst_enable), .inst_o(if_inst), .if_flag(if_flag)
);

if_id if_id0(
	.clk(clk_in), .rst(rst_in),
	.if_pc(if_pc), .if_inst(if_inst),
	.if_stall(if_stall), .if_clear(if_clear),
	.id_pc(if_id_pc), .id_inst(if_id_inst)
);

id id0(
	.rst(rst_in),
	.pc_i(if_id_pc), .inst_i(if_id_inst),
	.reg1_data_i(reg_rdata1), .reg2_data_i(reg_rdata2),
	.ex_wd(ex_wd), .ex_wreg(ex_wreg), .ex_wdata(ex_wdata), .ex_ld(ex_ld),
	.mem_wd(mem_wd), .mem_wreg(mem_wreg), .mem_wdata(mem_wdata),
	.pc_o(id_pc), .reg1_read_o(id_re1), .reg2_read_o(id_re2),
	.reg1_addr_o(id_raddr1), .reg2_addr_o(id_raddr2),
	.aluop_o(id_aluop), .alusel_o(id_alusel), 
	.reg1_o(id_reg1), .reg2_o(id_reg2), .offset_o(id_offset),
	.wd_o(id_wd), .wreg_o(id_wreg), .id_flag(id_flag)
);

id_ex id_ex0(
	.clk(clk_in), .rst(rst_in),
	.id_stall(id_stall), .id_clear(id_clear),
	.id_pc(id_pc), .id_alusel(id_alusel), .id_aluop(id_aluop), 
	.id_reg1(id_reg1), .id_reg2(id_reg2), .id_offset(id_offset),
	.id_wd(id_wd), .id_wreg(id_wreg),
	.ex_pc(id_ex_pc), .ex_alusel(id_ex_alusel), .ex_aluop(id_ex_aluop), 
	.ex_reg1(id_ex_reg1), .ex_reg2(id_ex_reg2), .ex_offset(id_ex_offset),
	.ex_wd(id_ex_wd), .ex_wreg(id_ex_wreg)
);

ex ex0(
	.rst(rst_in),
	.pc_i(id_ex_pc), .alusel_i(id_ex_alusel), .aluop_i(id_ex_aluop),
	.reg1_i(id_ex_reg1), .reg2_i(id_ex_reg2),
	.offset_i(id_ex_offset), .wd_i(id_ex_wd), .wreg_i(id_ex_wreg),
	.wd_o(ex_wd), .wreg_o(ex_wreg), .wdata_o(ex_wdata),
	.pc_o(jmp_pc), .jmp(jmp),
	.mem_addr_o(ex_ma), .is_ld(ex_ld),
	.aluop_o(ex_aluop)
);

ex_mem ex_mem0(
	.clk(clk_in), .rst(rst_in),
	.ex_stall(ex_stall),
	.ex_wd(ex_wd), .ex_wreg(ex_wreg), .ex_wdata(ex_wdata), .ex_mem_addr(ex_ma), .ex_aluop(ex_aluop),
	.mem_wd(ex_mem_wd), .mem_wreg(ex_mem_wreg), .mem_wdata(ex_mem_wdata), .mem_mem_addr(ex_mem_ma), .mem_aluop(ex_mem_aluop)
);

mem mem0(
	.rst(rst_in),
	.wd_i(ex_mem_wd), .wreg_i(ex_mem_wreg), .wdata_i(ex_mem_wdata), .mem_addr_i(ex_mem_ma), .aluop(ex_mem_aluop),
	.r_enable(r_enable), .w_enable(w_enable), .mem_addr_o(mem_ma), .wdata(w_data), .len(len), .rdata(r_data), .mem_ok(mem_ctrl_mem_ok),
	.wd_o(mem_wd), .wreg_o(mem_wreg), .wdata_o(mem_wdata), .mem_flag(mem_flag)
);

mem_wb mem_wb0(
	.clk(clk_in), .rst(rst_in),
	.mem_stall(mem_stall), .mem_clear(mem_clear),
	.mem_wd(mem_wd), .mem_wreg(mem_wreg), .mem_wdata(mem_wdata), 
	.wb_wd(mem_wb_wd), .wb_wreg(mem_wb_wreg), .wb_wdata(mem_wb_wdata)
);

endmodule