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

 Last modification: 2024-10-22 AGH RSz
 NOTE: scoreboard uses bfm signals directly - this is a temporary solution
 */

module scoreboard(fifomult2024_bfm bfm);

import fifomult2024_tb_pkg::*;

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color;
	
	 typedef struct packed {
        bit signed [15:0] data_in_A;
        bit signed [15:0] data_in_B;
	    bit parity_A;
	    bit parity_B;
    } data_packet_t;


    typedef struct packed {
        logic signed [31:0] data_out;
        bit data_in_parity_error ;
	    bit data_out_parity;
    } data_expected_packet_t;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

test_result   tr             = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function data_expected_packet_t get_expected(
    data_packet_t    data_packet
);
    data_expected_packet_t expected_values;
    `ifdef DEBUG
    $display("%0t DEBUG: get_excepted(%0d,%0d) parity(%0d,%0d)", $time, data_packet.data_in_A, data_packet.data_in_B,data_packet.parity_A, data_packet.parity_B);
    `endif
 


    if (data_packet.parity_A == ^(data_packet.data_in_A) && data_packet.parity_B == ^(data_packet.data_in_B)) begin
        expected_values.data_out = data_packet.data_in_A * data_packet.data_in_B;
        expected_values.data_in_parity_error = 1'b0;
        expected_values.data_out_parity = ^expected_values.data_out;
    end
    else begin
        expected_values.data_out = data_packet.data_in_A * data_packet.data_in_B;
        expected_values.data_in_parity_error = 1'b1;
        expected_values.data_out_parity = ^expected_values.data_out;
    end
        `ifdef DEBUG
    $display("%0t DEBUG: data_out= %0d |parity_err= %0d | parity_out= %0d", $time, expected_values.data_out, expected_values.data_in_parity_error,expected_values.data_out_parity);
    `endif
    
    return expected_values;
endfunction : get_expected

//------------------------------------------------------------------------------
// data registering and checking
//------------------------------------------------------------------------------

// fifo for storing input and expected data
data_packet_t sb_data_q  [$];

// storing data from tpgen and expected data
 data_packet_t                 data_buf; //purely for scoreboard
    bit data_in_valid_cntr = 1'b0;  // only for scoreboard

    always @(posedge bfm.clk) begin:scoreboard_fe_blk
        if(bfm.data_in_valid === 1'b1 && data_in_valid_cntr == 1'b1)begin
            data_buf.data_in_B = bfm.data_in;
            data_buf.parity_B = bfm.data_in_parity;
            sb_data_q.push_front(data_buf);
            data_in_valid_cntr = 1'b0;
        end
        else if(bfm.data_in_valid === 1'b1 && data_in_valid_cntr == 1'b0)begin
            data_buf.data_in_A = bfm.data_in;
            data_buf.parity_A = bfm.data_in_parity;
            data_in_valid_cntr = 1'b1;
        end

        if(!bfm.rst_n) begin
            sb_data_q.delete();
            data_in_valid_cntr = 1'b0;
        end
    end
    

// checking the data from the DUT
always @(negedge bfm.clk) begin : scoreboard_be_blk

  		data_expected_packet_t data_exp_s;
	    
        if(bfm.data_out_valid) begin:verify_result
	        
	        data_packet_t dp;
            dp= sb_data_q.pop_back();
	        

            data_exp_s = get_expected(dp);

            CHK_RESULT: if({bfm.data_out, bfm.data_in_parity_error, bfm.data_out_parity} == data_exp_s) begin
           `ifdef DEBUG
                $display("%0t Test passed for A=%0d B=%0d", $time, dp.data_in_A, dp.data_in_B);
           `endif
            end
            else begin
                tr <= TEST_FAILED;
                $error("%0t Test FAILED for data_in_A=%0d data_in_B=%0d parity_A=%0b parity_B=%0b ||| received data: %d  expected data: %d. received data_out_parity_err: %b  expected data_out_parity_error: %b.",
                    $time, dp.data_in_A, dp.data_in_B, dp.parity_A, dp.parity_B, bfm.data_out, data_exp_s.data_out, bfm.data_in_parity_error, data_exp_s.data_in_parity_error);
            end;

        end
    end : scoreboard_be_blk

//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

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
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
function void print_test_result (test_result r);
    if(tr == TEST_PASSED) begin
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

//------------------------------------------------------------------------------
// print the test result at the simulation end
//------------------------------------------------------------------------------
final begin : finish_of_the_test
    print_test_result(tr);
end

endmodule : scoreboard






