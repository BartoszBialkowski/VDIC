class triangle_c extends shape_c;

	function new(string n,coordinates_struct p[$]);
		super.new(n,p);
	endfunction : new

	function real get_area();
		coordinates_struct t_c1;
		coordinates_struct t_c2;
		coordinates_struct t_c3;
		coordinates_struct points_tmp[$];
		real area   = 0.0;

		points_tmp = points;
		t_c1 = points_tmp.pop_front();
		t_c2 = points_tmp.pop_front();
		t_c3 = points_tmp.pop_front();

		area = 0.5 * (((t_c2.x - t_c1.x)*(t_c3.y - t_c1.y) - (t_c2.y - t_c1.y)*(t_c3.x - t_c1.x))**2)**0.5;

		return area;

	endfunction : get_area

endclass : triangle_c