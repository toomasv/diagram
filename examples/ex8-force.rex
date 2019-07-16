Red [Description: {Force}]
context [
	o: o2: b1: none
	view dia [diagram force rate 10 [
		size 500x500 
		at 410x10 button "Randomize" [diagram-ctx/randomize face/parent]
		style o: node ellipse 14x14 red loose  
		style o2: node ellipse 4x4
		b1: o "1" 
		connect blank from [center :b1] to [center each [15 o2]]
		connect blank from [center :b1] to [center each [40 o2]] force [radius 100]
	]]
]