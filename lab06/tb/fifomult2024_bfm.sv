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
import fifomult2024_tb_pkg::*;
 
//------------------------------------------------------------------------------
// the interface
//------------------------------------------------------------------------------

interface fifomult2024_bfm;

//------------------------------------------------------------------------------
// dut connections
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


//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
 
command_monitor command_monitor_h;
result_monitor result_monitor_h;

//------------------------------------------------------------------------------
// reset_fifo
//------------------------------------------------------------------------------

task reset_fifo();
    `ifdef DEBUG
    $display("%0t DEBUG: reset_fifo", $time);
    `endif

    data_in_valid   = 1'b0;
    data_in_parity   = 1'b0;
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
endtask : reset_fifo

//------------------------------------------------------------------------------
// get_parity
//------------------------------------------------------------------------------

task get_parity(
        input shortint   data_in,
        input bit valid,
        output bit       parity
    );
    parity = ^data_in;

    if (valid == 1'b1)
        parity = !parity;

endtask : get_parity

//------------------------------------------------------------------------------
// send transaction to DUT
//------------------------------------------------------------------------------

task send_data(input command_s cmd);
	
	if (cmd.rst_n == 0) begin
		reset_fifo();
	end 

   	@(negedge clk);
	if(busy_out) begin
	    @(negedge busy_out);
	    @(negedge clk);
	end    
	 
	    data_in = cmd.data_in_A;
	    get_parity(data_in, cmd.parity_A ,data_in_parity);
	    data_in_valid = 1'b1;

      	@(negedge clk)begin;
        	data_in_valid = 1'b0;
	    end  	
	    
	    if(busy_out) begin
	        @(negedge busy_out);
	        @(negedge clk);    
		end    
	
	    data_in = cmd.data_in_B;           
	            get_parity(data_in, cmd.parity_B, data_in_parity);
	            data_in_valid = 1'b1;

        @(negedge clk)begin
        	data_in_valid = 1'b0;
	    end    

endtask : send_data

//------------------------------------------------------------------------------
// convert binary parity code to enum
//------------------------------------------------------------------------------

//function paritycheck_t parity2enum();
//    paritycheck_t parity;
//    if( ! $cast(parity,op) )
//        $fatal(1, "Illegal operation on parity bus");
//    return parity;
//endfunction : parity2enum

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------

bit data_cntr = 0;

always @(posedge clk) begin : op_monitor
    //static bit in_command = 0;
    command_s command;
    if (data_in_valid) begin
        if(data_cntr == 0) begin
            command.data_in_B  = data_in;
            command.parity_B  = data_in_parity;
	        data_cntr = 1'b1;
	    end    
        else begin
            command.data_in_A  = data_in;
            command.parity_A  = data_in_parity;
            command_monitor_h.write_to_monitor(command);
	        data_cntr = 1'b0;
        end        
    end
   // else // start low
       // in_command = 0;
end : op_monitor

always @(negedge rst_n) begin : rst_monitor
    command_s command;
	reset_fifo();
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor



//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------

initial begin : result_monitor_thread
	data_expected_packet_t results;
    forever begin
        @(posedge clk);
        if (data_out_valid) begin
	        results.data_out = data_out;
	        results.data_out_parity = data_out_parity;
	        results.data_in_parity_error = data_in_parity_error;
            result_monitor_h.write_to_monitor(results);
	    end    
    end
end : result_monitor_thread


//------------------------------------------------------------------------------
// clock generator  
//------------------------------------------------------------------------------
initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end
end

endinterface : fifomult2024_bfm


