Red []
;context [
	#include %../diagram-style.red
	blk: dia [
		style tx: node box 80x30 border [line-width 3 pen gray] 
		style cn: connect forward pen gray line-width 3 
		space 30x20 
	]
	start-symbol: [box 30x30 draw [pen gray line-width 3 circle 15x15 13]]
	end-symbol: [box 30x30 draw [pen gray line-width 3 circle 15x15 13]]
	out: tail blk
	alt: no
	set 'railroad func [code [block!]][
		collect/into [
			keep to-set-word 'alt0
			keep start-symbol
			keep parse code rule: [
				collect any [s: 
					'| (alt: yes) keep ('return)
				|	'opt rule keep ('cn)
				|	any-type! keep ('cn) 
					opt if (alt) [keep ('from) keep (to-get-word 'alt0)]
					keep ('tx) keep (mold s/1)
				]
			]
			keep 'cn
			keep end-symbol
		] clear out
		view dia blk
	]
;]