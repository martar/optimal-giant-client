importScripts './solver.js'

solver = {}
solver.Skier = Skier

class Punishment
	punishFuntion = (angle) =>
		# angle between 0 and 180 degrees
		if angle <= 90
			return 0.01
		else
			1-Math.pow((angle/180.0)-1.5,6)
			
	punishFuntion2 = (angle) =>
		# angle between 0 and 180 degrees
		if angle <= 90
			return 0.01
		else
			2*(angle/180)-1			
			
	this.computePunishFactor = (positions) =>
		i= 0
		punishFactors = []
		angles = []
		punishFactors.push 1
		while i < positions.length - 2
			a = positions[i]
			b = positions[i+1]
			c = positions[i+2]
			abx = b.x - a.x
			aby = b.y - a.y
			cbx = b.x - c.x
			cby = b.y - c.y
			angba = Math.atan2(aby, abx)
			angbc = Math.atan2(cby, cbx)
			rslt = angba - angbc
			angle = (rslt * 180) / Math.pi
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
	
	this.computePunishment = (positions) =>
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

		
	this.computeSegmentPunishFactor = (positions) =>
		COS_M = 0.98
		i = 0
		# compute the second derivative
		punish = []
		while (i < positions.length-2)

			cos_s1_s2 = Punishment.findCos(positions, i)
			if cos_s1_s2 >= COS_M
				m = 1
			else if cos_s1_s2 > 0
				m = Math.pow(cos_s1_s2,4)  #(cos do potegi 4.)
			else # -1 <=  cos a <= 1
				m = 0.0001
			if m < 0.0001
				m = 0.0001
			punish.push m
			i+=1
		punish.push 1
		punish.push 1
		return punish

	this.findCos = (positions, i) =>
		C = [x3,y3] = [positions[i+2].x,positions[i+2].y]
		B = [x2,y2] = [positions[i+1].x,positions[i+1].y]
		[x1,y1] = [positions[i].x,positions[i].y]
		A = [2*x2 - x1, 2*y2 - y1]
		
		a = Utils.vectorDistance(B,C)
		b = Utils.vectorDistance(B,A)
		c = Utils.vectorDistance(A,C)
		
		return (Math.pow(c,2) - Math.pow(a,2) - Math.pow(b,2))/(-2*a*b)
			
		
	# number of gates besides START ans META
	computeRedundantEdgeChangePunish = (numberOfEdgeChange, numberOfGates) =>
		numberOfRightChanges = numberOfGates - 1
		numberOfRedundanChanges = numberOfEdgeChange - numberOfRightChanges
		if numberOfRedundanChanges < 0
			throw "Number of redundant gates wrong!"
		redundantChangePunish = 2 # seconds
		numberOfRedundanChanges * redundantChangePunish
	
	this.mySumPunishment = (skier, points) =>
		for nextPos, index in points
			skier.moveStraightToPoint(1, [nextPos.x,nextPos.y], 0.001)
		result = Punishment.computePunishment(skier.positions)
		factor = result.sum
		fitness = factor*skier.result
		return fitness
	
	this.mySumPunishmentWithEgdeChangePunish = (skier, points) =>
		for nextPos, index in points
			skier.moveStraightToPoint(1, [nextPos.x,nextPos.y], 0.001)
		result = Punishment.computePunishment(skier.positions)
		factor = result.sum
		# FIXME fixed 5 
		fitness = factor*(skier.result + computeRedundantEdgeChangePunish(result.numberOfEdgeChange, 5))
		return fitness
		
	this.decreaseVelocityPunishment = (skier, pts, a=0) =>
		if not pts[0].x
			points = (new Point(p[0],p[1]) for p in pts)
		else 
			points = pts
		result = Punishment.computePunishFactor([{x:0, y:0}].concat points)
		punishFactors = result.punishFactors
		for nextPos, index in points
			if nextPos.x
				pos = [nextPos.x,nextPos.y]
			else
				pos = nextPos
			skier.moveStraightToPoint(punishFactors[index], pos, 0.1)
		fitness = skier.result
		return fitness
		
	this.decreaseVelocityPunishmentWithEgdeChangePunis = (skier, points) =>
		result = Punishment.computePunishFactor([{x:0, y:0}].concat points)
		punishFactors = result.punishFactors
		for nextPos, index in points
			skier.moveStraightToPoint(punishFactors[index], [nextPos.x,nextPos.y], 0.1)
		fitness = skier.result + computeRedundantEdgeChangePunish(result.numberOfEdgeChange, 5)
		return fitness

	this.segmentVelocityCorrection = (skier,pts) =>
		if not pts[0].x
			points = (new Point(p[0],p[1]) for p in pts)
		else 
			points = pts
		punishFactors = Punishment.computeSegmentPunishFactor([{x:0, y:0}].concat points)
		for nextPos, index in points
			skier.moveStraightToPoint(punishFactors[index], [nextPos.x,nextPos.y], 0.1)
		return skier.result

		
@Punishment = Punishment