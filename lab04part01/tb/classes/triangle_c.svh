class triangle_c extends polygon_c;

	function new(string n,coordinates_struct p[$]);
		super.new(n,p);
	endfunction : new

	function real get_area();
		real area   = 0.0;

		area = 0.5 * (((points[1].x - points[0].x)*(points[2].y - points[0].y) - (points[1].y - points[0].y)*(points[2].x - points[0].x))**2)**0.5;

		return area;

	endfunction : get_area

endclass : triangle_c