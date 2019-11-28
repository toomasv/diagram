Red [
	Title: 			{Diagram dialect}
	Description: 	{Extends VID to allow easy diagram description}
	Author: 		{Toomas Vooglaid}
	Date:			31-May-2019
	Last:			10-Jul-2019
	Version:		#0.6
	Licence: 		"MIT"
]
;probe system/options
;probe system/standard
;probe system/script
#include %../utils/snakeline.red

diagram-ctx: context [
	test: make face! [type: 'area size: 100x100]
	;pos-text: func [text][
	;	sz: size-text/with
	;]
	;node-cnt: 0
	default-size: 80x50
	default-corner: 10
	default-knee: 10
	default-arrow: 10x5
	default-endsize: 15
	line-width: pen: none
	spacing*: 10x10
	add-space: 0
	points: [center top bottom left right top-left top-right bottom-left bottom-right]
	;space: none
	lim: func [:dim face][face/offset/:dim + face/size/:dim]
	default-attract: .9;.55
	default-repulse: .37
	default-coef: 10000
	default-radius: 30			; for force
	
	reconnect: function [node][
		if c: node/options/to [
			foreach d c [
				unless d/options/shape/1 = 'blank [
					l: find/tail d/draw 'line 
					l/1: node/offset + (node/size / 2)
				]
			]
		]
		if c: node/options/from [
			foreach d c [
				unless d/options/shape/1 = 'blank [
					l: find/tail d/draw 'line 
					l/2: node/offset + (node/size / 2)
				]
			]
		]
	]
	randomize: function [nodes][
		system/view/auto-sync?: off
		foreach node nodes/pane [
			if all [
				node/options
				none? node/options/at-offset
			][
				node/offset: as-pair first j: random nodes/size second j
				reconnect node
			]
		]
		show nodes
		system/view/auto-sync?: on
	]
	calc-forces: function [face][
		system/view/auto-sync?: off
		foreach r face/pane [
			if all [
				r/options
				none? r/options/at-offset
			][
				f: 0x0
				foreach e face/pane [
					if all [
						e/options
						none? e/options/at-offset
						not same? e r
					][
						;conn: none
						dif: (e/offset + (e/size / 2)) - (r/offset + (r/size / 2))
						if dif = 0x0 [dif: 0x1]
						ang: arctangent2 dif/y dif/x
						dis: sqrt (dif/x ** 2) + (dif/y ** 2) 
						either any [
							all [
								r/options/to-nodes
								node: find r/options/to-nodes e
								conn: r/options/to/(index? node)
								
							]
							all [
								r/options/from-nodes
								node: find r/options/from-nodes e
								conn: r/options/from/(index? node)
								
							]
						][
							radius: any [all [force: conn/options/force force/radius] default-radius]
							attract: any [all [force: conn/options/force force/attract] default-attract]
							if 0.0 = d: dis - radius [d: .01]
							s: log-2 da: absolute d
							s: d / da * s * attract
						][
							repulse: any [all [force: conn/options/force force/repulse] default-repulse]
							coef: any [all [force: conn/options/force force/coef] default-coef]
							d: coef / dis
							s: log-10 da: absolute d 
							s: repulse * negate d / da * s
						]
						f: f + as-pair s * cosine ang s * sine ang
					]
				]
				if all [
					find r/options 'to 
					r/offset >= (mn: r/parent/size / 3) 
					r/offset <= (mn * 2 - r/size)
				] [f: min 1x1 max -1x-1 f]
				r/offset: r/offset + f
				reconnect r
			]
		]
		show face
		system/view/auto-sync?: on
	]
	
	extend system/view/VID/styles [
		diagram: [
			template: [
				type: 'panel
				draw: copy []
				actors: [
					;on-create: func [face][probe "cr-dia1" ;probe face/options
					;	mx: face/size probe face/options
					;	node-cnt: 0			; Restart node counting for current diagram
					;]
					pos: ofs: brd: tri: none
					on-created: func [face event /local line-width pen corner pane mx mv][
						;probe "cr-dia2"
						; Move connect-lines behind nodes 
						; Currently disabled, may be conditional enabling? TBD
						if no [
							foreach-face/with face [
								pane: find face/parent/pane face
								move pane head pane
							][
								any [
									face/options/style = 'connect 
									face/options/parent-style = 'connect
								]
							]
						]
		
						; Make caption
						;if face/text [
						;	insert find face/parent/pane face make face! [
						;		type: 'text 
						;		color: face/color - 16
						;		text: copy face/text 
						;		offset: face/offset
						;		size: as-pair face/size/x 30 
						;		font: either face/font [copy face/font][make font! [style: 'italic size: 14]]
						;		para: either face/para [copy face/para][make para! [align: 'center]]
						;	]
						;	face/offset/y: face/offset/y + 30
						;	face/text: face/para: none
						;	face/parent/size/y: face/parent/size/y + 30
						;]
						;if face/text [
							;fnt: make font! [style: 'bold size: 9] view [size 300x300 below panel with [draw: append append compose [font fnt box 0x17] size - 1x18 [10 text 0x0 "diagram"] size: size - 0x17] [origin 10x27 box 80x50 draw [fill-pen gold box 0x0 79x49 5 text 12x15 "Some text"] base red return base blue] base]
						;]
						
						;case/all [
						; Adjust size
						if not all [face/extra face/extra/size not face/extra/default not any [
							face/options/drag 
							face/options/wheel 
							face/options/navigate
							;face/options/zoom
						]][
							mx: face/size 
							mv: false
							;ofs: 0x0
							
							foreach elem face/pane [
								either any [
									elem/options/style = 'connect
									elem/options/parent-style = 'connect
								][
									parse elem/draw [some [
										pair! s: (mx: max mx elem/offset + s/-1) 
									| 	'shape into [any [
											'move set shp pair! (if mv: not mv [mx: max mx shp]) 
										| 	'hline set hl integer! (mx: max mx (shp: shp + as-pair hl 0)) 
										| 	'vline set vl integer! (mx: max mx (shp: shp + as-pair 0 vl)) 
										|	'arc set ac pair! (mx: max mx shp: shp + ac)
										;|	'line some [s: pair! (mx: mx)]
										| 	skip
										]] 
									| 	skip
									]]
								][
									mx: max mx elem/offset + elem/size
								]
							]
							
							foreach elem face/pane [
								if any [
									elem/options/style = 'connect
									elem/options/parent-style = 'connect
								][
									elem/size: mx + 20
								]
							]
							either face/extra [
								face/size/x: max mx/x case [w: face/extra/size [w/x] w: face/extra/width [w]] 
								face/size/y: max mx/y case [w: face/extra/size [w/y] w: face/extra/height [w]] 
							][
								face/size: mx
							]
							if all [face/options add-space: face/options/add][
								face/size: face/size + add-space
							]
							
							either any [
								face/options/drag 
								face/options/wheel 
								face/options/navigate
								;face/options/zoom
							][
								found: find face/parent/pane face
								;ofs: face/offset
								insert next found layout/only [panel []]
								panel: select found/2 'pane
								move found panel
								found/1/offset: face/offset
								found/1/size: case [
									s: face/extra/size [s]
									w: face/extra/width [as-pair w mx/y ]
									h: face/extra/height [as-pair mx/x h]
									true [mx]
								]
								face/offset: 0x0
								;found/1/pane/1/offset: 0x0
								
								;if face/options/zoom [
								;	lay*: layout/tight compose [size (face/size)]
								;;	move/part pane: face/pane lay*/pane length? pane
								;	append lay*/pane copy/deep face/pane
									;lay/visible? no
								;	view/tight/no-wait lay* ;/flags 'no-border 
								;	show lay*;face/parent
								;	im: to-image lay*
									;unview/only lay
								;	append face/draw: [image im]
								;	clear face/pane
								;]
							][
								if all [face/extra width: face/extra/width] [
									face/size/x: width
									
								]
								if all [face/extra height: face/extra/height] [
									face/size/y: height
								]
							]
						]
						
						; Draw border
						if border: face/options/border [
							switch type?/word border [
								integer! [line-width: border]
								word! tuple! issue! [pen: border]
								block! [reduce bind border :on-created]
							]
							if issue? pen [pen: to-tuple pen]
							face/draw: compose [fill-pen glass pen black line-width 1 brd: box 0x0 (face/size - 1) 10]
							case/all [
								line-width [face/draw/line-width: line-width]
								pen [face/draw/pen: pen]
								corner [change back tail face/draw corner]
								face/color [
									face/draw/fill-pen: face/color face/color: any [face/parent/color snow]
								]
							]
						]

						; Enable resizing
						if face/options/resize [
							insert face/draw compose [
								fill-pen 0.0.0.254 pen gray tri: triangle 
								(as-pair face/size/x - 1 face/size/y - 10) 
								(face/size - 1) 
								(as-pair face/size/x - 10 face/size/y - 1)
							]
							;probe face/draw
						]
						
						;]
						;probe face/options
						if face/options/force [diagram-ctx/randomize face]
						show face/parent
					]
					;on-time: function [face event][calc-forces face]
					on-drag: function [face event][]
					on-wheel: function [face event][]
					on-down: function [face event][]
					on-over: function [face event /local df s][]
					on-up: function [face event][]
					on-key-down: function [face event][]
					on-time: function [face event][]
				]
			]
			init: [;probe "dia1"
				if face/options/style <> 'diagram [			; For easy finding
					append face/options [parent-style: diagram]
				] 
				if all [face/extra face/extra/size not any [
					face/options/drag 
					face/options/wheel 
					face/options/navigate
					;face/options/zoom
				]][
					face/size: face/extra/size			; Hard size, no heuristics will be applied
				]
				if opts*: face/options [
					case/all [
						opts*/drag [
							append face/options [drag-on: 'down]
							append clear body-of :face/actors/on-drag bind copy [
								face/offset/x: min 0 max face/parent/size/x - face/size/x face/offset/x 
								face/offset/y: min 0 max face/parent/size/y - face/size/y face/offset/y
								show face 'done
							] :face/actors/on-drag
							append clear body-of :face/actors/on-down [system/view/auto-sync?: off] 
							append clear body-of :face/actors/on-up [system/view/auto-sync?: on]
						]
						opts*/wheel [
							append body-of :face/actors/on-wheel bind copy/deep [
								case [
									event/ctrl? [
										face/offset/x: min 0 max 
											face/parent/size/x - face/size/x 
											face/offset/x + (10 * to-integer event/picked)
									]
									event/shift? []
									true [
										face/offset/y: min 0 max 
											face/parent/size/y - face/size/y 
											face/offset/y + (10 * to-integer event/picked)
									]
								]
								show face 'end
							] :face/actors/on-wheel
						]
						opts*/navigate [
							append body-of :face/actors/on-key-down bind [
								step: 0x0
								mn: face/parent/size - face/size
								fo: face/offset
								switch event/key [
									up [step/y: min 0 - fo/y 10]
									down [step/y: max mn/y - fo/y -10]
									left [step/x: min 0 - fo/x 10]
									right [step/x: max mn/x - fo/x -10]
									page-up [step/y: min 0 - fo/y face/parent/size/y]
									page-down [step/y: max mn/y - fo/y 0 - face/parent/size/y]
									home [step: 0x0 - fo]
									end [step: mn - fo]
								]
								face/offset: face/offset + step
							] :face/actors/on-key-down
							set-focus face
						]
						;if all [face/options face/options/zoom][
						;	face/draw: [scale 1 1]
						;	append body-of :face/actors/on-wheel bind [
						;		if event/shift? [
						;			face/draw/2: face/draw/3: face/draw/2 + (event/picked * .05)
						;		]
						;	] :face/actors/on-wheel
						;]
						opts*/resize [
							either block? flags: face/flags [
								append flags 'all-over
							][
								face/flags: either flags [
									append to-block flags 'all-over
								]['all-over]
							]
							append body-of :face/actors/on-down bind bind [
								system/view/auto-sync?: off 
								ofs: event/offset
								
							] face/actors :face/actors/on-down
							append body-of :face/actors/on-over bind bind [
								if event/down? [
									df: event/offset - ofs
									face/size: face/size + df
									if brd [brd/3: face/size - 1]
									tri/2: face/size - 1x10
									tri/3: face/size - 1
									tri/4: face/size - 10x1
									
									pane: face/pane 
									max-y: 0
									max-x: 0 
									cur-x: 10
									cur-y: 10
									
									forall pane [
										if all [2 < length? pane not find pane/1/options 'connect][
											max-y: max max-y lim y pane/1
											max-x: max max-x lim x pane/1
											either face/options/direction = 'vertical [
												pane/3/offset: either face/size/y - pane/3/size/y - spacing*/y < lim y pane/1 [
													max-y: 0
													as-pair cur-x: max-x + spacing*/x spacing*/y
												][
													as-pair cur-x max-y + spacing*/y
												]
											][
												pane/3/offset: either face/size/x - pane/3/size/x - spacing*/x < lim x pane/1 [
													max-x: 0
													as-pair spacing*/x cur-y: max-y + spacing*/x
												][
													as-pair max-x + spacing*/x cur-y 
												]
											]
										]
									]
									
									ofs: event/offset
									show face
								]
							] face/actors :face/actors/on-over
							;probe length? face/pane
							foreach fc face/pane [
								if find fc/options 'connect [put fc/options 'bound true]
							]
						]
						;block? anim: opts*/animate [
						;	probe :face/actors/on-down
							;anim*: copy []
							;if block? on-time: anim/tick [
							;	append anim* compose/only [on-time (tick)]
							;]
							;if rate: anim/rate [
								
							;]
						;]
						opts*/force [
							append body-of :face/actors/on-time bind copy/deep [
								diagram-ctx/calc-forces face
							] :face/actors/on-time
						]
					]
				]
				
				;probe reduce bind [direction current global? below? max-sz opts spec] :layout
				;probe face/text
				;probe face/options
				;probe "dia2"
			]
		]
		node: [
			template: [
				type: 'base
				color: none
				size: default-size
				menu: ["do" do "front" front "stop" stop]
				actors: [
					draw*: none
					text-pos: function [face][
						sz: size-text face
						;print [sz + 3 face/size sz + 3 > face/size]
						;def: either all [
						;	shape: face/options/shape 
						;	shape/1 = 'default 
						;	size: find shape pair!
						;][size/1][default-size]
						;face/size: min def max def sz + 3
						pos: (face/size / 2) - (sz / 2) 
						change skip tail face/draw -2 reduce [pos face/text]
					]
					;on-create: func [face][probe "cr-node1"
					;	node-cnt: node-cnt + 1			; Enumerate nodes for easy referencing
					;	set to-word rejoin ["node" node-cnt] face
					;]
					on-created: function [face event][;probe "cr-node2"
						case [
							rt: face/options/rt [
								pos: face/offset + 3
								clr: any [face/draw/fill-pen white]
								sz: face/size - 4
								append face/parent/pane layout/only compose/only [
									at (pos) rich-text (clr) (sz) data (rt)
								]
							]
							face/text [
								face/actors/text-pos face			; Transfer text
							]
						]
					]
					on-menu: func [face event][						; Set manually?
						switch event/picked [
							do [do face/text] 
							front [move pane: find face/parent/pane face tail pane]
							stop [probe face/parent/rate: none]
						]
					] 	; Experimental, just a thought for flowchart
					on-drag: func [face event][reconnect face]		; Set manually?
					;on-down: func [face event][] 					; Waiting for links ; NB! Should be set manually
				]
			]
			init: [ ;probe "node1"
				spacing*: spacing
				unless face/options [face/options: make block! 10]
				if face/options/style <> 'node [					; For easy finding
					append face/options copy [parent-style: node]
				]
				
				draw*: compose [
					fill-pen white pen black line-width 1 
					box 0x0 (face/size - 1) (default-corner) text (face/size / 2) ""
				]

				
				; Transfer some attributes to draw
				case/all [
					face/color [change find/tail draw* 'fill-pen face/color face/color: none]
					face/font [insert find draw* 'text reduce ['font face/font]]
				]
				
				; Adjust shape
				either all [
					shp: face/options/shape 
					not empty? sh: intersect shp [box ellipse diamond]
				][
					shape: at draw* 7
					remove/part shape switch shape/1 [
						box [4] ellipse [3] diamond [5]
					]
					case [
						found: find/tail shp 'box [
							shape: insert shape [box 0x0]
							if pair? found/1 [
								either shp/1 = 'default [
									sz: 3 + size-text face
									face/size/x: max sz/x found/1/x
									face/size/y: max sz/y found/1/y
								][face/size: found/1]
							]
							shape: insert shape face/size - 1
							insert shape either found: find/part found integer! 2 [found/1][default-corner]
						]
						found: find/tail shp 'ellipse [
							shape: insert shape [ellipse 0x0]
							if pair? found/1 [face/size: found/1]
							insert shape face/size - 1
						]
						found: find/tail shp 'diamond [
							if pair? found/1 [
								face/size: found/1
							]
							shape: insert shape reduce [
								'polygon
								as-pair face/size/x / 2 0
								as-pair face/size/x - 1 face/size/y / 2
								as-pair face/size/x / 2 face/size/y - 1
								as-pair 0 face/size/y / 2
							]
						]
					]
				][
					change find/tail draw* [box 0x0] face/size - 1
				]
				
				; Format border
				line-width: pen: none
				if border: face/options/border [
					switch type?/word border [
						integer! [line-width: border]
						lit-word! word! tuple! [pen: border]
						block! [line-width: border/line-width pen: border/pen]
					]
					if line-width [
						face/size: face/size + line-width 
						draw*/line-width: line-width
						if find [box ellipse] draw*/7 [draw*/8: to-pair line-width / 2]
					]
					if pen [draw*/pen: pen]
				]
				
				; Format link
				if link: face/options/link [
					either find draw* 'font [
						either style: draw*/font/style [
							if word? style [style: to-block style]
							draw*/font/style: union style [underline]
						][
							draw*/font/style: [underline]
						]
					][
						insert find draw* 'text reduce [
							'font make font! [
								style: 'underline size: system/view/fonts/size color: blue
							]
						]
					]
					;insert body-of :face/actors/on-down compose [browse (link)] ;define manually
					either face/options [
						append face/options [cursor: 'hand]
					][
						face/options: [cursor: 'hand]
					]
				]
				face/draw: draw*
				;probe "node2"
			]
		]
		connect: [
			template: [
				type: 'base
				color: transparent
				actors: [
					start-pos: end-pos: distance: shape: draw: none
					count-legs: function [face][
						cnt: 0
						switch shape/1 [
							snake [
								parse draw/shape [
									some [['hline | 'vline] (cnt: cnt + 1) | skip]
								]
								cnt
							]
							line [
								parse find/tail draw 'line [
									some [pair! (cnt: cnt + 1)]
								]
								cnt - 1
							]
							'line [
								parse skip draw/shape 3 [
									some [pair! (cnt: cnt + 1)]
								]
								cnt
							]
							spline 'spline [
								parse find/tail draw 'spline [
									some [pair! (cnt: cnt + 1)]
								]
								cnt - 1
							]
							arc curve qcurve [1]
						]
					]
					get-leg-points: function [leg /local start end step df][
						cnt: 0
						switch shape/1 [
							snake [
								parse draw/shape [
									'move set start pair! (end: start)
									some [
										[	s: 'hline set step integer! (end/x: end/x + step)
										| 	s: 'vline set step integer! (end/y: end/y + step)
										] 	opt [if (leg <= cnt: cnt + 1) thru end]
									|	'arc set df pair! 3 integer! opt 'sweep 
										(start: end: end + df)
									]
								]
							]
							line hline vline [
								parse find/tail draw 'line [
									some [
										set start pair! 
										opt [if (leg <= cnt: cnt + 1) set point pair! (end: point) thru end]
									]
								]
							]
							'line [
								parse draw/shape [
									'move set start pair! 'line (end: start)
									some [
										set step pair! (end: end + step)
										[if (leg <= cnt: cnt + 1) thru end | (start: end)]
									]
								]
							]
							spline 'spline [
								parse find/tail draw 'spline [
									some [
										set start pair! 
										opt [if (leg <= cnt: cnt + 1) set point pair! (end: point) thru end]
									]
								]
							]
							arc [] ; TBD
							curve []
							qcurve []
						]
						reduce [start end]
					]
					get-pos: function [leg hor ver ofs ang tsz leg* ofs* ang* clr /local start* end*][
						set [start* end*] get-leg-points leg
						hsz: tsz / 2
						diff: end* - start*
						half: diff / 2
						;switch shape/1 [
						;	snake [
								vert?: (absolute diff/x) < (absolute diff/y);diff/x = 0;
								hor?: diff/y = 0
								hor: either hor [
									switch hor [
										left [
											pos: min start*/x end*/x
											if vert? [pos: pos - tsz/x]
											pos
										]
										right [
											pos: max start*/x end*/x
											if not vert? [pos: pos - tsz/x]
											pos
										]
										center [start*/x + half/x - hsz/x]
									]
								][
									switch/default leg* [
										start [
											either vert? [ 
												either distance/x < 0 [start*/x][start*/x - tsz/x]
											][
												either diff/x < 0 [start*/x - tsz/x][start*/x]
											]
										]
										end [
											either vert? [ 
												either distance/x < 0 [end*/x - tsz/x][end*/x]
											][
												either diff/x < 0 [end*/x][end*/x - tsz/x]
											]
										]
									][
										either vert? [
											either distance/x < 0 [start*/x][start*/x - tsz/x]
										][
											start*/x + half/x - hsz/x
										]
									]
								]
								ver: either ver [
									switch ver [
										top [
											pos: min start*/y end*/y
											if not vert? [pos: pos - tsz/y]
											pos
										]
										bottom [
											pos: max start*/y end*/y
											if vert? [pos: pos - tsz/y]
											pos
										]
										middle [start*/y + half/y - hsz/y]
									]
								][
									switch/default leg* [
										start [
											either vert? [ 
												either diff/y < 0 [start*/y - tsz/y][start*/y]
											][
												either distance/y < 0 [start*/y][start*/y - tsz/y]
											]
										]
										end [ 
											either vert? [ 
												either diff/y < 0 [end*/y][end*/y - tsz/y]
											][
												either distance/y < 0 [end*/y - tsz/y][end*/y]
											]
										]
									][
										either vert? [
											start*/y + half/y - hsz/y
										][
											either distance/y < 0 [start*/y][start*/y - tsz/y]
										]
									]
								]
						;	]
						;	line []
						;	spline []
						;	arc []
						;	curve []
						;	qcurve []
						;]
						pos: as-pair hor ver
						if ofs* [pos: pos + (diff * ofs)]
						if ofs <> 0x0 [pos: pos + ofs]
						either ang* = 'align [
							ang-df: end* - start*
							ang*: arctangent2 ang-df/y ang-df/x
							case [
								ang* > 90 	[ang*: ang* - 180] 
								ang* < -90 	[ang*: ang* + 180]
							]
						][ang*: 0]
						ang: ang + ang*
						reduce [pos ang hsz]
					]
					text-pos: function [face text /local hor ver leg*][
						text-size: size-text/with test text
						half: text-size / 2
						;print [end-pos start-pos end-pos - start-pos / 2 text-size text-size / 2]
						leg: 1
						ofs: 0x0
						ang: 0
						if all [face/data label: face/data/label] [
							either block? label [
								ofs: 0x0
								parse label [
									any [s:
										['start | 'end | 'mid] (
											leg: switch s/1 [
												start [leg*: 'start 1] 
												mid [1 + (count-legs face) / 2]
												end [leg*: 'end count-legs face]
											]
										)
									|	'leg set leg integer!
									|	set hor ['left | 'center | 'right]
									|	set ver ['top | 'middle | 'bottom]
									|	set ofs pair!
									|	set ofs* percent!
									|	set ang integer!
									|	set ang* 'align
									|	set clr [tuple! | word! if (tuple? get clr)]
									]
								]
							][
								case [
									label =	'start [leg: 1 leg*: 'start]
									label = 'mid [leg: 1 + (count-legs face) / 2]
									label = 'end [leg: count-legs face leg*: 'end]
									found: find [left center middle] label [hor: found/1]
									found: find [top middle bottom] label [ver: found/1]
									percent? label [ofs*: label]
									pair? label [ofs: label]
									label = 'align [ang*: label]
									integer? label [ang: label]
									any [tuple? label all [word? label tuple? get label]][clr: label]
								]
							]
						]
						;print ["data2: " leg hor ver ofs ang text-size leg*]
						get-pos leg hor ver ofs ang text-size leg* ofs* ang* clr
					]
					find-pos: function [face parent][
						either find parent/pane face [
							face/offset + (face/size / 2)
						][
							ofs: 0x0
							fc: face/parent
							while [fc <> parent][
								ofs: ofs + fc/offset
								fc: fc/parent
							]
							ofs + face/offset + (face/size / 2)
						]
					]
					;on-create: func [f e][probe "cr-conn1"]
					on-created: function [
						face 
						event 
						/local path ofs start-set? end-set? elem 
						/extern start-pos end-pos distance shape draw
					][;probe "cr-conn2"
						face/size: face/parent/size
						
						;if face/data [probe face/data]
						
						; Get starting node
						unless all [
							face/data
							from: face/data/from 
							start: all [
								block? from 
								any [
									all [
										each: find/tail from 'each
										each/1
										;switch type?/word each/1 [
										;	block! [each/1]				; bunch of provided styles/nodes
										;	get-word! [probe select get to-word each/1 'pane]
										;]
									]
									all [
										from-node: find from get-word! 
										get to-word from-node/1
									]
									all [
										point: find/tail from 'point
										reduce ['offset point/1 'size 0x0]
									]
									all [
										skp: find/tail from 'skip
										me: find face/parent/pane face
										first skip me skp/1
									]
									all [
										from-node: find from object!
										first from-node
									]
								]
							] 
						][
							pane: find face/parent/pane face
							until [
								pane: back pane 
								not any [
									pane/1/options/style = 'connect
									pane/1/options/parent-style = 'connect
								]
							]
							start: first pane
						]
						
						; Get ending node
						unless all [
							face/data
							to: face/data/to 
							end: all [
								block? to 
								any [
									all [
										to-node: find to get-word! 
										get to-word to-node/1
									]
									all [
										point: find/tail to 'point
										reduce ['offset point/1 'size 0x0]
									]
									all [
										skp: find/tail to 'skip
										me: find face/parent/pane face
										first skip me skp/1
									]
									all [
										each: find/tail to 'each
										block? each/1 
										each/1				; bunch of provided styles/nodes
									]
									all [
										to-node: find to object!
										first to-node
									]
								]
							]
						][
							pane: find face/parent/pane face
							;print ["qw" index? pane pane/2/type]
							until [
								pane: next pane 
								not any [
									pane/1/options/style = 'connect
									pane/1/options/parent-style = 'connect
								]
							]
							end: first pane
							if not end/parent [end/parent: face/parent]
							;prin ["par: "] print end/parent/type
						]
						
						; From each?
						if all [from each: find/tail from 'each][
							case [
								any [
									block? each: each/1 
									all [word? each each: get each]
									all [get-word? each each: select get to-word each 'pane]
								][
									;parent-opts: any [face/parent/options face/parent/options: copy []]
									;move/part find face/options 'styles parent-opts 2
									;styles: face/parent/options/styles
									;prin "each: " probe each 
									cnt: 0
									; find position after current connect
									found: find/tail face/parent/pane face
									; copy data of current connect
									data*: copy/deep face/data
									; duplicate current options
									opts*: face/options
									; remove `each` option
									remove/part find data*/from 'each 2
									; adjusted from
									from*: data*/from
									parse each [
										some [(cnt: cnt + 1 w: nod: none)
											set nod get-word! opt [set w string!] (
												either cnt = 1 [
													start: get to-word nod
												][
													;prin "from: " probe 
													data*/from: append copy from* nod
													found: insert found layout/only compose [
														connect with [data: copy/deep data* options: opts*] (any [w []])
													]
												]
											)
										|	set nod object! (
												either cnt = 1 [
													start: nod
												][
													data*/from: append copy from* nod
													found: insert found layout/only compose [
														connect with [data: copy/deep data* options: opts*]
													]
												]
											)
										]
									]
								]
							]

						]
						; To each?
						if all [to each: find/tail to 'each][
							case [
								all [end/pane not empty? pane: end/pane][
									if 1 < length? pane [
										found: find/tail face/parent/pane face
										pane: next pane 
										data*: copy/deep face/data
										opts*: face/options
										change find data*/to 'each to-get-word 'ob
										until [
											ob: pane/1
											insert found layout/only dia [
												connect forward with [data: data* options: opts*]
											]
											pane: next pane 
											tail? pane
										]
										end: end/pane/1
									]
								]
								block? each/1 [
									parent-opts: any [face/parent/options face/parent/options: copy []]
									move/part find face/options 'styles parent-opts 2
									styles: face/parent/options/styles
									
									cnt: 0
									found: find/tail face/parent/pane face
									data*: copy/deep face/data
									opts*: face/options
									remove/part find data*/to 'each 2
									parse each/1 [
										some [(cnt: cnt + 1 w: i: none)
											set i integer! set nod word! ( 
												if cnt = 1 [
													found: insert found layout/only/styles dia compose [(nod)] styles
													end: found/-1
												]
												found: insert found layout/only/styles dia append/dup copy [] compose/deep/only [
													connect with [data: (data*) options: (opts*)] (nod) 
												] either cnt = 1 [i - 1][i] styles
											)
										|	set nod word! opt [set w string!](
												either cnt = 1 [
													found: insert found layout/only/styles dia compose [(nod) (any [w []])] styles
													end: found/-1
												][
													found: insert found layout/only/styles dia compose/deep [
														connect with [data: data* options: opts*] (nod) (any [w []])
													] styles
												]
											)
										|	get-word! ()
										]
									]
								]
							]
						]
						
						; Register connections to nodes  ;NB! Only if `bound`?
						either start/options/to [
							append start/options/to face
							append start/options/to-nodes end
						][
							put start/options 'to append copy [] face
							put start/options 'to-nodes append copy [] end
						]
						either end/options/from [
							append end/options/from face
							append end/options/from-nodes start
						][
							put end/options 'from append copy [] face
							put end/options 'from-nodes append copy [] start
						]
						
						; Infer direction
						dir: pick [vertical horizontal] make logic! all [
							face/parent/options 
							face/parent/options/vertical
						]
						if all [face/data hint: face/data/hint] [
							switch type?/word hint [
								lit-word! word! [
									if find [vertical horizontal] hint [
										dir: hint
									]
								]
								integer! [path: to-block hint]
								block! [
									if find [vertical horizontal] first hint [
										dir: take hint
									]
									path: hint
								]
							]
						]
						vertical?: dir = 'vertical
						
						; Find initial starting- and ending-points
						either any [start/parent = end/parent block? start block? end] [
							start-pos: start/offset + (start/size / 2)
							end-pos: end/offset + (end/size / 2)
						][  ; If on different panels
							parent: face/parent ;connector's parent
							start-pos: find-pos start parent
							end-pos: find-pos end parent
						]
						
						; Start-point
						half: start/size / 2
						if from [
							ofs: either ofs: find from pair! [ofs/1][0x0]
							unless empty? start-point: intersect from points [
								start-set?: yes
								put face/options 'start-point first start-point
								switch first start-point [
									top [start-pos/y: start-pos/y - half/y]
									bottom [start-pos/y: start-pos/y + half/y]
									left [start-pos/x: start-pos/x - half/x]
									right [start-pos/x: start-pos/x + half/x]
									top-left [start-pos: start/offset]
									top-right [start-pos: 1x-1 * half + start-pos]
									bottom-left [start-pos: -1x1 * half + start-pos]
									bottom-right [start-pos: half + start-pos]
									;center []
								]
							]
							if face/options/bound [
								put face/options 'start-ofs ofs
							]
						]
						unless start-set? [
							either vertical? [
								start-pos/y: start-pos/y + half/y
							][
								start-pos/x: start-pos/x + half/x
							]
						]
						if ofs [start-pos: start-pos + ofs] ofs: none

						; Adjust end/offset for `hline`/`vline`
						ortho?: none
						if all [shape: face/options/shape find [hline vline] shape/1][
							if not len: pick shape 2 [
								diff: end/offset - start-pos
								len: either shape/1 = 'hline [diff/x][diff/y]
							]
							step: either shape/1 = 'hline [as-pair len 0][as-pair 0 len]
							ortho?: shape/1
							end/offset: end-pos: start-pos + step
						]
						
						; End-point
						half: end/size / 2

						if to [
							ofs: either ofs: find to pair! [ofs/1][0x0]
							unless empty? end-point: intersect to points [
								end-set?: yes
								put face/options 'end-point first end-point
								switch first end-point [
									top [either ortho? [
										end/offset/x: end-pos/x - half/x
									][	end-pos/y: end-pos/y - half/y]]
									bottom [either ortho? [
										end/offset: end-pos - as-pair half/x end/size/y
									][	end-pos/y: end-pos/y + half/y]]
									left [either ortho? [
										end/offset/y: end-pos/y - half/y
									][	end-pos/x: end-pos/x - half/x]]
									right [either ortho? [
										end/offset: end-pos - as-pair end/size/x half/y
									][	end-pos/x: end-pos/x + half/x]]
									top-left [if not ortho? [end-pos: end/offset]]
									top-right [either ortho? [
										end/offset/x: end-pos/x - end/size/x
									][	end-pos: 1x-1 * half + end-pos]]
									bottom-left [either ortho? [
										end/offset/y: end-pos - end/size/y
									][	end-pos: -1x1 * half + end-pos]]
									bottom-right [either ortho? [
										end/offset: end-pos - end/size
									][	end-pos: half + end-pos]]
									;center []
								]
							]
							if face/options/bound [
								put face/options 'end-ofs ofs
							]
						]
						
						unless end-set? [
							either vertical? [
								case [
									not ortho? [end-pos/y: end-pos/y - half/y]
									shape/1 = 'vline [
										either negative? len [
											end/offset: end-pos - as-pair half/x end/size/y
										][	end/offset/x: end-pos/x - half/x]
									]
									true [
										either negative? len [
											end/offset/y: end-pos/y - half/y
										][	end/offset: end-pos - as-pair end/size/x half/y]
									]
								]
							][
								case [
									not ortho? [end-pos/x: end-pos/x - half/x]
									ortho? = 'hline [
										either negative? len [
											end/offset: end-pos - as-pair end/size/x half/y
										][	end/offset/y: end-pos/y - half/y]
									]
									true [
										either negative? len [
											end/offset: end-pos - as-pair half/x end/size/y
										][	end/offset/x: end-pos/x - half/x]
									]
								]
							]
						]
						if ofs [either ortho? [end/offset: end/offset - ofs][end-pos: end-pos + ofs]] 
						
						;if face/options/forward [
						;	me: find face/parent/pane face
						;	swap me next me
						;]
						me: find face/parent/pane face
						case [
							face/options/forward [
								pane: me
								until [
									pane: next pane
									any [
										pane/1/options/style <> 'connect
										pane/1/options/parent-style <> 'connect
									]
								]
								swap me pane
							]
							face/options/backward [
								pane: me
								;until [
								;	pane: skip pane -2
								;	any [
								;		pane/1/options/style <> 'connect
								;		pane/1/options/parent-style <> 'connect
								;	]
								;]
								there: find face/parent/pane start
								;print [index? me index? there]
								;move me there
							]
							face/options/back [
								;print [length? me length? face/parent/pane index? me index? face/parent/pane]
								;prin [index? me ": "]
								move me head face/parent/pane
								;print [index? me "."]
							]
							face/options/front [
								move me tail me
							]
						]
						;--------------
						
						if face/options/bound [
							put face/options 'start-offset start/offset
							put face/options 'end-offset end/offset
							put face/options 'start-point either start-set? [first start-point]['center]
							put face/options 'end-point either end-set? [first end-point]['center]
						]
						
						distance: end-pos - start-pos

						df: as-pair either 0 = distance/x [0][distance/x / absolute distance/x] ; Sector (avoid division by 0)
									either 0 = distance/y [0][distance/y / absolute distance/y] ; e.g. 1x0, 1x-1
						;diff: distance - (df * start/size / 2) - (df * end/size / 2)			; Distance between corners
						
						; Prepare draw-block
						draw: copy [pen black line-width 1 text 0x0 "" shape []]
						case/all [
							pen: face/options/pen [draw/pen: pen]
							line-width: face/options/line-width [draw/line-width: line-width]
							line-cap: face/options/line-cap [insert draw append [line-cap] line-cap]
							line-join: face/options/line-join [insert draw append [line-join] line-join]
							face/options/dashed [
								pattern: [10x10 [line 0x0 10x10]]
								insert pattern/2 take/part draw 4
								insert pattern/2 [rotate 18]
								insert draw compose [pen pattern (pattern)]
							]
						]
						
						; Draw shape
						either shape: face/options/shape [
							switch first shape [
								blank []
								line spline [
									change/part find draw 'shape compose [
										(first shape) (start-pos) (next shape) (end-pos)
									] 2
								]
								'line [
									pre: compose [move (start-pos) move (start-pos)]
									if find shape '_ [
										total: 0x0 cnt: 0
										foreach elem next shape [
											either pair? elem [total: total + elem][cnt: cnt + 1]
										]
										total: distance - total
										total: total * 1.0 / cnt
										replace/all shape '_ total
									]
									insert at pre 3 shape
									insert draw/shape pre
								]
								'spline [
									if find shape '_ [
										total: 0x0 cnt: 0
										foreach elem next shape [
											either pair? elem [total: total + elem][cnt: cnt + 1]
										]
										total: distance - total
										total: total * 1.0 / cnt
										replace/all shape '_ total
									]
									shape: next shape
									pos: start-pos
									forall shape [shape/1: pos: pos + shape/1]
									change/part find draw 'shape compose [
										(to-word first head shape) (start-pos) (shape) (end-pos)
									] 2
									shape: head shape
								]
								hline vline [
									change/part find draw 'shape compose [
										line (start-pos) (end-pos)
									] 2
								]
								arc [
									center: either sweep: face/options/shape/arc [
										as-pair end-pos/x start-pos/y 
									][
										as-pair start-pos/x end-pos/y
									]
									radius: absolute distance
									set [start-angle sweep] pick [[180 90][90 -90]] make logic! sweep
									change/part find draw 'shape reduce [
										'arc center radius start-angle sweep
									] 2
								]
								qcurve curve [
									if empty? control: next shape [
										curve?: 'curve = first shape
										repend control either curve? [
											either vertical? [
												[as-pair start-pos/x end-pos/y 
												 as-pair end-pos/x start-pos/y]
											][
												[as-pair end-pos/x start-pos/y 
												 as-pair start-pos/x end-pos/y]
											]
										][
											either vertical? [
												as-pair start-pos/x end-pos/y
											][
												as-pair end-pos/x start-pos/y
											]
										]
									]
									change/part find draw 'shape compose [
										curve (start-pos) (control) (end-pos)
									] 2
								]
								shape [
									pre: compose [move (start-pos) move (start-pos)]
									insert at pre 3 shape/2
									insert draw/shape pre
								]
							]
						][
							; Prepare snakeline argument block
							shape: [snake]
							lines: copy []
							backwards: no
							op: :append
							case [
								hint [
									either path [
										idx: 1 + length? path
										if found: find path '_ [
											idx: index? found
											path: head change/part found [0 0] 1
											op: :change
										]
										frst: sum extract path 2
										scnd: sum extract next path 2
										rest: end-pos - start-pos - either vertical? [
											as-pair scnd frst
										][	as-pair frst scnd]
										op at path idx case [
											any [
												all [vertical? 		odd? idx]
												all [not vertical? 	even? idx]
											][reduce [rest/y rest/x]]
											any [
												all [vertical? 		even? idx]
												all [not vertical? 	odd? idx]
											][reduce [rest/x rest/y]]
										]
									][
										path: copy []
										rest: end-pos - start-pos
										append path case [
										any [
											all [vertical? 		even? length? path]
											all [not vertical? 	odd? length? path]
										][reduce [rest/y rest/x]]
										any [
											all [vertical? 		odd? length? path]
											all [not vertical? 	even? length? path]
										][reduce [rest/x rest/y]]
									]
									]
									;prin "path: " probe 
									append lines path
									;probe lines
								]
								vertical? [
									repend lines [
										;(df/y * start/size/y / 2) + (diff/y / 2)
										distance/y / 2
										distance/x
										;(df/y * end/size/y / 2) + (diff/y / 2)
										distance/y / 2
									]
								]
								true [
									repend lines [
										;(df/x * start/size/x / 2) + (diff/x / 2)
										distance/x / 2
										distance/y
										;(df/x * end/size/x / 2) + (diff/x / 2)
										distance/x / 2
									]
								]
							]
							
							; Draw snakeline
							insert/dup draw/shape reduce ['move start-pos] 2
							knee: any [face/options/knee default-knee]
							insert at draw/shape 3 either vertical? [
								snakeline/vertical lines knee
							][
								snakeline lines knee
							]
						]
						
						; Set label(s)
						case [
							text: face/text [
								set [pos ang hsz] text-pos face text
								txt: find/tail draw 'text
								either ang = 0 [
									change/part txt reduce [pos copy text] 2
								][
									change at txt 2 text
									change/part back txt append/only compose [
										transform (ang) 1 1 (pos + hsz)
									] copy/part back txt 3 3
								]
								face/text: none
							]
							all [face/data label: face/data/label] []
							all [face/data labels: face/data/labels] []
						]
						
						; Adorn connector
						case/all [
							face/options/double [
								append draw copy/deep draw
								lw: first found: find/tail draw 'line-width
								change found 3 * lw
								pen: either clr: face/parent/color [clr][snow] 
								change find/last/tail draw 'pen pen
							]
							inc-ang: 0
							closed?: no
							dim: default-arrow
							clr: 'white
							if arrow: face/options/arrow [
								arrow-shape: [
									rotate (ang) (pos) 
									shape [
										move (pos - dim) 
										'line (dim) (as-pair 0 - dim/x dim/y) 
										move (pos - dim)
									]
								]
								either block? arrow [
									parse arrow [
										any [s: 
											'closed (closed?: yes)
										|	integer! (inc-ang: s/1)
										|	pair! (dim: s/1)
										|	[tuple! | word! if (tuple? get s/1)] (
												clr: s/1
											) 
										|	'end into []
										|	'start into []
										]
									]
									;if end: arrow/end []
									;if start: arrow/start []
								][
									case [
										arrow = 'closed [closed?: yes]
										integer? arrow [inc-ang: arrow]
										pair? arrow [dim: arrow]
									]
								]								
								if closed? [
									take/last/part arrow-shape/shape 2
									insert arrow-shape compose [fill-pen (clr)]
								] 
								switch shape/1 [
									snake [
										shape-end: skip tail draw/shape -4
										switch first shape-end [
											'vline [
												either negative? shape-end/2 [
													pos: end-pos 
													ang: -90
												][
													pos: end-pos 
													ang: 90
												]
											]
											'hline [
												either negative? shape-end/2 [
													pos: end-pos 
													ang: -180
												][
													pos: end-pos 
													ang: 0
												]
											]
										]
									]
									line spline 'spline hline vline [
										last-points: skip tail draw -2
										diff: last-points/2 - last-points/1
										ang: to-integer arctangent2 diff/y diff/x
										pos: end-pos
									]
									'line [
										diff: first skip tail draw/shape -3
										ang: to-integer arctangent2 diff/y diff/x
										pos: end-pos
									]
								]
								ang: ang + inc-ang
								append draw compose/deep arrow-shape
							]
						]
						face/draw: copy/deep draw
						;probe face/options
					]
				]
			]
			init: [;probe "conn1"
				at-offset: 0x0 
				;print ["spacing:" spacing]
				if all [face/options face/options/style <> 'connect] [			; For easy finding
					append face/options [parent-style: connect]
				]
				if all [
					face/data 
					any [
						all [face/data/to each: face/data/to/each] 
						all [face/data/from each: face/data/from/each]
					] 
					block? each
				][
					put face/options 'styles local-styles
				]
				;probe "conn2"
			]
		]
	]
]
context [
	default-space: 40x40 ; Is not used!
	s: s2: d: d2: data: opts: clr: none
	node-styles: copy ['node]
	connect-styles: copy ['connect]
	diagram-styles: copy ['diagram]
	position: [
		1 2 [pair! | 'center | 'top | 'bottom | 'left | 'right
		| 'top-left | 'top-right | 'bottom-left | 'bottom-right
		]
	|	'point pair!
	]
	anim-block: [
		ahead block! into anim-block
	|	some [
		  'tick block!
		| 'rate [integer! | time!] 
		]
	]
	
	diagram-rule: [s:
		opt [if (all [set-word? s/-2 'style = s/-3]) (
			append diagram-styles compose [| (to-lit-word s/-2)]
		)]
		opt [s: (opts: make block! 6 extra: make block! 2); actors: make block! 5) 
			some [d: 
				[ 'border [
					  integer! | block! | tuple! | issue!
					| set clr word! if (find [issue! tuple!] type?/word attempt [get clr])
					]
				| 'animate anim-block  										;TBD
				] (
				  append opts copy/part d 2
				)
			|	opt ['default d: s (append extra [default])]
				[ pair! (append extra append copy [size] d/1) 				; predetermined size
				| integer! (append extra append copy [width] d/1)			; predetermined width
				| ['width | 'height] integer! (append extra copy/part d 2)	; predetermined dim
				]
			|	'add [integer! | pair!] (append opts copy/part d 2)			; addition to calculated size
			|	['vertical | 'horizontal | 'force] (  ;TBD | 'radial 		; layout type
				  append opts append copy/part d 1 true
				)  
			| 	['drag | 'wheel | 'navigate | 'resize] ( ;TBD | 'scroll | 'zoom (?) | 'collapse | 'collapsible] (
				  append opts append copy/part d 1 true
				)  
			] s2: (
				remove/part s s2
				unless empty? extra [s: insert s compose/only [extra (extra)]]
				unless empty? opts [s: insert s compose/only [options (opts)]]
			) :s
			|	(s: insert s [options [horizontal: #[true]]]) :s
		]
	]
	connect-rule: [s: 
		opt [if (all [set-word? s/-2 'style = s/-3]) (
			append connect-styles compose [| (to-lit-word s/-2)]
		)]
		opt [s: (opts: make block! 10 data: make block! 10)
			some [d:
			  ['to | 'from] d3: [
				1 3 [position | get-word! | 'skip integer! | 'each opt [block! | get-word!]] d2: ( ; block may contain [some [integer! word! | word! | get-word!]]
				append data append/only copy/part d 1 copy/part d3 d2
			  )
			  | block! d2: (
				append data copy/part d d2
			  )
			]
			| ['hint | 'label | 'labels] skip (append data copy/part d 2)
			| [ ['pen | 'line-width | 'line-cap | 'line-join | 'knee] skip ;| 'end | 'start] skip ;TBD
			  | 'arrow ['closed | pair! | integer! | block!]
			  ] d2: (append opts copy/part d d2)
			| [ ['line | 'spline] any [pair! | '_]
			  | ['hline | 'vline] opt integer!
			  | 'arc opt 'sweep
			  | 'curve opt [2 pair!]
			  | 'qcurve opt pair!
			  | 'shape block!
			  | 'blank
			  ] d2: (
				append opts append/only copy [shape] copy/part d d2
			  )
			| ['arrow | 'dashed | 'double | 'forward | 'backward | 'front | 'back] (
				append opts append copy/part d 1 true
			  ) 
			| ['force opt block!] d2: (
				append opts 'force
				append/only opts either block? d2/-1 [d2/-1][true]
			  )
			] s2: (
				remove/part s s2
				unless empty? data [s: insert s compose/only [data (data)]]
				unless empty? opts [s: insert s compose/only [options (opts)]]
			) :s
		]
	]
	node-rule: [s: (opts: make block! 10)
		opt [if (all [set-word? s/-2 'style = s/-3]) (
			append node-styles compose [| (to-lit-word s/-2)]
		)]
		some [d:
			opt 'default [
			  'box opt pair! opt integer! 
			| ['diamond | 'ellipse] opt pair! 
			] d2: (append opts compose/only [shape: (copy/part d d2)])
		| 	[
			  'border skip
			| 'link url!
			;| 'shape block! ; TBD
			| 'rt [string! | block!]
			] (append opts copy/part d 2)
		] s2: (
			s: change/part s compose/only [options (opts)] s2
		) :s
	]
	set 'dia func [blk][
		;node-cnt: 0
		clear next diagram-styles
		clear next connect-styles
		clear next node-styles
		parse blk rule: [
			some [
				  diagram-styles diagram-rule
				| node-styles node-rule
				| connect-styles connect-rule
				| ahead block! into rule
				| skip
			]
		] 
		blk
	]
]

