Red [Description: {Tables, wheel, drag}]
view dia [
	size 220x120
	style table: diagram border [corner: 0] 
	style cell: node box 50x20 0 init [spacing: 0x-1 axis: 'y]
	style plain-cell: node box 50x20 0 border [pen: off] font-color black init [spacing: 0x-1 axis: 'y]
	style arrow: connect knee 3 arrow closed 
	diagram drag wheel 200x100 gray [
		table 52x98 [
			origin 1x1
			t1k1: cell "key1"
			t1k2: cell "key2"
			cell "field1"
			cell "field2"
			cell "field3"
		] ;rate 0:0:2 on-time [unview]
		pad 30x30 table 52x98 [
			origin 1x1 
			t2k1: cell "key1"
			cell "key2"
			cell "field1"
			cell "field2"
			cell "field3"
		]
		pad 30x20 table 52x79 [
			origin 1x1 
			t3k1: plain-cell font [color: black style: 'bold] "primary"
			plain-cell "field1"
			plain-cell "field2"
			plain-cell "field3"
		]
		
		arrow from :t1k2 to -2x0 :t2k1 label end "con1"
		arrow from :t1k1 to -2x0 :t3k1 hint 115 label end "con2"
	]
]
