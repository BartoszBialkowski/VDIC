class rectangle_c extends shape_c;

	function new(string n,coordinates_struct p[$]);
		super.new(n,p);
	endfunction : new

	function real get_area();
		coordinates_struct r_c1;
		coordinates_struct r_c2;
		coordinates_struct r_c3;
		coordinates_struct r_c4;
		coordinates_struct points_tmp[$];
		real area   = 0.0;
		real s1 = 0.0;
		real s2 = 0.0;

		points_tmp = points;
		r_c1 = points_tmp.pop_front();
		r_c2 = points_tmp.pop_front();
		r_c3 = points_tmp.pop_front();
		r_c4 = points_tmp.pop_front();

		s1 = get_distance(r_c1,r_c2);
		s2 = get_distance(r_c2,r_c3);
		area = s1 * s2;
		return area;
	endfunction : get_area

endclass : rectangle_c