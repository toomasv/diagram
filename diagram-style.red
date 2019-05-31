Red [
	Title: 			{Diagram dialect}
	Description: 		{Extends VID to allow easy diagram description}
	Author: 		{Toomas Vooglaid}
	Date:			31-May-2019
	Version:		#0.5
	RedBNF:			{
		diagram: ['diagram any [diagram-settings panel-settings] diagram-block]
		diagram-settings: [direction | size-spec | border-spec]
		direction: ['vertical | 'horizontal]
		size-spec: ['size pair!]
		border-spec: ['border opt [integer! | color-spec | border-block]]
		color-spec: [color-word | tuple!]
		border-block: [
			  quote line-width: integer! quote pen: [color-word | tuple!] 
			| quote pen: [color-word | tuple!] quote line-width: integer!
		]
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
		rt-spec: ['rt rtd-layout-block] ; if this is given normal text should not be set
		
		connect-spec: [['connect | connect-style] any connect-settings any base-settings]
		connect-settings: [from-attr | to-attr | hint-attr | format-attr]
		from-attr: ['from 1 3 [point-name | point-offset | :node-ref]]
		to-attr: ['to 1 3 [point-name | point-offset | :node-ref]]
		point-name: ['top | 'bottom | 'left | 'right | 'top-left | 'top-right | 'bottom-right | 'bottom-right | 'center]
		point-offset: pair!
		hint-attr: ['hint [direction | path-step | hint-spec]]
		direction: ['vertical | 'horizontal]
		path-step: integer!
		hint-spec: [some [opt direction any path-step]]
		format-attr: [shape-spec | line-format | arrow-spec]
		shape-spec: [line-spec | spline-spec | arc-spec | curve-spec | qcurve-spec]
		line-spec: ['line any pair!] ; intermediate points only - start- and end-points are automatically given
		spline-spec: ['spline any pair!] ; Remarks as above 
		arc-spec: ['arc opt 'sweep] ; If `sweep` is present, arc is drawn clockwise, otherwise counterclockwise
		curve-spec: ['curve opt [2 pair!]] ; Cubic bezier curve - pair!-s are control-points
		qcurve-spec: ['qcurve opt pair!] ; Quadratic bezier curve - pair! is control-point
		line-format: ['line-width integer! | 'pen [color-word | tuple] | 'dashed | 'double] ; `dashed` is experimental, 
			does not produce good result now
		arrow-spec ['arrow opt 'closed] ; TBD add integer for optional angle, add pair! for dimensions, add `shape` for custom shape
	}
]
context [
	line2: l2: none
	set 'snakeline func [lines radius /vertical /horizontal /local line1 l1 a1 a2][
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
					cf: pick [1 2] head? lines
					keep l1*: either all [(short-l1?: (cf * radius) < absolute l1) l1 <> 0] [
						l1 / (absolute l1) * ((absolute l1) - (cf * radius))
					][0]
					cf: pick [1 2] 2 = length? lines
					l2*: either all [(short-l2?: (cf * radius) < absolute l2) l2 <> 0] [
						l2 / (absolute l2) * ((absolute l2) - (cf * radius))
					][0]
					
					; Find arc's end-point
					l1': either 0 = l1 [1][l1 / absolute l1] ; Avoid dividing by 0
					l2': either 0 = l2 [1][l2 / absolute l2]
					either line1 = 'hline [
						a: as-pair l1' l2'
						r1: min radius max 0 (absolute l1) / 2
						r2: min radius max 0 (absolute l2) / 2
					][
						a: as-pair l2' l1'
						r2: min radius max 0 (absolute l1) / 2
						r1: min radius max 0 (absolute l2) / 2
					]
					keep ['arc] keep a * as-pair r1 r2

					keep radius + (radius - r2 * 5) 		; To avoid bumps in case of strighter lines
					keep radius + (radius - r1 * 5) 
					keep 0
					if any [
						all [line1 = 'hline a/1 = a/2]
						all [line1 = 'vline a/1 <> a/2]
					][keep 'sweep]
				][
					keep line2 keep l2*				; last line
				]
			]
		]
	]
]

context [
	test: make face! [type: 'area size: 100x100]
	pos-text: func [text][
		sz: size-text/with
	]
	node-cnt: 0
	default-knee: 10
	line-width: pen: none
	points: [center top bottom left right top-left top-right bottom-left bottom-right]
	
	extend system/view/VID/styles [
		diagram: [
			template: [
				type: 'panel
				actors: [
					on-create: func [][
						;probe "dia-cr1" 
						node-cnt: 0
					]
					on-created: func [face event /local line-width pen mx pane][
						; Move connect-lines behind nodes
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
						
						case/all [
							; Adjust size
							not face/options/size [
								mx: 0x0 mv: false
								
								foreach-face/with face [
									parse face/draw [some [
										pair! s: (mx: max mx face/offset + s/-1) 
									| 	'shape into [any [
											'move set shp pair! (if mv: not mv [mx: max mx shp]) 
										| 	'hline set hl integer! (mx: max mx (shp: shp + as-pair hl 0)) 
										| 	'vline set vl integer! (mx: max mx (shp: shp + as-pair 0 vl)) 
										|	'arc set ac pair! (mx: max mx shp: shp + ac)
										| 	skip
										]] 
									| 	skip
									]]
								][
									any [
										face/options/style = 'connect
										face/options/parent-style = 'connect
										face/options/style = 'node
										face/options/parent-style = 'node
									]
								]
								foreach-face/with face [face/size: mx + 20][
									any [
										face/options/style = 'connect
										face/options/parent-style = 'connect
									]
								]
								face/size: mx + 15
							]
							
							; Make caption
							face/text [
								insert find face/parent/pane face make face! [
									type: 'text 
									color: face/color - 16
									text: copy face/text 
									offset: face/offset
									size: as-pair face/size/x 30 
									font: either face/font [copy face/font][make font! [style: 'italic size: 14]]
									para: either face/para [copy face/para][make para! [align: 'center]]
								]
								face/offset/y: face/offset/y + 30
								face/text: face/para: none
								face/parent/size/y: face/parent/size/y + 30
							]
							
							; Draw border
							border: face/options/border [
								switch type?/word border [
									integer! [line-width: border]
									word! tuple! [pen: border]
									block! [reduce bind border :on-created]
								]
								face/draw: compose [pen black line-width 1 box 0x0 (face/size - 1)]
								if line-width [face/draw/line-width: line-width]
								if pen [face/draw/pen: pen]
							]
						]
					]
				]
			]
			init: [
				if all [face/options face/options/size][face/size: face/options/size]
			]
		]
		node: [
			template: [
				type: 'base
				color: none
				size: 80x50;35
				actors: [
					text-pos: function [face][
						sz: size-text face
						pos: (face/size / 2) - (sz / 2) 
						change skip tail face/draw -2 reduce [pos face/text]
					]
					on-create: func [face][
						node-cnt: node-cnt + 1			; Enumerate nodes for easy referencing
						set to-word rejoin ["node" node-cnt] face
					]
					on-created: function [face event][
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
			init: [
				unless face/options [face/options: make block! 10]		; For easy finding
				if face/options/style <> 'node [
					append face/options copy [parent-style: 'node]
				]
				
				draw: compose [
					fill-pen white pen black line-width 1 
					box 0x0 (face/size - 1) (default-knee) text (face/size / 2) ""
				]

				
				; Transfer some attributes to draw
				case/all [
					face/color [change find/tail draw 'fill-pen face/color face/color: none]
					face/font [insert find draw 'text reduce ['font face/font]]
				]
				
				; Adjust shape
				either all [
					face/options/shape 
					not empty? intersect face/options/shape [box ellipse diamond]
				][
					shape: at draw 7
					remove/part shape switch shape/1 [
						box [4] ellipse [3] diamond [5]
					]
					case [
						found: find/tail face/options/shape 'box [
							shape: insert shape [box 0x0]
							if pair? found/1 [face/size: found/1]
							shape: insert shape face/size - 1
							insert shape either found: find/part found integer! 2 [found/1][default-knee]
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
					change find/tail draw [box 0x0] face/size - 1
				]
				
				; Format border
				line-width: pen: none
				if border: face/options/border [
					switch type?/word border [
						integer! [line-width: border]
						word! tuple! [pen: border]
						block! [line-width: border/line-width pen: border/pen]
					]
					if line-width [
						face/size: face/size + line-width 
						draw/line-width: line-width
						if find [box ellipse] draw/7 [draw/8: to-pair line-width / 2]
					]
					if pen [draw/pen: pen]
				]
				
				; Format link
				if link: face/options/link [
					either find draw 'font [
						either style: draw/font/style [
							if word? style [style: to-block style]
							draw/font/style: union style [underline]
						][
							draw/font/style: [underline]
						]
					][
						insert find draw 'text reduce [
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
				face/draw: draw
			]
		]
		connect: [
			template: [
				type: 'base
				color: transparent
				actors: [
					on-created: function [face event /local path ofs start-set? end-set?][
						if face/options/style <> 'connect [			; For easy finding
							append face/options [parent-style: 'connect]
						]
						
						face/size: face/parent/size
						
						; Get starting node
						unless all [
							face/data
							from: face/data/from 
							start: all [
								block? from 
								from-node: find from get-word! 
								get to-word from-node/1
							]
						][
							pane: find face/parent/pane face
							until [
								pane: back pane 
								any [
									find [node note] pane/1/options/style
									find [node note] pane/1/options/parent-style
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
								to-node: find to get-word! 
								get to-word to-node/1
							]
						][
							pane: find face/parent/pane face
							until [
								pane: next pane 
								any [
									find [node note] pane/1/options/style
									find [node note] pane/1/options/parent-style
								]
							]
							end: first pane
						]
						
						; Infer direction
						dir: pick [vertical horizontal] make logic! face/parent/options/vertical
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
						start-pos: start/offset + (start/size / 2)
						end-pos: end/offset + (end/size / 2)
						
						; Start-point
						half: start/size / 2
						if from [
							ofs: either ofs: find from pair! [ofs/1][0x0]
							unless empty? start-point: intersect from points [
								start-set?: yes
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
						]
						unless start-set? [
							either vertical? [
								start-pos/y: start-pos/y + half/y
							][
								start-pos/x: start-pos/x + half/x
							]
						]
						if ofs [start-pos: start-pos + ofs] ofs: none
						; End-point
						half: end/size / 2
						if to [
							ofs: either ofs: find to pair! [ofs/1][0x0]
							unless empty? end-point: intersect to points [
								end-set?: yes
								switch first end-point [
									top [end-pos/y: end-pos/y - half/y]
									bottom [end-pos/y: end-pos/y + half/y]
									left [end-pos/x: end-pos/x - half/x]
									right [end-pos/x: end-pos/x + half/x]
									top-left [end-pos: end/offset]
									top-right [end-pos: 1x-1 * half + end-pos]
									bottom-left [end-pos: -1x1 * half + end-pos]
									bottom-right [end-pos: half + end-pos]
									;center []
								]
							]
						]
						unless end-set? [
							either vertical? [
								end-pos/y: end-pos/y - half/y
							][
								end-pos/x: end-pos/x - half/x
							]
						]
						if ofs [end-pos: end-pos + ofs]

						distance: end-pos - start-pos
						df: as-pair either 0 = distance/x [0][distance/x / absolute distance/x] ; Sector (avoid division by 0)
									either 0 = distance/y [0][distance/y / absolute distance/y] ; e.g. 1x0, 1x-1
						diff: distance - (df * start/size / 2) - (df * end/size / 2)			; Distance between corners
						
						; Prepare draw-block
						draw: [pen black line-width 1 shape []]
						case/all [
							pen: face/options/pen [draw/pen: pen]
							line-width: face/options/line-width [draw/line-width: line-width]
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
								line spline [
									change/part find draw 'shape compose [
										(first shape) (start-pos) (next shape) (end-pos)
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
								;shape [
								;	pre: compose [move (start-pos) move (start-pos)]
								;	insert at pre 3 shape/2
								;	insert draw/shape pre
								;]
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
							either vertical? [
								insert at draw/shape 3 snakeline/vertical lines 10
							][
								insert at draw/shape 3 snakeline lines 10
							]
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
							arrow: face/options/arrow [
								case [
									block? arrow [; TBD
										if end: arrow/end []
										if start: arrow/start []
									]
									pair? arrow [; Unfinished
										arrow-shape: compose [
											move (pos - arrow) 
											'line (arrow) (as-pair 0 - arrow/x arrow/y)
											move (pos - arrow)
										]
									]
									true [
										arrow-shape: [
											rotate (ang) (pos) 
											shape [
												move (pos - 10x5) 
												'line 10x5 -10x5 
												move (pos - 10x5)
											]
										]
										if arrow = 'closed [
											take/last/part arrow-shape/shape 2
											insert arrow-shape [fill-pen white]
											;probe shape
										]
										;probe shape-end
									]
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
									line [
										last-points: skip tail draw -2
										diff: last-points/2 - last-points/1
										ang: to-integer arctangent2 diff/y diff/x
										pos: end-pos
									]
								]
								append draw compose/deep arrow-shape
							]
						]
						face/draw: copy/deep draw
					]
				]
			]
			init: [at-offset: 0x0]
		]
	]
]
context [
	default-space: 40x40
	s: s2: d: d2: data: opts: clr: none
	node-styles: copy ['node]
	connect-styles: copy ['connect]
	position: [
		1 2 [pair! | 'center | 'top | 'bottom | 'left | 'right
		| 'top-left | 'top-right | 'bottom-left | 'bottom-right
		]
	]
	
	diagram-rule: [s: (opts: make block! 6) 
		some [d: 
			[ 'border [
				  integer! | block! | tuple! 
				| set clr word! if (tuple? attempt [get clr])
				] 
			| 'size skip
			] (
			  append opts copy/part d 2
			)
		|	[ 'vertical | 'horizontal | 'border] (
			  append opts append copy/part d 1 true
			) 
		] s2: (
			s: change/part s compose/only [options (opts)] s2
		) :s
	]
	connect-rule: [s: 
		opt [if (all [set-word? s/-2 'style = s/-3]) (
			append connect-styles compose [| (to-lit-word s/-2)]
		)]
		opt [s: (opts: make block! 10 data: make block! 10)
			some [d:
			  ['to | 'from] d3: 1 3 [position | get-word!] d2: (
				append data append/only copy/part d 1 copy/part d3 d2
			  )
			| 'hint skip (append data copy/part d 2)
			| [ ['pen | 'line-width] skip ;| 'end | 'start] skip ;TBD
			  | 'arrow ['closed]; TBD | pair! | block!]
			  ] d2: (append opts copy/part d d2)
			| [ ['line | 'spline ] any pair! 
			  | 'arc opt 'sweep
			  | 'curve opt [2 pair!]
			  | 'qcurve opt pair!
			  ;| shape block!
			  ] d2: (
				append opts append/only copy [shape] copy/part d d2
			  )
			| ['arrow | 'dashed | 'double] (
				append opts append copy/part d 1 true
			  ) 
			] s2: (
				remove/part s s2
				unless empty? data [s: insert s compose/only [data (data)]]
				unless empty? opts [s: insert s compose/only [options (opts)]]
			) :s
			;if (not empty? opts) insert (compose/only [options (opts)]) 
		]
	]
	node-rule: [s: (opts: make block! 10)
		opt [if (all [set-word? s/-2 'style = s/-3]) (
			append node-styles compose [| (to-lit-word s/-2)]
		)]
		some [d:
			[
			  'box opt pair! opt integer! 
			| 'diamond opt pair! 
			| 'ellipse opt pair! 
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
	set 'dia func [blk /local in-dia?][
		node-cnt: 0
		clear next connect-styles
		clear next node-styles
		parse blk rule: [
			some [
				  'diagram (in-dia?: yes) diagram-rule
				| node-styles node-rule
				| connect-styles connect-rule
				| ahead block! into rule
				| skip
			]
		] 
		blk
	]
]
; Examples
comment {
view probe dia [
	;style dbl: connect extra [double]
	below
	diagram vertical beige "Diagram example" [ ;border [line-width: 3 pen: brick]  ;310x280
		style closed-arrow: connect arrow closed from bottom to top;default 'connect 
		space 40x40 
		pad 60x0 
		n1: node ellipse water font [color: white style: [bold italic] size: 12] "One" 
		closed-arrow from bottom-left 10x-10 to top
		return n2: node "Two" 
		closed-arrow from bottom-right -10x-10 :n1 to top ;connect from n1 arrow closed
		n3: node diamond 60x50 "Three" 
		closed-arrow;connect double 
		return pad 75x0 node box 50x30 "Four" 
		closed-arrow from :n3 to top;connect from n3 double line-width 2 
		docs: node link https://www.red-lang.org/p/documentation.html "Red docs" 
		closed-arrow from left to bottom :docs hint [horizontal -20 50]
		connect from right to bottom hint horizontal line-width 2 pen brick arrow; ; 45 -150 -100 50 -70
		return pad 250x-250 node ellipse 40x40 
			border [line-width: 5 pen: gold] 
			link https://www.red-lang.org
			font-color red 
			"Red"
	]
	pad 0x60
	diagram border "Problem workout" linen [;size 330x170 
		style step: node border gray font-color black 
		style chk: node diamond border gray font-color black 
		style note: node box 60x60 0 ;border silver ;font [color: gray name: "Times New Roman"]
		space 30x20
		origin 40x10 
		think: step {Think about^/the problem}
		connect line line-width 3 pen gray arrow ;from right to left
		below pad -2x-2 step border [line-width 4 pen brick] "Experiment"
		connect line hint vertical line-width 3 pen gray arrow from bottom to top; [vertical 40]
		pad 2x2 across clr: chk "Clear?" 
		connect from bottom to left -3x0 :think hint [vertical 20 -170] line-width 3 pen red arrow
		connect line line-width 3 pen leaf arrow from left to right
		pad -220x0 step "Implement"
		connect line 230x70 from top 20x10 :clr ;spline 
		at 250x40 note box 60x60 0 rt [i "Some " /i u "remarks" /u b " here" /b] yello ;"Some^/remarks^/here";
	]
]
}
