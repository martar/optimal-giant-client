solver = require './solver.js'
evol = require './evolutionAlgorithm.js'
opti = require './optimizePoints.js'

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
		console.log positions
		console.log diff
		i = 0
		punish = []
		magicalFactor = 1.5
		# we want to know how many times the skier had to change the edges,
		# we will use it tu munish him more!
		numberOfEdgeChange = 0
		while (i < diff.length-1)
			# if the signs of the neighbour steps are diffrent, punish the next step by some factor (because it takes more time to change the edges that to simply sline in the same turn
			if (diff[i+1]*diff[i]<0)
				numberOfEdgeChange += 1
			i+=1
		# it's important to punish more the bigger values of derivatives than sum of smaller values of derivatives,
		# so we take the 
		diff = (Math.abs(item)* item * item for item in diff)
		sum = diff.reduce (t, s) -> t + s
		{ sum: sum, numberOfEdgeChange: numberOfEdgeChange}

punishFuntion = (angle) =>
	# angle between 0 and 180 degrees
	if angle <= 90
		return 0.01
	else
		1-Math.pow((angle/180.0)-1.5,6)
		
computePunishFactor =(positions) =>
	i= 0
	punishFactors = []
	angles = []
	punishFactors.push 1
	while i < positions.length - 2
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
		if angle > 180
			angle = 360 - angle
		punishFactors.push punishFuntion(angle)
		i += 1
	punishFactors.push 1
	punishFactors

accuracy = 0.001
skierA = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])
skierA = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])
skierA = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])

pointsA = [[8,4], [12,8], [16,16], [12,24], [8,28], [0,36]]
pointsB = [[4,4], [12,12], [16,16], [20,24], [4,28], [0,36]]
pointsC = [[2,4], [4,8], [16,16], [12,24], [8,28], [0,36]]

punishFactors = computePunishFactor(points)
for nextPos, index in points
	skier.moveStraightToPoint(punishFactors[index], nextPos, accuracy)
	
skier = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])

for nextPos, index in points
	skier.moveStraightToPoint(1, nextPos, accuracy)

console.log computePunishment(skier.positions).numberOfEdgeChange

console.log "________________________"
console.log punishFactors

	