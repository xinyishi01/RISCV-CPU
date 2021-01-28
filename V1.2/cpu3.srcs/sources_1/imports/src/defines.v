`ifndef Defined
`define Defined


`define ZeroWord 32'h00000000

`define InstLen 32
`define AddrLen 32
`define RegNum 32
`define RegAddrLen 5
`define NOPAddr 5'b00000
`define RegLen 32

`define Read 1'b0
`define Write 1'b1
`define True 1'b1
`define False 1'b0

`define InstAddrBus 31:0
`define InstBus 31:0
`define RegAddrBus 4:0
`define RegBus 31:0
`define MemAddrBus 31:0
`define MemBus 7:0
`define AluOpBus 4:0
`define AluSelBus 3:0
`define IndexBus 6:0
`define MapSize 127
`define MapBus 127:0
`define LenBus 2:0


`define OP_IMM		7'b0010011
`define OP			7'b0110011
`define LUI			7'b0110111
`define AUIPC		7'b0010111
`define JAL			7'b1101111
`define JALR		7'b1100111
`define BRANCH		7'b1100011
`define LOAD		7'b0000011
`define STORE		7'b0100011

`define F3_ADD_SUB	3'b000
`define F3_SLL		3'b001
`define F3_SLT		3'b010
`define F3_SLTU		3'b011
`define F3_XOR		3'b100
`define F3_SRL_SRA	3'b101
`define F3_OR		3'b110
`define F3_AND		3'b111

`define F3_BEQ		3'b000
`define F3_BNE		3'b001
`define F3_BLT		3'b100	
`define F3_BGE		3'b101
`define F3_BLTU		3'b110
`define F3_BGEU		3'b111

`define F3_LB		3'b000
`define F3_LH		3'b001
`define F3_LW		3'b010
`define F3_LBU		3'b100
`define F3_LHU		3'b101
`define F3_SB		3'b000
`define F3_SH		3'b001
`define F3_SW		3'b010

`define F7_ADD 		7'b0000000
`define F7_SUB 		7'b0100000
`define F7_SRL 		7'b0000000
`define F7_SRA 		7'b0100000

`define Sel_Nor		0
`define Sel_Jmp		1
`define Sel_Br		2
`define Sel_LD		3
`define Sel_SD		4

`define EX_NOP		0

`define EX_OR		1
`define EX_AND		2
`define EX_XOR		3
`define EX_ADD		4
`define EX_SLT		5
`define EX_SLTU		6
`define EX_SLL		7
`define EX_SRL		8
`define EX_SRA		9
`define EX_LUI		10
`define EX_AUIPC	11
`define EX_SUB      12

`define EX_JAL		1
`define EX_JALR		2
`define EX_BEQ		3
`define EX_BNE		4
`define EX_BLT		5
`define EX_BLTU		6
`define EX_BGE		7
`define EX_BGEU		8

`define EX_LB		1
`define EX_LBU		2
`define EX_LH		3
`define EX_LHU		4
`define EX_LW		5
`define EX_SB		6
`define EX_SH		7
`define EX_SW		8


`endif