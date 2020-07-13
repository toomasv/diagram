Red []
context [
	line2: ln2: none
	set 'snakeline function [
		{Returns `shape` block of relative lines and arcs}
		lines 		"full line segments (wo considering knee arcs)"
		radius 		"radius of knee arcs"
		/vertical 	"starts with `vline`"
		/horizontal "starts with `hline` (default)"
		/extern line2 ln2
	][
		line1: none
		collect [
			forall lines [
				either 1 < length? lines [
					set [line1 line2] pick [
						['vline 'hline]
						['hline 'vline]
					] to-logic any [
						all [vertical odd? index? lines]
						all [not vertical even? index? lines]
					]
					ln1: lines/1 ln2: lines/2
					abs-ln1: absolute ln1
					abs-ln2: absolute ln2
					keep line1
					
					; Make room for arcs
					cf1: pick [1 2] head? lines
					keep ln1*: either all [cf1 * radius < abs-ln1 ln1 <> 0] [
						ln1 / abs-ln1 * (abs-ln1 - (cf1 * radius))
					][0]
					cf2: pick [1 2] 2 = length? lines
					ln2*: either all [cf2 * radius < abs-ln2 ln2 <> 0] [
						ln2 / abs-ln2 * (abs-ln2 - (cf2 * radius))
					][0]
					
					; Find arc's end-point
					ln1': either 0 = ln1 [1][ln1 / abs-ln1] ; Avoid dividing by 0
					ln2': either 0 = ln2 [1][ln2 / abs-ln2]
					either line1 = 'hline [
						a: as-pair ln1' ln2'
						r1: min radius max 0 abs-ln1 / cf1
						r2: min radius max 0 abs-ln2 / cf2
					][
						a: as-pair ln2' ln1'
						r2: min radius max 0 abs-ln1 / cf1
						r1: min radius max 0 abs-ln2 / cf2
					]
					keep ['arc] keep a * as-pair r1 r2

					keep r2*: radius + (radius - r2 * 5) 		; To avoid bumps in case of strighter lines
					keep r1*: radius + (radius - r1 * 5) 
					keep 0
					if any [
						all [line1 = 'hline a/1 = a/2]
						all [line1 = 'vline a/1 <> a/2]
					][keep 'sweep]
				][
					keep line2 keep ln2*						; last line
				]
			]
		]
	]
]