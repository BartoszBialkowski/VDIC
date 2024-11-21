class coverage;
	
//import fifomult2024_tb_pkg::*;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
protected virtual fifomult2024_bfm bfm;


local bit             [15:0] data_prev;
local bit                    data_prev_parity;
local bit 				   cov_valid;

typedef enum bit {
    PARITY_OK             = 1'b0, //change names
    PARITY_ERR           = 1'b1
} paritycheck_t;

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking for min and max arguments of the ALU
covergroup corner_values_on_ops;

    option.name = "cg_corner_values_on_ops";
	
	data_prev_leg: coverpoint data_prev {
		bins min            = {16'h8000} ;
		bins max            = {16'h7FFF} ;
		bins zero           = {16'h0000} ;
		bins lpos           = {16'h0001} ;
		bins hneg           = {16'hFFFF} ;
	}
	
	data_leg: coverpoint bfm.data_in {
		bins min            = {16'h8000} ;
		bins max            = {16'h7FFF} ;
		bins zero           = {16'h0000} ;
		bins lpos           = {16'h0001} ;
		bins hneg           = {16'hFFFF} ;
	}

    paritycheck_prev_leg: coverpoint data_prev_parity {
        //  test valid data at the input
        bins valid_data = PARITY_OK;

        //  test invalid data at the input
        bins invalid_data = PARITY_ERR;
    }
    
    paritycheck_leg: coverpoint bfm.data_in_parity {
        //  test valid data at the input
        bins valid_data = PARITY_OK;

        // #A test invalid data at the input
        bins invalid_data = PARITY_ERR;
    }
    
    B_op_corners: cross data_prev_leg, data_leg, paritycheck_prev_leg, paritycheck_leg  {


    }

endgroup

function new (virtual fifomult2024_bfm b);
	corner_values_on_ops = new();
	bfm = b;
endfunction : new

task execute();
    forever begin : sample_cov
        @(posedge bfm.clk);
        if((cov_valid == 1 && bfm.data_in_valid == 1) || !bfm.rst_n) begin
            corner_values_on_ops.sample();
        	cov_valid = 0;
            /* #1step delay is necessary before checking for the coverage
             * as the .sample methods run in parallel threads
             */
            #1;
            if($get_coverage() == 100) break; //disable, if needed

//             you can print the coverage after each sample
            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
        end
        else if(bfm.data_in_valid == 1 && cov_valid == 0)begin
	        data_prev = bfm.data_in;
	        data_prev_parity = bfm.data_in_parity;
	        cov_valid = 1;
        end
    end
endtask
//end : coverage
	
endclass : coverage
