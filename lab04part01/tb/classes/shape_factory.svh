parameter CIRCLE    = 2;
parameter TRIANGLE  = 3;
parameter RECTANGLE = 4;
parameter POLYGON   = 5;

class shape_factory;
	static function shape_c make_shape(coordinates_struct p[$]);
		circle_c circle_o;
		triangle_c triangle_o;
		rectangle_c rectangle_o;
		polygon_c polygon_o;

		coordinates_struct points_q[$];
		coordinates_struct points_q_tmp[$];

		static int ctr_local = 0;
		coordinates_struct p1;
		coordinates_struct p2;
		coordinates_struct p3;
		coordinates_struct p4;
		real d1 = 0.0;
		real d2 = 0.0;

		points_q_tmp = p;

		ctr_local = 0;

		foreach(p[i]) ctr_local++;

		p1 = points_q_tmp.pop_front();
		p2 = points_q_tmp.pop_front();
		p3 = points_q_tmp.pop_front();
		p4 = points_q_tmp.pop_front();

		d1 = ((p1.x - p3.x)**2 + (p1.y - p3.y)**2)**0.5;
		d2 = ((p2.x - p4.x)**2 + (p2.y - p4.y)**2)**0.5;

		//  check if rectangle
		if (ctr_local == 4 && d1 != d2) ctr_local = 5;

		case (ctr_local)
			CIRCLE:
			begin
				circle_o = new("circle",p);
				return circle_o;
			end
			TRIANGLE:
			begin
				triangle_o = new("triangle",p);
				return triangle_o;
			end
			RECTANGLE:
			begin
				rectangle_o = new("rectangle",p);
				return rectangle_o;
			end
			default :
			begin
				polygon_o = new("polygon",p);
				return polygon_o;
			end
		endcase

	endfunction : make_shape
endclass : shape_factory