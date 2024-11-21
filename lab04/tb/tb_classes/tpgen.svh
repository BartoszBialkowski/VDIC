class tpgen;
	
	protected virtual fifomult2024_bfm bfm;
	
	function new(virtual fifomult2024_bfm b);
		bfm = b;
	endfunction : new
	
//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------
//---------------------------------
// Random data generation functions
//---------------------------------

function paritycheck_t get_paritycheck();
    bit [2:0] op_choice;
    op_choice = 3'($random);
    case (op_choice)
        3'b000 : return PARITY_ERR; //12.5% probability
        default : return PARITY_OK;
    endcase
endfunction : get_paritycheck

//---------------------------------
// Generating random data for DUT input
//---------------------------------

function shortint get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'h0000; //0
    else if (zero_ones == 3'b001)
        return 16'h7FFF; //32767
    else if (zero_ones == 3'b010)
        return 16'hFFFF; //-1
    else if (zero_ones == 3'b100)
        return 16'h8000; //-32768
    else if (zero_ones == 3'b101)
        return 16'h0001; //-32768
    else
        return 16'($random);

endfunction : get_data

//------------------------
// Tester main
//------------------------

task execute();
	
//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------
	typedef enum bit {
	    TEST_PASSED,
	    TEST_FAILED
	} test_result_t;
	
	
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
	bit signed [15:0] data_in_A_buf;
	bit signed [15:0] data_in_B_buf;
	
	paritycheck_t parity_A_buf;
	paritycheck_t parity_B_buf;
	
	bfm.reset_fifo();
	
	repeat (15000) begin : tpgen_main_blk
	    data_in_A_buf      = get_data();
	    parity_A_buf = get_paritycheck();
        data_in_B_buf      = get_data();
        parity_B_buf = get_paritycheck();
	    
	    bfm.send_data(data_in_A_buf, parity_A_buf, data_in_B_buf, parity_B_buf);

    end : tpgen_main_blk
    $finish;
	
endtask

endclass : tpgen
