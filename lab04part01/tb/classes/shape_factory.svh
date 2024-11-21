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


		static int ctr_local = 0;
		real d1 = 0.0;
		real d2 = 0.0;


		ctr_local = 0;

		foreach(p[i]) ctr_local++;

		d1 = ((p[0].x - p[2].x)**2 + (p[0].y - p[2].y)**2)**0.5;
		d2 = ((p[1].x - p[3].x)**2 + (p[1].y - p[3].y)**2)**0.5;

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
