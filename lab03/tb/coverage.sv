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
module coverage(fifomult2024_bfm bfm);
import fifomult2024_tb_pkg::*;

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
        @(posedge bfm.clk);
	    	if (!bfm.rst_n) data_in_coverage_cntr = 1'b0;
			if(bfm.data_in_valid === 1'b1 && data_in_coverage_cntr == 1'b1)begin
	            data_coverage_B = bfm.data_in;
	           coverage_parity_B = bfm.data_in_parity;
	            data_in_coverage_cntr = 1'b0;
				c_00_FF.sample();
	        end
	        else if(bfm.data_in_valid === 1'b1 && data_in_coverage_cntr == 1'b0)begin
	            data_coverage_A = bfm.data_in;
	            coverage_parity_A = bfm.data_in_parity;
	            data_in_coverage_cntr = 1'b1;
	        end
			#1;
            if($get_coverage() == 100) break; //disable, if needed

//             you can print the coverage after each sample
            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
        
    end
end : coverage

endmodule : coverage


