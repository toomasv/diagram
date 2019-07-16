Red [Description: {Array func flowchart}]
context [
	conn: hline: vline: cond1: dia2: cond2: n1: n2: dia3: cond3: cond4: cond5: none
	view dia [
		title "Gregg's array func"
		diagram 620x700 border 1 [
			space 30x30
			style conn: connect arrow [closed 8x3 black]
			style hline: connect arrow [closed 8x3 black] hline 30 label start
			style vline: connect arrow [closed 8x3 black] vline 30 label start
			pad 0x20 node ellipse "Start"
			conn cond1: node diamond "block? size"
			hline "Yes" dia2: diagram width 380 add 0x10 border 1 silver [
				space 30x30
				cond2: node diamond 120x70 {      tail?^/more-sizes:^/   next size}
				hline "Yes" n1: node {more-sizes:^/    none}
				connect arrow [closed 8x3 black] vline 30 label start from [bottom :cond2] "No" n2: node {   size:^/first size}
				connect arrow [closed 8x3 black] from [bottom :n1] hint vertical to [right :n2]
				connect arrow [closed 8x3 black] vline 30 label start from [bottom :n2] node diamond 80x70 {    not^/integer?^/    size}
				connect arrow [closed 8x3 black] hline 30 label start "Yes" node {     cause-error script 'expect-arg^/  reduce ['array 'size type? get/any 'size]}
			]
			origin 10x320
			dia3: diagram width 460 add 0x10 border 1 silver [
				space 30x30 pad 35x0
				at 10x10 text bold "case" 
				cond3: node diamond 100x70 {    block?^/more-sizes^/  }
				hline "Yes" node {  append/only result array/initial more-sizes :value}
				vline from [bottom :cond3] to top "No" cond4: node diamond 100x70 {series?^/:value}
				hline "Yes" node {  loop size [append/only result copy/deep value]}
				vline from [bottom :cond4] to top "No" cond5: node diamond 100x70 {  ^/any-function?^/       :value}
				hline "Yes" node {  loop size [append/only result value]}
				vline from [bottom :cond5] to top "No" node {  append/dup result value size}
			]
			conn hint [vertical 210] from [bottom :cond1] to [top -80x0 :dia3] label start "No" 
			connect from [bottom :dia2] to [top -80x0 :dia3] hint [vertical 20]
			conn from :dia3 hint horizontal to top origin 500x550 node "result"
			vline from bottom to top node ellipse "End"
		]
	]
]