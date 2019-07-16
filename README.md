# diagram
Diagram dialect, extends VID

**Warning!** It's under development, bugs expected, breaking changes may appear in new versions.

## RedBNF

	diagram: [['diagram | diagram-style] any diagram-settings any panel-settings diagram-block]
	diagram-settings: [direction | size-spec | border-spec | funcs]
	direction: ['vertical | 'horizontal] 			; General direction for connector, default is `horizontal`
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
	box-shape: ['box opt pair! opt integer!] 		; pair! is size, integer! is corner radius
	ellipse-shape: ['ellipse pair!] 			; pair! is size
	diamond-shape: ['diamond pair!] 			; pair! is size
	border-spec: ['border [integer! | word! | tuple! | border-block]] ; integer! is line-width, [word! | tuple!] is color
	border-block: [
	  'line-width integer! 'pen [word! | tuple!] 
	| 'pen [word! | tuple!] 'line-width integer!
	]
	link-spec: ['link url!]
	rt-spec: ['rt rtd-layout-block] 			; if this is given normal text should not be set
	
	connect-spec: [['connect | connect-style] any connect-settings any base-settings]
	connect-settings: [from-attr | to-attr | hint-attr | label-attr | format-attr | move-attr | force-attr]
	from-attr: ['from 1 3 [point-name | point-offset | :node-ref]]
	to-attr: ['to 1 3 [point-name | point-offset | :node-ref | 'each opt block!]] ; `each` for several targets 
								; inside a panel or another `diagram` (examples 7)
								; or in provided block (example 8)
	point-name: ['top | 'bottom | 'left | 'right | 'top-left | 'top-right | 'bottom-right | 'bottom-right | 'center]
								; by default (i.e. horizontal direction) -- from `right` to `left`
								; default for vertical direction -- from `bottom` to `top`
	point-offset: pair! 					; additional offset from named point
	hint-attr: ['hint [direction | path-step | hint-spec]]
	direction: ['vertical | 'horizontal]
	path-step: integer!   					; length of first leg
	hint-spec: [some [opt direction any path-step]]
	label-attr: ['label [label-spec | label-block]]
	label-spec: [pos-word | align | valign | position | angle | color-spec]
	pos-word: ['start | 'end | 'mid]
	align: ['left | 'right | 'center]
	valign: ['top | 'bottom | 'middle]
	position: [pair! | percent!] 				; offset from start of line or leg
	angle: ['align | integer!]				; `align` tries to guess the angle of line, integer! sets the angle
	label-block: [any [label-spec | 'leg integer!]]		; `leg` sets position at given int leg of segmnted connector
	format-attr: [shape-spec | line-format | arrow-spec]
	shape-spec: [line-spec | rel-line-spec | rel-spline-spec | ortho-line-spec | arc-spec | curve-spec | qcurve-spec]
	line-spec: [['line | 'spline] any pair!] 		; intermediate points only - start- and end-points are automatically given
	rel-line-spec: [quote 'line any ['_ | pair!]] 		; `_` - automatically computed legs, 
								; pair!s are relative, start/end-points are automatic
	rel-spline-spec: [quote 'spline any [pair! | '_]] 	; as above, pair!s are control-points
	ortho-line-spec: [['hline | 'vline] integer!] 		; relocates to-node to the endpoint of ortho-line
	arc-spec: ['arc opt 'sweep] 				; if `sweep` is present, arc is drawn clockwise, otherwise counterclockwise
	curve-spec: ['curve opt [2 pair!]] 			; cubic bezier curve - pair!-s are control-points
	qcurve-spec: ['qcurve opt pair!] 			; quadratic bezier curve - pair! is control-point
	line-format: ['line-width integer! | 'pen [color-word | tuple] | ['line-join | 'line-cap] word! | 'dashed | 'double] 
								; `dashed` is experimental, does not produce good result now 
	arrow-spec ['arrow opt ['closed | integer! | pair! | arrow-block]] ; TBD add `shape` for custom shape
	arrow-block: [any [integer! | pair! | 'closed]] 	; integer for optional angle, pair! for dimensions (x--length , y--half-width)
	move-attr: [opt 'forward]				; `forward` moves connectors before the targeted panel/node (useful e.g. with `each`)
	force-attr: [some [
		'radius integer! 				; distance from node to connected nodes (in pixels)
	  |	['attract | 'repulse] [integer! | float!] 	; attractive and repulsive forces coeficients (~ 0.1 - 5)
	  |	'coef integer!					; another coeficient for repulsive force (currently 10000 or 1000)
	]]

## Examples
To try examples open `examples/examples.red`, select example and "Run" it.
