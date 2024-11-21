class rectangle_c extends polygon_c;

	function new(string n,coordinates_struct p[$]);
		super.new(n,p);
	endfunction : new

	function real get_area();
		real area   = 0.0;
		real side1 = 0.0;
		real side2 = 0.0;

		side1 = get_distance(points[0],points[1]);
		side2 = get_distance(points[2],points[3]);
		area = side1 * side2;
		
		return area;
	endfunction : get_area

endclass : rectangle_c