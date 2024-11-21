typedef struct {
	real x;
	real y;
} coordinates_struct;


virtual class shape_c;

	protected string name;
	protected coordinates_struct points[$];
	
	function new(string n, coordinates_struct pq[$]);
		
		name   = n;
		points = pq;
		
	endfunction : new

	pure virtual function real get_area();

	virtual function void print();
		
		$display("---------------------------------------------------------------------------------");
		$display("This is: %s",name);

		foreach (points[i]) begin
			$display("(%0.2f %0.2f)",points[i].x, points[i].y);
		end

		if (get_area() != 0.0) begin
			$display("Area: %0.2f", get_area());
		end
		else begin
			$display("Area: can not be calculated for generic polygon");
		end
		
	endfunction : print

	function real get_distance(coordinates_struct point1, coordinates_struct point2);
		
		real distance = ((point1.x - point2.x)**2 + (point1.y - point2.y)**2)**0.5;
		return distance;	
		
	endfunction  : get_distance
	
endclass : shape_c
