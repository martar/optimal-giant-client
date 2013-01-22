importScripts './underscore.js'
importScripts './solver.js'	
importScripts './evolutionAlgorithm.js'
importScripts './gauss.js'
evol = {}
evol.Individual = Individual
solver = {}
solver.Skier = Skier
###
_ = require('./underscore.js')
solver = require('./solver.js')
evol = require('./evolutionAlgorithm.js')
gauss = require('./gauss.js')
###

findCoords = (value,length) ->
	coor = []
	vProp = Math.tan(value)
	
	coor.push(length/(Math.sqrt(1+vProp*vProp)))
	coor.push(vProp*length/(Math.sqrt(1+vProp*vProp)))
	coor

gates_indices = []

class PointTurns
	constructor: (@del_y,@count,@val,@gates,@startPoint=[0,0]) ->
		@idvs = []
		@getInitialPop()
	
	getInitialPop: () ->
		# initial deviation
		init_dev = 1
		for ind_i in [1..@count]
			
			startPoint = null
			points = []
			cur_y = @del_y
			i = 0
			for gate in @gates
				if startPoint == null
					startPoint = @startPoint
				# set a range for random x's (it can be changed by mutation)
				if startPoint[0] > gate[0]
					x_range = [gate[0],startPoint[0]]
				else
					x_range = [startPoint[0],gate[0]]
				
				# randomize x's between gates each del_y
				while cur_y < gate[1]
					points.push([Math.random()*(x_range[1]-x_range[0])+x_range[0],cur_y,init_dev])
					
					cur_y += @del_y
					i+=1
				cur_y = gate[1] + @del_y
				# add gate and memorize its index (needed only in first iteration) 
				points.push(gate[..])
				if ind_i == 1
					gates_indices.push(i)
				startPoint = gate
				i+=1
			skier = new solver.Skier(0,null,0,0,null,x0=@startPoint,v0 = findCoords(0,@val))
			
			# postMessage({points:points})
			@idvs.push(new PointsSet(points,skier))
		# postMessage({unm:gates_indices})
		
class PointsSet extends evol.Individual
	constructor: (points,@skier) ->
		@setValue(points)
		
	setValue: (value) ->
		@fitness = null
		@value = value
		if skier?
			pos = @skier.getPositions().reverse()[0]
			#console.log pos
			@skier.positions = [pos[0],pos[1]]
			vel = @skier.getVelocities().reverse()[0]
			@skier.velocities = [vel[0],vel[1]]
		@computeFitness()
	
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

	punishFuntion3 = (angle) =>
		# angle between 0 and 180 degrees
		(angle/180)^10		
			
	computePunishFactor :(positions) =>
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
			punishFactors.push punishFuntion3(angle)
			
		punishFactors.push 1
		{ punishFactors: punishFactors, numberOfEdgeChange: numberOfEdgeChange}
	
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

	
	computeFitness: () ->
		if @fitness
			return @fitness
		interval = 0.1
		t = 0
		@min = 100000
		
		#@decreaseVelocityPunishment()
		#@decreaseVelocityPunishmentWithEgdeChangePunis()
		#@mySumPunishment()
		@mySumPunishmentWithEgdeChangePunish()
	
	# number of gates besides START ans META
	computeRedundantEdgeChangePunish = (numberOfEdgeChange, numberOfGates) =>
		numberOfRightChanges = numberOfGates - 1
		numberOfRedundanChanges = numberOfEdgeChange - numberOfRightChanges
		if numberOfRedundanChanges < 0
			throw "Number of redundant gates wrong!"
		redundantChangePunish = 2 # seconds
		numberOfRedundanChanges * redundantChangePunish
	
	mySumPunishment: () ->
		for nextPos, index in @value
			@skier.moveStraightToPoint(1, nextPos, 0.001)
		result = @computePunishment(@value)
		factor = result.sum
		@fitness = factor*@skier.result
	
	mySumPunishmentWithEgdeChangePunish: () ->
		for nextPos, index in @value
			@skier.moveStraightToPoint(1, nextPos, 0.001)
		result = @computePunishment(@value)
		factor = result.sum
		# FIXME fixed 5 
		@fitness = factor*(@skier.result + computeRedundantEdgeChangePunish(result.numberOfEdgeChange, 5))
		
	decreaseVelocityPunishment: () ->
		result = @computePunishFactor([[0,0]].concat @value)
		punishFactors = result.punishFactors
		for nextPos, index in @value
			@skier.moveStraightToPoint(punishFactors[index], nextPos, 0.001)
		@fitness = @skier.result
		
	decreaseVelocityPunishmentWithEgdeChangePunis: () ->
		result = @computePunishFactor([[0,0]].concat @value)
		punishFactors = result.punishFactors
		for nextPos, index in @value
			@skier.moveStraightToPoint(punishFactors[index], nextPos, 0.001)
		@fitness = @skier.result + computeRedundantEdgeChangePunish(result.numberOfEdgeChange, 5)
		
	createCopy: (changedPoints) ->
		skierPos = @skier.getPositions()
		firstPos = skierPos[skierPos.length-1]
		skierVel = @skier.getVelocities()
		firstVel = skierVel[skierVel.length-1]
		
		new PointsSet(changedPoints, new solver.Skier(0, null, 0, 0, null, x0=[firstPos[0], firstPos[1] ],v0=[firstVel[0],firstVel[1]]))
	
	'''
	mutate individual
	gaussAll - nrand value used for whole population in one iteration
	tau, tau_prim - parameters of evolutionary algorithm
	'''
	mutate: (gaussAll, tau, tau_prim) ->
	
		indCount = Math.floor(Math.random()*(@value.length-1))
		
		# deep copy
		newValue = ([i[0],i[1],i[2]] for i in @value)
		
		for i in [1..indCount]
			# do not change final gate
			ind = Math.floor(Math.random()*(@value.length-1))
			# if gate chosen find new index
			while(ind in gates_indices)
				ind = Math.floor(Math.random()*(@value.length-1))
		
			gauss = Math.nrand()
			
			# mutate sigma
			newValue[ind][2] = newValue[ind][2] * Math.exp(tau_prim*gaussAll + tau*gauss)
			
			gauss = Math.nrand()			
			diff = newValue[ind][2]*gauss
			
			newValue[ind][0] += diff
		#postMessage({inds:inds})
		@createCopy(newValue)
		
	cross: (b) ->
		@createCopy(([(@value[i][0] + b.value[i][0])/2, @value[i][1], (@value[i][2]+b.value[i][2])/2] for i in [0..@value.length-1]))

@PointTurns = PointTurns

"""
pop = new PointTurns(1,20,1,[10,10])
#console.log "nowa populacja:"
for i in pop.idvs.reverse()
	console.log i.fitness
	#for a in i.value
	#console.log a

#console.log ({fitness: i.fitness,points: ([a[0],a[1]] for a in i.value)} for i in pop.idvs.reverse())


b = new evol.Optimization(pop,20,5).compute()
console.log (i.fitness for i in pop.idvs.reverse())
console.log b
"""