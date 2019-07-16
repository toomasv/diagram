Red [Description: {`each`}]
context [
	nod: top: dgr: one: two: three: two-1: two-2: none
	view dia [diagram vertical [
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