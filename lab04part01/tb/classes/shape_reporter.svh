class shape_reporter #(type T = shape_c);

	protected static T storage[$];
	static int i = 0;
	//-------------------------
	static function void shapes_storage(T l);

		storage.push_back(l);

	endfunction : shapes_storage

	//-------------------------
	static function void report_shapes();
		foreach (storage[i]) storage[i].print();
	endfunction : report_shapes

endclass : shape_reporter