Red [Description: {Connect with normal faces}]
context [
	fld: list: chk: none
	img: draw/transparent 31x31 [fill-pen red translate 15x15 polygon 0x-15 5x-5 15x0 5x5 0x15 -5x5 -15x0 -5x-5]
	view dia [
		space 50x20
		fld: field focus on-enter [append list/data face/text]
		connect	arrow label start "<Enter>" list: text-list data []
		connect arrow label [mid right] "<Press>" button "Check" [
			chk/data: (last list/data) = chk/text
		] return
		connect arrow hint vertical to right :chk
		;connect from point 40x50 to top hint [vertical 30] 
		chk: check "Amazing?"
		;connect from point 40x50 hint [vertical 30] pad -45x-20 image img
	]
]