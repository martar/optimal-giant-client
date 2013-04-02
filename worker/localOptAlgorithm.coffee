importScripts './solver.js'
importScripts './statistics.js'

solver = {}
solver.Skier = Skier

class LocalOptimization
	constructor: (@init_skier,@gates,@val,@startPoint=[0,0]) ->
		# without startPoint
		@current_result = @init_skier.positions.reverse()[1..]
		@gatesys = (gate[0][1] for gate in @gates)
		postMessage({result:@current_result, ys:@gates})
		
		
	compute: () ->
		postMessage({start:"start"})
		stepSize = (0.5 for i in [1..@current_result.length])
		acceleration = 1.2
		candidate = [-acceleration, -1/acceleration, 0, 1/acceleration, acceleration]
		epsilon = 0.00001
		before = 100000
		curFitness = @computeFitness()
		
		postMessage({start:"start alg"})
		while before - curFitness > epsilon 
			before = curFitness
			for i in [0..@current_result.length-1]
				if Math.round(@current_result[i][1]) not in @gatesys
					best = -1
					bestScore = 1000000
					for j in [0..4] 	# try each of 5 candidate locations
						@current_result[i][0] += stepSize[i] * candidate[j]
						temp = @computeFitness()
						
						@current_result[i][0] = @current_result[i][0] - stepSize[i] * candidate[j]
						if(temp < bestScore)
							bestScore = temp
							best = j
					if candidate[best]!=0
						@current_result[i][0] += stepSize[i] * candidate[best]
						stepSize[i] *= candidate[best] # accelerate
			postMessage({best:@current_result})
			curFitness = bestScore
		return @init_skier

	# FIXME punishments should be in outer class available to the world - now it is copy-paste!
	computeFitness: () ->
		skier = new solver.Skier(0,null,0,0,null,x0=@startPoint,v0 = Utils.findCoords(@current_result[0],@startPoint,@val))
		for nextPos, index in @current_result
			skier.moveStraightToPoint(1, nextPos, 0.001)
		result = @computePunishment(@current_result)
		factor = result.sum
		# FIXME fixed 5 
		fitness = factor*(skier.result + computeRedundantEdgeChangePunish(result.numberOfEdgeChange, 5))
		return fitness
		
	# number of gates besides START ans META
	computeRedundantEdgeChangePunish = (numberOfEdgeChange, numberOfGates) =>
		numberOfRightChanges = numberOfGates - 1
		numberOfRedundanChanges = numberOfEdgeChange - numberOfRightChanges
		if numberOfRedundanChanges < 0
			throw "Number of redundant gates wrong!"
		redundantChangePunish = 2 # seconds
		numberOfRedundanChanges * redundantChangePunish
	
	
	computePunishment : (positions) =>
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


@LocalOptimization = LocalOptimization
@LocalOptimization = LocalOptimization