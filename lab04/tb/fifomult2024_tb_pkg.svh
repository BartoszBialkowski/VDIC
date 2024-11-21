package fifomult2024_tb_pkg;

typedef enum bit {
    PARITY_OK             = 1'b0, //change names
    PARITY_ERR           = 1'b1
} paritycheck_t;

`include "coverage.svh"
`include "tpgen.svh"
`include "scoreboard.svh"
`include "testbench.svh"
	
endpackage