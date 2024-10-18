/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 History:
 2021-10-05 RSz, AGH UST - test modified to send all the data on negedge clk
 and check the data on the correct clock edge (covergroup on posedge
 and scoreboard on negedge). Scoreboard and coverage removed.
 */
module top;

//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------

typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

typedef enum bit {
    PARITY_OK            = 1'b0,
    PARITY_ERR           = 1'b1
} paritycheck_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

bit signed    [15:0] data_in;
bit                  clk;
bit                  rst_n;
bit                  data_in_parity;
bit                  data_in_valid;
wire                 busy_out;
wire 				 [31:0] data_out;
wire                 data_out_parity;
wire                 data_out_valid;
wire                 data_in_parity_error;

test_result_t        test_result = TEST_PASSED;

bit signed 			data_out_parity_exp;
bit signed 			data_in_parity_error_exp;
bit signed [31:0]	data_out_exp;
bit signed [15:0] 	data_in_A_local;
bit signed [15:0] 	data_in_B_local;
paritycheck_t 		parity_A_local;
paritycheck_t 		parity_B_local;
//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

fifomult2024 DUT (.data_in, .clk, .rst_n, .data_in_parity, .data_in_valid, .busy_out,
    .data_out, .data_out_parity, .data_out_valid, .data_in_parity_error);

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

// timestamp monitordata_in_valid   = 1'b0;
initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
        end
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------
//---------------------------------
// Random data generation functions
//---------------------------------
// Generating random data for DUT input
function shortint get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'h0000;
    else if (zero_ones == 3'b001)
        return 16'h7FFF;
    else if (zero_ones == 3'b010)
        return 16'hFFFF;
    else if (zero_ones == 3'b100)
        return 16'h8000;
    else if (zero_ones == 3'b101)
        return 16'h0001;
    else
        return 16'($random);

endfunction : get_data

//---------------------------------
// Generating random parity for DUT

function paritycheck_t get_paritycheck();
    bit [1:0] parity_result;
    parity_result = 2'($random);
    case (parity_result)
        2'b00 : 	return PARITY_OK;
        2'b01 : 	return PARITY_OK;
        2'b10 : 	return PARITY_ERR;
        2'b11 : 	return PARITY_OK;
        default : 	return PARITY_OK;
    endcase // case (parity_result)
endfunction : get_paritycheck

//---------------------------------
//Parity check for input data
task get_parity(
        input shortint   data_in,
        input paritycheck_t valid,
        output bit       parity
    );
    parity = ^data_in;

    if (valid == PARITY_ERR)
        parity = !parity;

endtask : get_parity

//------------------------
// Tester main

initial begin : tpgen
    reset_fifo();
    repeat (1000) begin : tpgen_main_blk

        
        @(negedge clk) begin
            data_in_A_local      = get_data();
	        data_in_B_local      = get_data();
	        parity_A_local 		 = get_paritycheck();
	        parity_B_local 		 = get_paritycheck();

        end
        if(!busy_out)begin        	      
            data_in = data_in_A_local;
            get_parity(data_in, parity_A_local ,data_in_parity);
            data_in_valid = 1'b1;
        end
        
        @(negedge clk)begin
        	data_in_valid = 1'b0;
	    end
        if(!busy_out)@(negedge clk)begin
            data_in = data_in_B_local;           
            get_parity(data_in, parity_B_local , data_in_parity);
            data_in_valid = 1'b1;
        end
        @(negedge clk)begin
        	data_in_valid = 1'b0;
	    end    
            //------------------------------------------------------------------------------
            // temporary data check - scoreboard will do the job later
        get_expected(data_in_A_local, data_in_B_local, parity_A_local ,parity_B_local , data_out_exp, data_out_parity_exp, data_in_parity_error_exp);
        @(posedge data_out_valid)
        if(data_out === data_out_exp & data_out_parity === data_out_parity_exp & data_in_parity_error === data_in_parity_error_exp) begin
            `ifdef DEBUG
            $display("Test PASSED for data_in_A=%0d data_in_B=%0d parity_A=%0b parity_B=%0b", data_in_A_local, data_in_B_local, parity_A_local, parity_B_local);
            `endif
        end
        else begin
            $display("Test FAILED for data_in_A=%0d data_in_B=%0d parity_A=%0b parity_B=%0b ", data_in_A_local, data_in_B_local, parity_A_local, parity_B_local);
            $display("Expected data: %d  received data: %d. Expected data_out_parity_exp: %b  received data_out_parity: %b. Expected data_in_parity_exp: %b  received data_in_parity_error: %b ", data_out_exp, data_out, data_out_parity_exp, data_out_parity, data_in_parity_error_exp, data_in_parity_error);
            test_result = TEST_FAILED;
        end;

    // print coverage after each loop
    // $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    // if($get_coverage() == 100) break;
    end : tpgen_main_blk
    $finish;
end : tpgen

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset_fifo();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_fifo", $time);
    `endif
    data_in_valid   = 1'b0;
    data_in_parity   = 1'b0;
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_fifo

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

task get_expected(
        input bit signed [15:0]    data_in_A,
        input bit signed [15:0]    data_in_B,
        input paritycheck_t    parity_A_local,
        input paritycheck_t    parity_B_local,

        output bit signed [31:0]            data_out,
        output bit            data_out_parity,
        output bit            data_in_parity_error
    );

`ifdef DEBUG
    $display("%0t DEBUG: get_excepted(%0d,%0d)", $time, data_in_A, data_in_B);
`endif

    if (parity_A_local == PARITY_OK && parity_B_local == PARITY_OK) begin
        data_out                = data_in_A * data_in_B;
        data_in_parity_error    = 1'b0;
        data_out_parity        = ^data_out;
    end
    else begin
        data_out                = 0;
        data_in_parity_error    = 1'b1;
        data_out_parity        = ^data_out;
    end

endtask : get_expected

//------------------------------------------------------------------------------
// Temporary. The scoreboard will be later used for checking the data
final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
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

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction


endmodule : top
