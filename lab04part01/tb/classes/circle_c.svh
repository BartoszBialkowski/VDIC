class circle_c extends shape_c;

	function new(string n, coordinates_struct p[$]);
		super.new(n, p);
	endfunction : new

	function real get_radius();

		coordinates_struct points_tmp[$];
		coordinates_struct c1;
		coordinates_struct c2;
		real radius = 0.0;

		points_tmp = points;
		c1 = points_tmp.pop_front();
		c2 = points_tmp.pop_front();
		radius = get_distance(c1, c2);

		return radius;
	endfunction : get_radius

	virtual function void print();

		$display("----------------------------------------------------------------------------------------");
		$display("This is: %s",name);

		foreach (points[i])
			$display("(%0.2f %0.2f)",points[i].x, points[i].y);

		$display("radius: %0.2f",get_radius());

		$display("Area is: %0.2f",get_area());

	endfunction : print

	function real get_area();

		coordinates_struct cc1;
		coordinates_struct cc2;
		coordinates_struct points_tmp[$];
		real area   = 0.0;
		real radius   = 0.0;

		points_tmp = points;
		cc1 = points_tmp.pop_front();
		cc2 = points_tmp.pop_front();

		radius = get_radius();
		area = 3.1415 * radius**2;

		return area;
	endfunction : get_area

endclass : circle_c
