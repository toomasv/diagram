Red [Description: {diagram-style examples}]
view/flags [
	on-resizing [code/size: face/size - 20x57]
	drop-list data read %. on-change [
		code/text: read probe to-file pick face/data face/selected
		show code
	]
	button "Run" [do %../diagram-style.red do code/text] 
	return code: area 600x700
] 'resize