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
virtual class base_tpgen extends uvm_component;

// The macro is not there as we never instantiate/use the base_tpgen
//    `uvm_component_utils(base_tpgen)

//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function bit get_paritycheck();
    pure virtual protected function shortint get_data();

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase
    
    local function bit random_reset();
	    bit[7:0] random;
	    random = 8'($random);
	    if(random == 8'h7F) begin
		    `ifdef DEBUG
    			$display("%0t DEBUG: reset_fifo", $time);
    		`endif
    		return 1'b0;
		end    
	    else begin
		    return 1'b1;
	    end
    endfunction: random_reset    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------

    task run_phase(uvm_phase phase);

        command_s command;

        phase.raise_objection(this);
        command.rst_n = 1'b0;
        command_port.put(command);
	     command.rst_n = 1'b1;

        repeat (10000) begin : random_loop
            command.data_in_A  = get_data();
            command.data_in_B  = get_data();
	        command.parity_A = get_paritycheck();
	        command.parity_B = get_paritycheck();
	        //command.rst_n= random_reset();
            command_port.put(command);
        end : random_loop
        #500;
        phase.drop_objection(this);
    endtask : run_phase

endclass : base_tpgen
