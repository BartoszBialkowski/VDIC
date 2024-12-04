//import fifomult2024_tb_pkg::*;

class coverage extends uvm_subscriber #(command_s);
    `uvm_component_utils(coverage)

	//------------------------------------------------------------------------------
	// Coverage block
	//------------------------------------------------------------------------------
	
	protected bit signed [15:0] data_coverage_A;
	protected bit signed [15:0] data_coverage_B;
	protected bit coverage_parity_A;
	protected bit coverage_parity_B;
	
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
		    
		    ignore_bins others_A = binsof(a_leg.others) && (binsof(b_leg.min)|| binsof(b_leg.zeros)|| binsof(b_leg.max)|| binsof(b_leg.minus_one)|| binsof(b_leg.one));
		    ignore_bins others_B = binsof(b_leg.others) && (binsof(a_leg.min)|| binsof(a_leg.zeros)|| binsof(a_leg.max)|| binsof(a_leg.minus_one)|| binsof(a_leg.one));
	    }
	
	endgroup
	
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
        corner_values_on_operations  = new();
    endfunction : new

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------	
	    
	    function void write(command_s t);
        data_coverage_A      = t.data_in_A;
        data_coverage_B      = t.data_in_B;
        coverage_parity_A = t.parity_A;
        coverage_parity_B = t.parity_B;   
        corner_values_on_operations.sample();
    endfunction : write

endclass : coverage

