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
class corners_tpgen extends random_tpgen;
    `uvm_component_utils (corners_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//---------------------------------
// Generating random data for DUT input
	protected function shortint get_data();
	
	    bit [2:0] zero_ones;
	
	    zero_ones = 3'($random);
		
	    if (zero_ones == 3'b000)
	        return 16'sh0000;
	    else if (zero_ones == 3'b001) 
	        return 16'sh0001;
	    else if (zero_ones == 3'b010 || zero_ones == 3'b011)
	        return 16'sh7FFF;
	    else if (zero_ones == 3'b100 || zero_ones == 3'b101)
	        return 16'shFFFF;
	    else if (zero_ones == 3'b111)
	        return 16'sh8000;
	    else
	        return 16'sh0000;
	endfunction : get_data


endclass : corners_tpgen






