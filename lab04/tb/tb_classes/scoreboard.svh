class scoreboard;
	
	
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
    PARITY_OK             = 1'b0, //change names
    PARITY_ERR           = 1'b1
} paritycheck_t;


//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
protected virtual fifomult2024_bfm bfm;
test_result_t        test_result = TEST_PASSED;

local bit sb_valid;

protected typedef struct packed {
    bit signed [15:0] data_in_A;
    bit signed [15:0] data_in_B;
    bit parity_A;
    bit parity_B;
} data_packet_t;

protected typedef struct packed {
    bit  signed [31:0] data_out;
    bit data_in_parity_error;
    bit data_out_parity;
} data_expected_packet_t;
	
data_expected_packet_t data_exp_q;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
function new (virtual fifomult2024_bfm b);
	bfm = b;
endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function data_expected_packet_t get_expected(
    data_packet_t    data_packet
);
	data_expected_packet_t retval;
	`ifdef DEBUG
	$display("%0t DEBUG: get_excepted(%0d,%0d)", $time, data_packet.data_in_A, data_packet.data_in_B);
	`endif
	
	if (data_packet.parity_A == ^data_packet.data_in_A  && data_packet.parity_B == ^data_packet.data_in_B) begin
	    retval.data_out = data_packet.data_in_A * data_packet.data_in_B;
		retval.data_in_parity_error = 1'b0;
		retval.data_out_parity = ^retval.data_out;
	end
	else begin
	    retval.data_out = data_packet.data_in_A * data_packet.data_in_B;
		retval.data_in_parity_error = 1'b1;
		retval.data_out_parity = ^retval.data_out;
	end
	return retval;
endfunction : get_expected


//-------------------------------------------------------------------
// Scoreboard, part 1 command receiver and reference model function
//-------------------------------------------------------------------

    data_packet_t               sb_data_q   [$];
	data_packet_t				scoreboard_data;

	local task store_cmd();
		forever begin:scoreboard_fe_blk
			@(posedge bfm.clk);
			if(bfm.data_in_valid == 1 && sb_valid == 1)begin
		        scoreboard_data.data_in_B = bfm.data_in;
		        scoreboard_data.parity_B = bfm.data_in_parity;
	            sb_data_q.push_front(scoreboard_data);
		        sb_valid <= 1'b0;
	        end
	        else if(bfm.data_in_valid == 1 && sb_valid == 0)begin
		        scoreboard_data.data_in_A = bfm.data_in;
		        scoreboard_data.parity_A = bfm.data_in_parity;
		       
		    	sb_valid <= 1'b1;
	        end
	       	else if(bfm.data_in_valid == 0 && sb_valid == 1)begin
		    	sb_valid <= 1'b1;
	       	end
	       	else begin
		       	sb_valid <= 0;
	       	end
	       	
	       	if(!bfm.rst_n)begin
		       	sb_valid = 0;
	       		sb_data_q.delete();
	       	end
		end
	endtask
//    always @(posedge bfm.clk) begin:scoreboard_fe_blk //posedge to be sure that expected data value is already loaded
//	    
//        if(bfm.data_in_valid == 1 && sb_valid == 1)begin
//	        scoreboard_data.data_in_B = bfm.data_in;
//	        scoreboard_data.parity_B = bfm.data_in_parity;
//            sb_data_q.push_front(scoreboard_data);
//	        sb_valid <= 1'b0;
//        end
//        else if(bfm.data_in_valid == 1 && sb_valid == 0)begin
//	        scoreboard_data.data_in_A = bfm.data_in;
//	        scoreboard_data.parity_A = bfm.data_in_parity;
//	       
//	    	sb_valid <= 1'b1;
//        end
//       	else if(bfm.data_in_valid == 0 && sb_valid == 1)begin
//	    	sb_valid <= 1'b1;
//       	end
//       	else begin
//	       	sb_valid <= 0;
//       	end
//       	
//       	if(!bfm.rst_n)begin
//	       	sb_valid = 0;
//       		sb_data_q.delete();
//        end
//       	
//    end
    
//---------------------------------------------------------------
// Scoreboard, part 2 - data checker
//---------------------------------------------------------------

    
	local task process_data_from_dut();
		forever begin : scoreboard_be_blk
	        if(bfm.data_out_valid) begin:verify_result
	            data_packet_t dp;
	
	            dp = sb_data_q.pop_back();
	            data_exp_q = get_expected(dp);
	
	            CHK_RESULT: if({bfm.data_out, bfm.data_in_parity_error, bfm.data_out_parity} == data_exp_q) begin
	           `ifdef DEBUG
	                $display("%0t Test PASSED for data_in_A=%0d data_in_B=%0d", $time, dp.data_in_A, dp.data_in_B);
	           `endif
	            end
	            else begin
	                test_result <= TEST_FAILED;
	                $error("%0t Test FAILED for data_in_A=%0d data_in_B=%0d parity_A=%0b parity_B=%0b ||| received data: %d  expected data: %d. received data_in_parity_error_exp: %b  expected data_in_parity_error: %b.",
	                    $time, dp.data_in_A, dp.data_in_B, dp.parity_A, dp.parity_B, bfm.data_out, data_exp_q.data_out, bfm.data_in_parity_error, data_exp_q.data_in_parity_error);
	            end;

	        end
		end : scoreboard_be_blk
	endtask
    
    task execute();
	    fork
		    store_cmd();
		    process_data_from_dut();
	    join_none
    endtask
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
    
    
//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------
function void print_result();
	print_test_result(test_result);
endfunction
	
	
endclass : scoreboard
