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
 //import fifomult2024_tb_pkg::*;
 
virtual class base_tpgen extends uvm_component;

// The macro is not there as we never instantiate/use the base_tpgen
//    `uvm_component_utils(base_tpgen)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual fifomult2024_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function paritycheck_t get_paritycheck();
    pure virtual protected function shortint get_data();
    pure virtual protected task reset_probability();

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual fifomult2024_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------


    task run_phase(uvm_phase phase);
	
		bit signed [15:0] 	data_in_A_local;
		bit signed [15:0] 	data_in_B_local;
		paritycheck_t 		parity_A_local;
		paritycheck_t 		parity_B_local;	
	    
	    phase.raise_objection(this);
	    
	    bfm.reset_fifo();
	
	    repeat (15000) begin : tpgen_main_blk
		    
		    reset_probability();
	   	 
			data_in_A_local      = get_data();
			parity_A_local 		 = get_paritycheck();
		    data_in_B_local      = get_data();
			parity_B_local 		 = get_paritycheck();
		    
		    bfm.send_data(data_in_A_local, data_in_B_local , parity_A_local ,parity_B_local);
	    end : tpgen_main_blk
	    //      #500;

        phase.drop_objection(this);

    endtask : run_phase



endclass : base_tpgen
