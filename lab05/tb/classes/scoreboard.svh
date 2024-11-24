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
 */
//import fifomult2024_tb_pkg::*;


class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
protected typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result;
	
	 protected typedef struct packed {
        bit signed [15:0] data_in_A;
        bit signed [15:0] data_in_B;
	    bit parity_A;
	    bit parity_B;
    } data_packet_t;


    protected typedef struct packed {
        logic signed [31:0] data_out;
        bit data_in_parity_error ;
	    bit data_out_parity;
    } data_expected_packet_t;
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------	

	protected virtual fifomult2024_bfm bfm;
	
    protected test_result tr = TEST_PASSED; // the result of the current test

    // fifo for storing input and expected data
    protected data_packet_t sb_data_q [$];
	protected data_packet_t                 data_buf; //purely for scoreboard

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

protected function data_expected_packet_t get_expected(
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

// storing data from tpgen and expected data
    local bit data_in_valid_cntr = 1'b0;  // only for scoreboard

     protected task store_cmd();
        forever begin:scoreboard_fe_blk
	            @(posedge bfm.clk);
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
     endtask
    
	local data_expected_packet_t data_exp_s;
// checking the data from the DUT
   protected task process_data_from_dut(); 
	    forever begin : scoreboard_be_blk
		    
		    @(negedge bfm.clk);
	  		
		    
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
        end
    endtask // scoreboard_be_blk 
    

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual fifomult2024_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    endtask : run_phase

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result r);
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
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(tr);
    endfunction : report_phase

endclass : scoreboard





