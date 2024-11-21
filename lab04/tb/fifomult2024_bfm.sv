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
interface fifomult2024_bfm;
import fifomult2024_tb_pkg::*;

bit             [15:0] data_in;
bit                    clk;
bit                    rst_n;
bit                    data_in_parity;
bit                    data_in_valid;
wire                   busy_out;
wire         	[31:0] data_out;
wire                   data_out_parity;
wire                   data_out_valid;
wire                   data_in_parity_error;

//test_result_t        test_result = TEST_PASSED;

modport tlm (import reset_fifo);
	
    
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
// reset fifo
//------------------------------------------------------------------------------

task reset_fifo();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_fifo", $time);
    `endif
    data_in_valid   = 1'b0;
    data_in_parity   = 1'b0;
    rst_n = 1'b1;
    @(negedge clk);
    rst_n = 1'b0;
	//sb_data_q.delete();
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_fifo


//---------------------------------
//Parity check for input data

task get_parity(
        input signed [15:0]  data_in,
        input paritycheck_t valid
	);
	bit        parity;
    parity =^ data_in;

    if (valid == PARITY_ERR)
        parity = !parity;
endtask : get_parity


task send_data(input bit signed [15:0] data_in_A, input paritycheck_t parity_A, input bit signed [15:0] data_in_B, input paritycheck_t parity_B);
		@(negedge clk);         
        if(busy_out) begin
	        @(negedge busy_out);
	        @(negedge clk); 
        end
        
        data_in        = data_in_A;
        get_parity(data_in, parity_A);
        data_in_valid  = 1'b1;
        
        @(negedge clk);
        data_in_valid = 1'b0;
        
        if(busy_out) begin
	        @(negedge busy_out);
	        @(negedge clk); 
        end
        
        data_in        = data_in_B;
        get_parity(data_in, parity_B);
        data_in_valid  = 1'b1;

        @(negedge clk);
        data_in_valid = 1'b0;
endtask : send_data

endinterface : fifomult2024_bfm


