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
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"

typedef enum bit {
    PARITY_OK            = 1'b0,
    PARITY_ERR           = 1'b1
} paritycheck_t;
	
   // terminal print colors
    typedef enum {
        COLOR_BOLD_BLACK_ON_GREEN,
        COLOR_BOLD_BLACK_ON_RED,
        COLOR_BOLD_BLACK_ON_YELLOW,
        COLOR_BOLD_BLUE_ON_WHITE,
        COLOR_BLUE_ON_WHITE,
        COLOR_DEFAULT
    } print_color;

//------------------------------------------------------------------------------
// package functions
//------------------------------------------------------------------------------

    // used to modify the color of the text printed on the terminal

    function void set_print_color ( print_color c );
        string ctl;
        case(c)
            COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
            COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
            COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
            COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
            COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
            COLOR_DEFAULT : ctl              = "\033\[0m\n";
            default : begin
                $error("set_print_color: bad argument");
                ctl                          = "";
            end
        endcase
        $write(ctl);
    endfunction

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
`include "coverage.svh"
`include "scoreboard.svh"
`include "base_tpgen.svh"
`include "random_tpgen.svh"
`include "corners_tpgen.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
`include "random_test.svh"
`include "add_test.svh"


endpackage : fifomult2024_tb_pkg
