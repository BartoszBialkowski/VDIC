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
// Coverage block
//------------------------------------------------------------------------------

        bit signed [15:0] data_coverage_A;
        bit signed [15:0] data_coverage_B;
	    bit coverage_parity_A;
	    bit coverage_parity_B;

// Covergroup checking for min and max arguments of the ALU
covergroup corner_values_on_operations;

    option.name = "covergroup_corner_values_on_operations";

    paritycheck_A: coverpoint coverage_parity_A {
        // #A test valid data at the input
        bins A_valid_data = PARITY_OK;

        // #A test invalid data at the input
        bins A_invalid_data = PARITY_ERR;
    }
    paritycheck_B: coverpoint coverage_parity_B {
        // #B test valid data at the input
        bins B_valid_data = PARITY_OK;

        // #B test invalid data at the input
        bins B_invalid_data = PARITY_ERR;
    }

    a_leg: coverpoint data_coverage_A {
        bins min          = {16'sh8000};
        bins minus_one    = {16'shFFFF};
        bins zeros         = {16'sh0000};
        bins others        = {[16'shFFFE:16'sh8001], [16'sh0002:16'sh7FFE]};
        bins one          = {16'sh0001};
        bins max          = {16'sh7FFF};
    }

    b_leg: coverpoint data_coverage_B {
        bins min          = {16'sh8000};
        bins minus_one    = {16'shFFFF};
        bins zeros         = {16'sh0000};
        bins others        = {[16'shFFFE:16'sh8001], [16'sh0002:16'sh7FFE]};
        bins one          = {16'sh0001};
        bins max          = {16'sh7FFF};
    }

    All_operations_corners: cross a_leg, b_leg, paritycheck_A, paritycheck_B  {

        ignore_bins others_only =
        binsof(a_leg.others) && binsof(b_leg.others);
    }

endgroup

    bit data_in_coverage_cntr = 1'b0;  // only for coverage
corner_values_on_operations        c_00_FF;
initial begin : coverage
    c_00_FF = new();
    forever begin : sample_cov
        @(posedge clk);
	    	if (!rst_n) data_in_coverage_cntr = 1'b0;
			if(data_in_valid == 1'b1 && data_in_coverage_cntr == 1'b1)begin
	            data_coverage_B = data_in;
	           coverage_parity_B = data_in_parity;
	            data_in_coverage_cntr = 1'b0;
				c_00_FF.sample();
	        end
	        else if(data_in_valid == 1'b1 && data_in_coverage_cntr == 1'b0)begin
	            data_coverage_A = data_in;
	            coverage_parity_A = data_in_parity;
	            data_in_coverage_cntr = 1'b1;
	        end
			#1;
            if($get_coverage() == 100) break; //disable, if needed

//             you can print the coverage after each sample
            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
        
    end
end : coverage

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
    repeat (15000) begin : tpgen_main_blk
	    
	    reset_probability();
	    
 		@(negedge clk);
	        if(busy_out) begin
	            @(negedge busy_out);
	            @(negedge clk);
		    end    
	 
		        data_in_A_local      = get_data();
		        parity_A_local 		 = get_paritycheck();
	            data_in = data_in_A_local;
	            get_parity(data_in, parity_A_local ,data_in_parity);
	            data_in_valid = 1'b1;

      	@(negedge clk)begin;
        	data_in_valid = 1'b0;
	    end  	
	    
	        if(busy_out) begin
	            @(negedge busy_out);
	        	@(negedge clk);    
		    end    
	
		        data_in_B_local      = get_data();
		        parity_B_local 		 = get_paritycheck();
	            data_in = data_in_B_local;           
	            get_parity(data_in, parity_B_local , data_in_parity);
	            data_in_valid = 1'b1;

        @(negedge clk)begin
        	data_in_valid = 1'b0;
	    end    
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
	sb_data_q.delete();
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_fifo

task reset_probability();
    bit [4:0] reset_probability;
    reset_probability = 5'($random);
    case (reset_probability)
        5'b00000 : 	reset_fifo();
    default : ;
    endcase // case (reset_probability)
endtask : reset_probability

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------


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


//-------------------------------------------------------------------
// Scoreboard, part 1  command receiver and reference model function
//-------------------------------------------------------------------

      data_packet_t               sb_data_q   [$];

  data_packet_t                 scoreboard_data; 
    bit data_in_valid_cntr = 1'b0;  

    always @(posedge clk) begin:scoreboard_fe_blk
        if(data_in_valid == 1'b1 && data_in_valid_cntr == 1'b1)begin
            scoreboard_data.data_in_B = data_in;
            scoreboard_data.parity_B = data_in_parity;
            sb_data_q.push_front(scoreboard_data);
            data_in_valid_cntr = 1'b0;
        end
        else if(data_in_valid == 1'b1 && data_in_valid_cntr == 1'b0)begin
            scoreboard_data.data_in_A = data_in;
            scoreboard_data.parity_A = data_in_parity;
            data_in_valid_cntr = 1'b1;
        end

        if(!rst_n) begin
            sb_data_q.delete();
            data_in_valid_cntr = 1'b0;
        end


    end
    
//---------------------------------------------------------------
// Scoreboard, part 2 - data checker
//---------------------------------------------------------------


    always @(negedge clk) begin : scoreboard_be_blk

  		data_expected_packet_t data_exp_s;
	    
        if(data_out_valid) begin:verify_result
	        
	        data_packet_t dp;
            dp= sb_data_q.pop_back();
	        

            data_exp_s = get_expected(dp);

            CHK_RESULT: if({data_out, data_in_parity_error, data_out_parity} == data_exp_s) begin
           `ifdef DEBUG
                $display("%0t Test passed for A=%0d B=%0d", $time, dp.data_in_A, dp.data_in_B);
           `endif
            end
            else begin
                test_result <= TEST_FAILED;
                $error("%0t Test FAILED for data_in_A=%0d data_in_B=%0d parity_A=%0b parity_B=%0b ||| received data: %d  expected data: %d. received data_out_parity_err: %b  expected data_out_parity_error: %b.",
                    $time, dp.data_in_A, dp.data_in_B, dp.parity_A, dp.parity_B, data_out, data_exp_s.data_out, data_in_parity_error, data_exp_s.data_in_parity_error);
            end;

        end
    end : scoreboard_be_blk



endmodule : top
