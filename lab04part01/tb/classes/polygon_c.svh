class polygon_c extends shape_c;

	function new(string n, coordinates_struct p[$]);
		super.new(n, p);
	endfunction : new

	function real get_area();
		return 0.0;
	endfunction : get_area

endclass : polygon_c
