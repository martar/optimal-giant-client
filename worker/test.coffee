solver = require './solver.js'
evol = require './evolutionAlgorithm.js'
opti = require './optimizePoints.js'

steep = 0.04
accuracy = 0.1
skier = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])

computePunishment = (positions) =>
		i = 0
		# compute the second derivative
		diff = []
		while (i < positions.length-2)
			[x3,y3] = positions[i+2]
			[x2,y2] = positions[i+1]
			[x1,y1] = positions[i]
			denominator = (y3-y2)*(y2-y1)
			numerator = x1 + x3 - 2*x2
			diff.push numerator/denominator
			i+=1
		# apply the punishment
		i = 0
		punish = []
		punish.push  diff[0]
		magicalFactor = 1.5
		while (i < diff.length-1)
			next = diff[i+1]
			curr = diff[i]
			# if the signs of the neighbour steps are diffrent, punish the next step by some factor (because it takes more time to change the edges that to simply sline in the same turn
			punishment = diff[i+1]
			if (next*curr<0)
				punishment = punishment* magicalFactor
			punish.push punishment
			i+=1
		# it's important to punish more the bigger values of derivatives than sum of smaller values of derivatives,
		# so we take the 
		punish = (Math.abs(item)* item * item for item in punish)
		sum = punish.reduce (t, s) -> t + s
		sum

computePunishFactor = (positions) =>
	console.log "Entering"
	i= 0
	factors = []
	while i < positions.length - 2
		console.log i
		a = positions[i]
		b = positions[i+1]
		c = positions[i+2]
		abx = b[0] - a[0]
		aby = b[1] - a[1]
		cbx = b[0] - c[0]
		cby = b[1] - c[1]
		angba = Math.atan2(aby, abx)
		angbc = Math.atan2(cby, cbx)
		rslt = angba - angbc
		angle = (rslt * 180) / 3.141592
		console.log angle
		if angle > 180
			angle = 360 - angle
		console.log angle
		factors.push 1-Math.pow((angle/180.0)-1.5,6)
		i += 1
	factors
	
points = [[5,13],[0,26],[5,39], [4,44],[5,49], [0,62], [5,75], [6,77], [3,80], [0,93]]

punishFactors = computePunishFactor(points)
for nextPos, index in points
	skier.moveStraightToPoint(1, nextPos, 0.001)
			
console.log "________________________"
console.log punishFactors
console.log "________________________"
console.log computePunishFactor(points)

	