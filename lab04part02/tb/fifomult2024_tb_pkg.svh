/******************************************************************************
 * (C) Copyright 2024 AGH University All Rights Reserved
 *
 * MODULE:    fifomult2024_tb_pkg
 * DEVICE:
 * PROJECT:
 * AUTHOR:    BBialkowski
 * DATE:      2024 12:20:30
 *
 *******************************************************************************/
`timescale 1ns/1ps
package fifomult2024_tb_pkg;

typedef enum bit {
    PARITY_OK            = 1'b0,
    PARITY_ERR           = 1'b1
} paritycheck_t;
	
	
`include "coverage.svh"
`include "tpgen.svh"
`include "scoreboard.svh"
`include "testbench.svh"

endpackage : fifomult2024_tb_pkg
