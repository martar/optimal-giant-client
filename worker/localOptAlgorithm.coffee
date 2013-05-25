importScripts './solver.js'
importScripts './statistics.js'
importScripts './punishments.js'

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
		skier = new solver.Skier(0,null,0,0,null,x0=@startPoint,v0 = Utils.findCoords(@current_result[0],@startPoint,@val))
		postMessage {skier:skier.positions}
		curFitness = Punishment.segmentVelocityCorrection(skier,@current_result,1)
		
		postMessage({start:"start alg"})
		while before - curFitness > epsilon 
			before = curFitness
			for i in [0..@current_result.length-1]
				if Math.round(@current_result[i][1]) not in @gatesys
					best = -1
					bestScore = 1000000
					for j in [0..4] 	# try each of 5 candidate locations
						@current_result[i][0] += stepSize[i] * candidate[j]
						skier = new solver.Skier(0,null,0,0,null,x0=@startPoint,v0 = Utils.findCoords(@current_result[0],@startPoint,@val))
						temp = Punishment.segmentVelocityCorrection(skier,@current_result)
						
						@current_result[i][0] = @current_result[i][0] - stepSize[i] * candidate[j]
						if(temp < bestScore)
							bestScore = temp
							best = j
							@init_skier.result = skier.result
					if candidate[best]!=0
						@current_result[i][0] += stepSize[i] * candidate[best]
						stepSize[i] *= candidate[best] # accelerate
			postMessage({best:@current_result})
			curFitness = bestScore
		return @init_skier

@LocalOptimization = LocalOptimization