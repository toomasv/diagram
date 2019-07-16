Red [Description: {Grid, arrows, labels, drag}]
context [
	;if not value? 'img1 [
		img1: draw/transparent 21x21 [
			fill-pen red 
			translate 10x10 
			polygon 0x-10 2x-5 10x-10 5x-2 10x0 5x2 10x10 2x5 0x10 -2x5 -10x10 -5x2 -10x0 -5x-2 -10x-10 -2x-5
		]
	;]
	cell: con: arr: linearr: none
	view dia [
		size 220x220 backdrop gray
		style cell: node box 30x20 3
		style con: connect knee 5
		style arr: connect knee 5 arrow
		style linearr: connect line arrow closed
		diagram 200x200 drag [
			origin 50x50 space 50x50 
			r1c1: cell r1c2: cell r1c3: cell r1c4: cell return
			r2c1: cell r2c2: cell r2c3: cell r2c4: cell return
			r3c1: cell r3c2: cell r3c3: cell r3c4: cell return
			r4c1: cell r4c2: cell pad 5x0 r4c3: image img1 r4c4: cell return
			r5c1: cell r5c2: cell r5c3: cell r5c4: cell 
			
			con from :r1c1 to :r3c2 label start "con1"
			con from :r3c2 to top :r1c4 hint [25 -175] label [leg 3] "con2"
			arr from :r1c4 to top :r2c2 hint [vertical 25] label [mid right] "arrow1"
			con from left :r2c3 to top :r4c1 hint [-12 90] label [end right 2x0] "con3"
			arr from left :r4c1 to :r2c1 hint -25 label [mid top right 2x15] "arrow2"
			connect 'line -15x0 _ -60x0 _ -15x0 arrow closed from left :r4c3 to right :r3c1 label mid "angular"
			linearr from bottom :r4c3 to top :r5c3
			connect qcurve 260x200 from top-right :r4c3 to bottom-right -1x-1 :r2c3
			connect 'spline 30x-10 -10x-50 arrow [10 8x2 closed green] from :r4c3 to :r3c4 pen red label [mid 27x-20 -5 align] "'spline"
			connect spline 270x280 260x330 arrow [closed -10 8x2] from :r4c3 to :r5c4 label [mid 5x15 7 align] "spline"
		]
	]
]