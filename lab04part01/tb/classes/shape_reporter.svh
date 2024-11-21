class shape_reporter #(type T = shape_c);

	protected static T shape_storage[$];
	//-------------------------
	static function void shapes_storage(T l);

		shape_storage.push_back(l);

	endfunction : shapes_storage

	//-------------------------
	static function void report_shapes();
		foreach (shape_storage[i]) shape_storage[i].print();
	endfunction : report_shapes

endclass : shape_reporter