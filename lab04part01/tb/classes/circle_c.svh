class circle_c extends shape_c;

	function new(string n, coordinates_struct p[$]);
		super.new(n, p);
	endfunction : new

	function real get_radius();
		real radius = 0.0;

		radius = get_distance(points[0], points[1]);

		return radius;
	endfunction : get_radius

	virtual function void print();

		$display("----------------------------------------------------------------------------------------");
		$display("This is: %s",name);

		foreach (points[i])
			$display("(%0.2f %0.2f)",points[i].x, points[i].y);

		$display("radius: %0.2f",get_radius());

		$display("Area: %0.2f",get_area());

	endfunction : print

	function real get_area();
		real area   = 0.0;
		real radius   = 0.0;

		radius = get_radius();
		area = 3.1415 * radius**2;

		return area;
	endfunction : get_area

endclass : circle_c
