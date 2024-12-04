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
class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//---------------------------------
// Generating random parity for DUT
	
protected function bit get_paritycheck();
    bit [1:0] parity_result;
    parity_result = 2'($random);
    case (parity_result)
        2'b00 : 	return 1'b0;
        2'b01 : 	return 1'b0;
        2'b10 : 	return 1'b1;
        2'b11 : 	return 1'b0;
        default : 	return 1'b0;
    endcase // case (parity_result)
endfunction : get_paritycheck


//---------------------------------
// Generating random data for DUT input
	protected function shortint get_data();
        return 16'($random);   
	endfunction : get_data

endclass : random_tpgen






