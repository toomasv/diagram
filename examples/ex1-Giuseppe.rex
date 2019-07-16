Red [Description: {Giuseppe's, anim, resize}]
context [
	arrow: proc: p2: p3: p4: none
	tick: 0
	view/flags dia [
		size 500x500
		diagram vertical border 1 resize beige "Example" [
			below space 40x40
			style arrow: connect arrow closed
			style proc: node rate 2 on-time [
				if face/extra/1 = tick [face/draw/fill-pen: face/extra/3]
				if face/extra/2 = tick [face/draw/fill-pen: white]
			]
			at 0x0 box rate 1 on-time [tick: tick % 5 + 1]
			proc ellipse "start" extra [1 5 green]
			arrow 
			p2: proc "    first^/operation" extra [2 5 green]
			arrow
			p3: proc "  second^/operation" extra [3 5 green]
			return pad 0x30
			arrow to top hint [horizontal 20 -200]
			p4: proc ellipse "end" extra [3 5 blue]
		]
	] 'resize
]