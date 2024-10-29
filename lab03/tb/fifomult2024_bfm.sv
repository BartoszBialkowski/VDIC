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


modport tlm (import reset_fifo);
    
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


endinterface : fifomult2024_bfm


