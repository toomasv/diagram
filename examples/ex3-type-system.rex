Red [Description: {Type system, wheel, navigate}]
context [
	lay: type-box: pen: axis: conn: hlin: type: di: none
	char: handle: int: float: time: date: pair: tuple: word: native: string: block: path: none
	view/tight/no-wait lay: layout dia [
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
		]
	]
]