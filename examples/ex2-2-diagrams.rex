Red [Description: {2 diagrams}]
context [
	closed-arrow: n1: color: style: size: n2: n3: docs: line-width: pen: step: chk: note: name: think: clr: none
	view dia [
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