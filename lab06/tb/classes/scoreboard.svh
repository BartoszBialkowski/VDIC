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



class scoreboard extends uvm_subscriber #(data_expected_packet_t);
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
protected typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;
	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
//    virtual tinyalu_bfm bfm;
    uvm_tlm_analysis_fifo #(command_s) cmd_f;

  local test_result_t 	test_result  = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

	local function data_expected_packet_t get_expected(
			command_s data_packet
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

    

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new("cmd_f", this);
    endfunction : build_phase

    local function void fl();
	    cmd_f.flush(); 	    
    endfunction
    
    
    
    	function void write(data_expected_packet_t t);
        data_expected_packet_t predicted_result;
        command_s cmd;
		cmd_f.try_get(cmd);
//		do begin
//	        if (!cmd_f.try_get(cmd)) begin
////	            $fatal(1, "Missing command in self checker");
//	        end
//	               
//		end	
//        while ((cmd.rst_n == 1));
        
//        if(cmd.rst_n == 0) begin
//	        cmd.data_in_A            = 0;
//		    cmd.data_in_B            = 0;
//		    cmd.parity_A 	= 0;
//			cmd.parity_B 	= 0;
//	        cmd.rst_n = 1;
//        	fl(); 
//	        end
//        else begin
        predicted_result = get_expected(cmd);
		
		
		
        SCOREBOARD_CHECK:
        if (predicted_result.data_out == t.data_out) begin
//           `ifdef DEBUG
//            $display("%0t Test passed for A=%0d B=%0d", $time, cmd.A, cmd.B);
//            `endif
        end
        else begin
            $display ("FAILED: A: %0d  B: %0d, result: %0d", cmd.data_in_A, cmd.data_in_B, t.data_out);
            test_result = TEST_FAILED;
        end
	    //end
    endfunction : write

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
    protected function void print_test_result (test_result_t r);
        if(test_result == TEST_PASSED) begin
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
        print_test_result(test_result);
    endfunction : report_phase

endclass : scoreboard





