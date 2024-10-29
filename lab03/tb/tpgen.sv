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
 */
module tpgen(fifomult2024_bfm bfm);
    
import fifomult2024_tb_pkg::*;
	
bit signed [15:0] 	data_in_A_local;
bit signed [15:0] 	data_in_B_local;
paritycheck_t 		parity_A_local;
paritycheck_t 		parity_B_local;	

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


task reset_probability();
    bit [4:0] reset_probability;
    reset_probability = 5'($random);
    case (reset_probability)
        5'b00000 : 	bfm.reset_fifo();
    default : ;
    endcase // case (reset_probability)
endtask : reset_probability


//------------------------
// Tester main

initial begin : tpgen
    bfm.reset_fifo();
    repeat (15000) begin : tpgen_main_blk
	    
	    reset_probability();
	    
 		@(negedge bfm.clk);
	        if(bfm.busy_out) begin
	            @(negedge bfm.busy_out);
	            @(negedge bfm.clk);
		    end    
	 
		        data_in_A_local      = get_data();
		        parity_A_local 		 = get_paritycheck();
	            bfm.data_in = data_in_A_local;
	            get_parity(bfm.data_in, parity_A_local ,bfm.data_in_parity);
	            bfm.data_in_valid = 1'b1;

      	@(negedge bfm.clk)begin;
        	bfm.data_in_valid = 1'b0;
	    end  	
	    
	        if(bfm.busy_out) begin
	            @(negedge bfm.busy_out);
	        	@(negedge bfm.clk);    
		    end    
	
		        data_in_B_local      = get_data();
		        parity_B_local 		 = get_paritycheck();
	            bfm.data_in = data_in_B_local;           
	            get_parity(bfm.data_in, parity_B_local , bfm.data_in_parity);
	            bfm.data_in_valid = 1'b1;

        @(negedge bfm.clk)begin
        	bfm.data_in_valid = 1'b0;
	    end    
    // print coverage after each loop
    // $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    // if($get_coverage() == 100) break;
    end : tpgen_main_blk
    $finish;
end : tpgen


endmodule : tpgen
