Red [
	Title: 			{Diagram dialect}
	Description: 	{Extends VID to allow easy diagram description}
	Author: 		{Toomas Vooglaid}
	Date:			31-May-2019
	Last:			7-Jul-2019
	Version:		#0.6
	Licence: 		"MIT"
	RedBNF:			{
		diagram: [['diagram | diagram-style] any diagram-settings any panel-settings diagram-block]
		diagram-settings: [direction | size-spec | border-spec | funcs]
		direction: ['vertical | 'horizontal] ; General direction for connector, default is `horizontal`
		size-spec: [integer! | pair! | ['width | 'height] integer!] ; single integer! -- width
		border-spec: ['border [integer! | color-spec | border-block]]
		color-spec: [color-word | tuple!]
		border-block: [
			  quote line-width: integer! quote pen: [color-word | tuple!] 
			| quote pen: [color-word | tuple!] quote line-width: integer!
		]
		funcs: [any ['drag | 'wheel | 'navigate]]
		diagram-block: [any [VID-keywords | node-spec | connect-spec]]
		
		node-spec: [['node | node-style] any node-settings any base-settings]
		node-settings: [shape-spec | border-spec | link-spec | rt-spec]
		shape-spec: [box-shape | ellipse-shape | diamond-shape] ;| custom-shape ; TBD 
		box-shape: ['box opt pair! opt integer!] ; pair! is size, integer! is corner radius
		ellipse-shape: ['ellipse pair!] ; pair! is size
		diamond-shape: ['diamond pair!] ; pair! is size
		border-spec: ['border [integer! | word! | tuple! | border-block]] ; integer! is line-width, [word! | tuple!] is color
		border-block: [
		  'line-width integer! 'pen [word! | tuple!] 
		| 'pen [word! | tuple!] 'line-width integer!
		]
		link-spec: ['link url!]
		rt-spec: ['rt rtd-layout-block] 					; if this is given normal text should not be set
		
		connect-spec: [['connect | connect-style] any connect-settings any base-settings]
		connect-settings: [from-attr | to-attr | hint-attr | label-attr | format-attr | move-attr | force-attr]
		from-attr: ['from 1 3 [point-name | point-offset | :node-ref]]
		to-attr: ['to 1 3 [point-name | point-offset | :node-ref | 'each opt block!]] ; `each` for several targets 
															; inside a panel or another `diagram` (examples 7)
															; or in provided block (example 8)
		point-name: ['top | 'bottom | 'left | 'right | 'top-left | 'top-right | 'bottom-right | 'bottom-right | 'center]
			; by default (i.e. horizontal direction) -- from `right` to `left`
			; default for vertical direction -- from `bottom` to `top`
		point-offset: pair! ; additional offset from named point
		hint-attr: ['hint [direction | path-step | hint-spec]]
		direction: ['vertical | 'horizontal]
		path-step: integer!   								; length of first leg
		hint-spec: [some [opt direction any path-step]]
		label-attr: ['label [label-spec | label-block]]
		label-spec: [pos-word | align | valign | position | angle | color-spec]
		pos-word: ['start | 'end | 'mid]
		align: ['left | 'right | 'center]
		valign: ['top | 'bottom | 'middle]
		position: [pair! | percent!] 							; offset from start of line or leg
		angle: ['align | integer!]							; `align` tries to guess the angle of line, integer! sets the angle
		label-block: [any [label-spec | 'leg integer!]]		; `leg` sets position at given int leg of segmnted connector
		format-attr: [shape-spec | line-format | arrow-spec]
		shape-spec: [line-spec | rel-line-spec | rel-spline-spec | ortho-line-spec | arc-spec | curve-spec | qcurve-spec]
		line-spec: [['line | 'spline] any pair!] 			; intermediate points only - start- and end-points are automatically given
		rel-line-spec: [quote 'line any ['_ | pair!]] 		; `_` - automatically computed legs, 
															; pair!s are relative, start/end-points are automatic
		rel-spline-spec: [quote 'spline any [pair! | '_]] 	; as above, pair!s are control-points
		ortho-line-spec: [['hline | 'vline] integer!] 		; relocates to-node to the endpoint of ortho-line
		arc-spec: ['arc opt 'sweep] 						; if `sweep` is present, arc is drawn clockwise, otherwise counterclockwise
		curve-spec: ['curve opt [2 pair!]] 					; cubic bezier curve - pair!-s are control-points
		qcurve-spec: ['qcurve opt pair!] 					; quadratic bezier curve - pair! is control-point
		line-format: ['line-width integer! | 'pen [color-word | tuple] | ['line-join | 'line-cap] word! | 'dashed | 'double] 
															; `dashed` is experimental, does not produce good result now 
		arrow-spec ['arrow opt ['closed | integer! | pair! | arrow-block]] ; TBD add `shape` for custom shape
		arrow-block: [any [integer! | pair! | 'closed]] 	; integer for optional angle, pair! for dimensions (x--length , y--half-width)
		move-attr: [opt 'forward]							; `forward` moves connectors before the targeted panel/node (useful e.g. with `each`)
		force-attr: [some [
			'radius integer! 								; distance from node to connected nodes (in pixels)
		  |	['attract | 'repulse] [integer! | float!] 		; attractive and repulsive forces coeficients (~ 0.1 - 5)
		  |	'coef integer!									; another coeficient for repulsive force (currently 10000 or 1000)
		]]
	}
]
;probe system/options
;probe system/standard
;probe system/script
context [
	;line2: l2: none
	set 'snakeline function [lines radius /vertical /horizontal /extern line2 l2][
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
					l1: lines/1 l2: lines/2
					keep line1
					
					; Make room for arcs
					cf1: pick [1 2] head? lines
					keep l1*: either all [cf1 * radius < absolute l1 l1 <> 0] [
						l1 / (absolute l1) * ((absolute l1) - (cf1 * radius))
					][0]
					cf2: pick [1 2] 2 = length? lines
					l2*: either all [cf2 * radius < absolute l2 l2 <> 0] [
						l2 / (absolute l2) * ((absolute l2) - (cf2 * radius))
					][0]
					
					; Find arc's end-point
					l1': either 0 = l1 [1][l1 / absolute l1] ; Avoid dividing by 0
					l2': either 0 = l2 [1][l2 / absolute l2]
					either line1 = 'hline [
						a: as-pair l1' l2'
						r1: min radius max 0 (absolute l1) / cf1
						r2: min radius max 0 (absolute l2) / cf2
					][
						a: as-pair l2' l1'
						r2: min radius max 0 (absolute l1) / cf1
						r1: min radius max 0 (absolute l2) / cf2
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
					keep line2 keep l2*						; last line
				]
			]
		]
	]
]

diagram-ctx: context [
	test: make face! [type: 'area size: 100x100]
	;pos-text: func [text][
	;	sz: size-text/with
	;]
	;node-cnt: 0
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
		foreach node nodes/pane [
			if all [
				node/options
				none? node/options/at-offset
			][
				node/offset: as-pair first j: random nodes/size second j
				reconnect node
			]
		]
	]
	calc-forces: function [face][
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
							;stp: as-pair s * cosine ang s * sine ang
							;f: f + stp
						][
							repulse: any [all [force: conn/options/force force/repulse] default-repulse]
							coef: any [all [force: conn/options/force force/coef] default-coef]
							d: coef / dis
							s: log-10 da: absolute d 
							s: repulse * negate d / da * s
						]
						stp: as-pair s * cosine ang s * sine ang
						f: f + stp
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
	]
	
	extend system/view/VID/styles [
		diagram: [
			template: [
				type: 'panel
				draw: copy []
				actors: [
					;on-create: func [face][probe "cr-dia1"
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
						
						;case/all [
						; Adjust size
						if not all [face/extra face/extra/size not any [
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
						
							face/size: mx + add-space;15
							
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
						if face/options/force [randomize face]
						show face/parent
					]
					;on-time: function [face event][calc-forces face]
					on-drag: function [face event][]
					on-wheel: function [face event][]
					on-down: function [face event][]
					on-over: function [face event /local df s][]
					on-up: function [face event][]
					on-key-down: function [face event][]
				]
			]
			init: [;probe "dia1"
				if face/options/style <> 'diagram [			; For easy finding
					append face/options [parent-style: diagram]
				] 
				add-space: either all [face/options add-sp: face/options/add][add-sp][0]
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
							append body-of :face/actors/on-drag bind copy [
								face/offset/x: min 0 max face/parent/size/x - face/size/x face/offset/x 
								face/offset/y: min 0 max face/parent/size/y - face/size/y face/offset/y
								show face 'end
							] :face/actors/on-drag
							append body-of :face/actors/on-down bind bind [
								system/view/auto-sync?: off pos: face/offset
							] face/actors :face/actors/on-down
						]
						opts*/wheel [
							append body-of :face/actors/on-wheel bind copy/deep [
								case [
									event/ctrl? [
										face/offset/x: min 0 max 
											face/parent/size/x - face/size/x 
											face/offset/x + (10 * event/picked)
									]
									event/shift? []
									true [
										face/offset/y: min 0 max 
											face/parent/size/y - face/size/y 
											face/offset/y + (10 * event/picked)
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
				size: 80x50;35
				actors: [
					draw*: none
					text-pos: function [face][
						sz: size-text face
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
								face/actors/text-pos face		; Transfer text
							]
						]
					]
					on-down: func [face event][] 		; Waiting for links
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
					face/options/shape 
					not empty? intersect face/options/shape [box ellipse diamond]
				][
					shape: at draw* 7
					remove/part shape switch shape/1 [
						box [4] ellipse [3] diamond [5]
					]
					case [
						found: find/tail face/options/shape 'box [
							shape: insert shape [box 0x0]
							if pair? found/1 [face/size: found/1]
							shape: insert shape face/size - 1
							insert shape either found: find/part found integer! 2 [found/1][default-corner]
						]
						found: find/tail face/options/shape 'ellipse [
							shape: insert shape [ellipse 0x0]
							if pair? found/1 [face/size: found/1]
							insert shape face/size - 1
						]
						found: find/tail face/options/shape 'diamond [
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
					insert body-of :face/actors/on-down compose [browse (link)]
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
							line [
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
										from-node: find from get-word! 
										get to-word from-node/1
									]
									all [
										point: find/tail from 'point
										reduce ['offset point/1 'size 0x0]
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
										each: find/tail to 'each
										block? each/1 
										each/1				; bunch of provided styles/nodes
									]
									;all [
									;	to-node: find to object!
									;	to-node/1
									;]
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
										|	word! opt [set w string!](
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
						
						; Find starting- and ending-points
						;prin ["hi" start/parent/type] prin [" " face/parent/type] print [" " end/parent/type "ho"]
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
						if ofs [end-pos: end-pos + ofs] 
						
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
								until [
									pane: back back pane
									any [
										pane/1/options/style <> 'connect
										pane/1/options/parent-style <> 'connect
									]
								]
								swap pane me
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
							case [
								hint [
									either path [
										frst: sum extract path 2
										scnd: sum extract next path 2
										rest: end-pos - (start-pos + either vertical? [
											as-pair scnd frst
										][	as-pair frst scnd
										])
									][
										path: copy []
										rest: end-pos - start-pos
									]
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
									line spline 'spline [
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
					]
				]
			]
			init: [;probe "conn1"
				at-offset: 0x0 
				;print ["spacing:" spacing]
				if all [face/options face/options/style <> 'connect] [			; For easy finding
					append face/options [parent-style: connect]
				]
				if all [face/data face/data/to each: face/data/to/each block? each][
					put face/options 'styles local-styles
				]
				;probe "conn2"
			]
		]
	]
]
context [
	default-space: 40x40
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
				| 'animate anim-block
				] (
				  append opts copy/part d 2
				)
			|	[ pair! (append extra append copy [size] d/1) 				; predetermined size
				| integer! (append extra append copy [width] d/1)			; predetermined width
				| ['width | 'height] integer! (append extra copy/part d 2)	; predetermined dim
				]
			|	'add [integer! | pair!] (append opts copy/part d 2)			; addition to calculated size
			|	['vertical | 'horizontal | 'force | 'radial] ( ;'border | 			; layout type
				  append opts append copy/part d 1 true
				)  
			| 	['drag | 'wheel | 'navigate | 'resize] ( ;TBD | 'scroll | 'zoom | 'collapse | 'collapsible] (
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
				1 3 [position | get-word! | 'each opt block!] d2: ( ; block may contain [some [integer! word! | word! | get-word!]]
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
			[
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

;Examples/tests
switch 0 [; 1..8
	1 [ ;Giuseppe's, anim, resize
		tick: 0
		view/flags probe dia [
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
	2 [ ;2 diagrams
		view probe dia [
			size 340x550
			;style dbl: connect extra [double]
			below
			diagram 320 border 1 vertical add 0x10 beige "Diagram example" [ ;  ;310x280
				style closed-arrow: connect arrow closed from bottom to top;default 'connect 
				space 40x40 
				pad 60x0 
				n1: node ellipse water font [color: white style: [bold italic] size: 12] "One" 
				closed-arrow from bottom-left 10x-10 to top
				return n2: node "Two" 
				closed-arrow from bottom-right -10x-10 :n1 to top ;connect from n1 arrow closed
				pad 5x0 n3: node diamond 60x50 "Three" 
				connect arrow closed from left to top hint horizontal;connect double 
				return pad 75x0 node box 50x30 "Four" 
				connect arrow closed from :n3 to top hint horizontal;connect from n3 double line-width 2 
				docs: node link https://www.red-lang.org/p/documentation.html "Re(a)d docs" 
				closed-arrow from left to bottom :docs hint [horizontal -20 50]
				connect from right to bottom hint horizontal line-width 2 pen brick arrow; ; 45 -150 -100 50 -70
				return pad 250x-250 node ellipse 40x40 
					border [line-width: 5 pen: gold] 
					link https://www.red-lang.org
					font-color red 
					"Red"
			] ;rate 0:0:2 on-time [unview]
			pad 0x60
			diagram 320 border 1 add 0x10 "Problem workout" beige [;size 330x170 
				style step: node border gray font-color black 
				style chk: node diamond border gray font-color black 
				style note: node box 60x60 0 border silver font [color: gray name: "Times New Roman"]
				space 30x20
				origin 40x10 
				think: step font-size 8 {Think about^/the problem}
				connect line line-width 3 pen gray arrow ;from right to left
				below pad -2x-2 step border [line-width 4 pen brick] "Experiment"
				connect line hint vertical line-width 3 pen gray arrow from bottom to top; [vertical 40]
				pad 2x2 across clr: chk "Clear?" 
				connect from bottom to left -3x0 :think hint [vertical 20 -170] line-width 3 pen red arrow label [start 2x0] "No"
				connect line line-width 3 pen leaf arrow from left to right label start "Yes"
				pad -220x0 step "Implement"
				connect line 230x70 from top 20x10 :clr ;spline 
				at 250x40 note box 60x60 0 rt [f 8 i "Some " /i u "remarks" /u b " here" /b /f] yello ;"Some^/remarks^/here";
			]
		]
	]
	3 [ ;Type system, wheel, navigate
		;system/view/auto-sync?: off
		view/tight/no-wait lay: layout probe dia [
			size 940x800 title "Red type system" 
			style type-box: diagram border [pen: black] init [axis: 'y]
			style conn: connect knee 3 
			style hlin: connect hline 20
			style type: node border off transparent 78x20 init [axis: 'y]
			di: diagram wheel navigate height 780 add 0x5 snow [; width ;913x780
				type-box 800 220.230.220 [
					type-box 690x20 200.220.200 [
						pad 300x-10 type "unset!"							]	hlin at 0x0 type "internal!" 
						
					type-box 690 200.220.200 [
						type-box 580x20 180.200.180 [
							at 300x0 type "event!"						]	hlin at 0x0 type "external!" 
							
						type-box 580 180.200.180 [
							type-box 470 160.190.160 [
								pad 280x0 	char: type "char!" 
								handle: type "handle!"
								pad -280x0 type-box 360 140.180.140 [
									pad 150x0 
									int: type "integer!"
									float: type "float!" connect hline 40 at 0x0 type "percent!"
																]	hlin at 0x0 type "number!" 
								pad 280x0	time: type "time!" 
								date: type "date!" 
								pair: type "pair!" 
								tuple: type "tuple!"
										conn from :int to :char
										conn from :int to :handle
										conn from :float to :time
																	]	hlin at 0x0 type "scalar!"
							type-box 470 160.190.160 [
								type-box 360 140.180.140 [
									pad 150x20 
									word: type "word!"	
										conn pad 120x-60 type "lit-word!"
										connect hline 40 from :word type "set-word!"
										conn from :word type "get-word!"
																]	hlin at 0x0 type "any-word!" 
								pad 280x0 type "refinement!"
								type "issue!"
																	]	hlin at 0x0 type "all-word!" 
							pad 290x0 type "datatype!"
							type "none!"
							type "logic!"
							type "typeset!"
																		]	hlin at 0x0 type "immediate!" 
						pad 300x0 type "map!"
						type "bitset!"
						
						pad -300x0 type-box 580 180.200.180 [
							pad 170x0 type "function!" 	connect hline 40 type "routine!"
							native: type "native!" 		conn pad 120x-60 type "op!"
														connect hline 40 from :native type "action!"
																		]	hlin at 0x0 type "any-function!"
						type-box 580 180.200.180 [
							pad 170x0 type "object!" 	connect hline 40 at 0x0 type "error!"
																		]	hlin at 0x0 type "any-object!"
						type-box 580 180.200.180 [
							type-box 470 160.190.160 [
								pad 40x20 string: type "string!"	
									conn pad 120x-60 type "url!" connect hline 40 type "file!"
									connect hline 160 from :string at 0x0 type "email!"
									conn from :string hint [horizontal 21] pad 120x0 type "tag!"
																	]	hlin at 0x0 type "any-string!"
							pad 290x0 	conn from :string hint [horizontal 21] 
											type "binary!"
										conn from :string hint [horizontal 21] 
											type "vector!"
										type "image!"
										
							pad -290x0 type-box 470 160.190.160 [
								type-box 360 140.180.140 [
									pad 30x0 block: type "block!" 	
										connect hline 160 at 0x0 type "hash!"
										conn from :block hint [horizontal 21] pad 235x0 type "paren!"
																]	hlin at 0x0 type "any-list!"
								pad 100x0 type-box 260 140.180.140 [
									pad 50x20 path: type "path!" 
										conn pad 120x-60 type "lit-path!"
										connect hline 40 from :path type "set-path!"
										conn from :path type "get-path!"
																]	hlin at 0x0 type "any-path!"
								conn from :block to :path hint [horizontal 21] 
																	]	hlin at 0x0 type "any-block!"
																		]	hlin at 0x0 type "series!"
																			] 	hlin at 0x0 type "default!" 
																				] 	hlin at 0x0 type "any-type!"
			] ;rate 0:0:2 on-time [unview]
		]
	]
	4 [ ;Tables, wheel, drag
		view probe dia [
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
	]
	5 [ ;Grid, arrows, labels, drag
		if not value? 'img [
			img: draw/transparent 21x21 [
				fill-pen red 
				translate 10x10 
				polygon 0x-10 2x-5 10x-10 5x-2 10x0 5x2 10x10 2x5 0x10 -2x5 -10x10 -5x2 -10x0 -5x-2 -10x-10 -2x-5
			]
		]
		view probe dia [
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
				r4c1: cell r4c2: cell pad 5x0 r4c3: image img r4c4: cell return
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
			;rate 0:0:2 on-time [unview]
		]
	]
	6 [ ;Connect with normal faces
		img: draw/transparent 31x31 [fill-pen red translate 15x15 polygon 0x-15 5x-5 15x0 5x5 0x15 -5x5 -15x0 -5x-5]
		view probe dia [
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
			;rate 0:0:2 on-time [unview]
		]
	]
	7 [ ;`each`
		view probe dia [diagram vertical [
			style nod: node ellipse 50x50
			space 30x10 pad 90x0  
			top: nod "top" return 
			connect to each forward 
			dgr: diagram [
				space 30x30 
				one: nod "one" two: nod "two" three: nod "three" 
			] 
			return
			connect from :one to each left hint vertical forward
			pad 40x0 diagram [space 30x30 below nod "one-1" nod "one-2"]
			connect from :three to each right hint vertical forward
			pad -20x0 diagram [space 30x30 below nod "three-1" nod "three-2"]
			return
			pad 40x0 diagram [space 30x30 two-1: nod "two-1" two-2: nod "two-2"]
			connect from :two to [:two-1 right] hint vertical
			connect from :two to [:two-2 left] hint vertical
		]]
	]
	8 [ ;Force
		view probe dia [diagram force rate 10 on-time [diagram-ctx/calc-forces face][
			size 500x500 
			at 410x10 button "Randomize" [diagram-ctx/randomize face/parent]
			style o: node ellipse 14x14 red loose  
			style o2: node ellipse 4x4
			b1: o "1" 
			connect blank from [center :b1] to [center each [10 o2]]
			connect blank from [center :b1] to [center each [35 o2]] force [radius 100]
		]]
	]
]
