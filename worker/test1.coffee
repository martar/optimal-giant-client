solver = require './solver.js'
evol = require './evolutionAlgorithm.js'
opti = require './optimizePoints.js'

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
		angles.push angle
		i += 1
	i=0
	# we want to know how many times the skier had to change the edges,
	# we will use it tu munish him more!
	numberOfEdgeChange = 0
	while (i < angles.length-1)
		# if the signs of the neighbour steps are diffrent, punish the next step by some factor (because it takes more time to change the edges that to simply sline in the same turn
		
		if ((180-angles[i+1])*(180-angles[i])<0)
			numberOfEdgeChange += 1
		i+=1
			
	for angle in angles
		if angle > 180
			angle = 360 - angle
		punishFactors.push punishFuntion(angle)
		
	punishFactors.push 1
	{ punishFactors: punishFactors, numberOfEdgeChange: numberOfEdgeChange}
	
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
		# console.log diff
		i = 0
		punish = []
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
		# console.log "ABS AND x^3"
		# console.log diff
		sum = diff.reduce (t, s) -> t + s
		{ sum: sum, numberOfEdgeChange: numberOfEdgeChange}


accuracy = 0.01
# because we model just one turn here
numberOfGates = 2
# równe odleglosci miedzy drugimi wspolzednymi
pointsA = [[12,8], [16,16], [12,24], [0,32]]
pointsB = [[8,8], [15.99,16],  [8,24], [0,32]]
pointsC = [[4,8], [16,16], [15,24],[0,32]]

# number of gates besides START ans META
computeRedundantEdgeChangePunish = (numberOfEdgeChange, numberOfGates) =>
	numberOfRightChanges = numberOfGates - 1
	numberOfRedundanChanges = numberOfEdgeChange - numberOfRightChanges
	if numberOfRedundanChanges < 0
		throw "Number of redundant gates wrong!"
	redundantChangePunish = 2 # seconds
	numberOfRedundanChanges * redundantChangePunish

runSkierSumPunish = (skier, points, numberOfGates) =>
	for nextPos, index in points
		skier.moveStraightToPoint(1, nextPos, accuracy)
	# using skier.positions after computation fo the starting point is set
	result = computePunishment(skier.positions.reverse())
	skier.sumFactor = result.sum
	# FIXME result.numberOfEdgeChange+1 just because thre is a one curve. normaly would be result.numberOfEdgeChange
	skier.edgeChangePunish = computeRedundantEdgeChangePunish(result.numberOfEdgeChange+1, numberOfGates)
	skier

# remember to concet starting point!
runSkierSlowPunish = (skier, points, numberOfGates) =>
	result =  computePunishFactor([[0,0]].concat points)
	punishFactors = result.punishFactors
	for nextPos, index in points
		skier.moveStraightToPoint(punishFactors[index], nextPos, accuracy)
	# FIXME result.numberOfEdgeChange+1 just because thre is a one curve. normaly would be result.numberOfEdgeChange
	skier.edgeChangePunish = computeRedundantEdgeChangePunish(result.numberOfEdgeChange+1, numberOfGates)
	skier

skierA = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0.001])
skierB = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0.001])
skierC = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0.001])

console.log "_________________________"
console.log "Positions A:"
console.log pointsA
skierA = runSkierSumPunish(skierA, pointsA,numberOfGates)
console.log "Sum punish factor: " + skierA.sumFactor
console.log "Pure result(no punish): " + skierA.result
console.log "Pure result WITH REDIUNDANT EDGE CHANGE PUNISH: " + (skierA.result + skierA.edgeChangePunish)
skierA = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0.001])
skierA = runSkierSlowPunish(skierA, pointsA, numberOfGates)
console.log "Slowing punish result: " + skierA.result
console.log "Slowing punish result WITH REDIUNDANT EDGE CHANGE PUNISH: " + (skierA.result + skierA.edgeChangePunish)
console.log "_________________________"
console.log "Positions B:"
console.log pointsB
skierB = runSkierSumPunish(skierB, pointsB, numberOfGates)
console.log "Sum punish factor: " + skierB.sumFactor
console.log "Pure result(no punish): " + skierB.result
console.log "Result WITH REDIUNDANT EDGE CHANGE PUNISH: " + (skierB.result + skierB.edgeChangePunish)
skierB = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0.001])
skierB = runSkierSlowPunish(skierB, pointsB, numberOfGates)
console.log "Slowing punish result: " + skierB.result
console.log "Slowing punish result WITH REDIUNDANT EDGE CHANGE PUNISH: " + (skierB.result + skierB.edgeChangePunish)
console.log "_________________________"
console.log "Positions C:"
console.log pointsC
skierC = runSkierSumPunish(skierC, pointsC, numberOfGates)
console.log "Sum punish factor: " + skierC.sumFactor
console.log "Pure result(no punish): " + skierC.result
console.log "Result WITH REDIUNDANT EDGE CHANGE PUNISH: " + (skierC.result + skierC.edgeChangePunish)
skierC = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0.001])
skierC = runSkierSlowPunish(skierC, pointsC, numberOfGates)
console.log "Slowing punish result: " + skierC.result
console.log "Slowing punish result WITH REDIUNDANT EDGE CHANGE PUNISH: " + (skierC.result + skierC.edgeChangePunish)

###
punishFactors = computePunishFactor(points)
for nextPos, index in points
	skier.moveStraightToPoint(punishFactors[index], nextPos, accuracy)
###