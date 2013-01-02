#try

importScripts './underscore.js'
importScripts './solver.js'	
importScripts './evolutionAlgorithm.js'


evol = {}
evol.Individual = Individual
solver = {}
solver.Skier = Skier
###
_ = require('./underscore.js')
solver = require('./solver.js')
evol = require('./evolutionAlgorithm.js')
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
					points.push([Math.random()*(x_range[1]-x_range[0])+x_range[0],cur_y])
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
		else @skier.velocities
		@computeFitness()
	
	computePunishment:(positions) =>
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
		
	computeFitness: () ->
		if @fitness
			return @fitness
		interval = 0.1
		t = 0
		@min = 100000

		for nextPos in @value
			@skier.moveStraightToPoint(nextPos, 0.001)
			
		factor = @computePunishment(@skier.positions)
		#console.log "czas: ", t
		@fitness = factor * @skier.result
		
	createCopy: (changedPoints) ->
		skierPos = @skier.getPositions()
		firstPos = skierPos[skierPos.length-1]
		skierVel = @skier.getVelocities()
		firstVel = skierVel[skierVel.length-1]
		
		new PointsSet(changedPoints, new solver.Skier(0, null, 0, 0, null, x0=[firstPos[0], firstPos[1] ],v0=[firstVel[0],firstVel[1]]))
		
	mutate: (percentValue) ->
		indCount = Math.floor(Math.random()*(@value.length-1))
		
		# deep copy
		newValue = ([i[0],i[1]] for i in @value)
		
		for i in [1..indCount]
			# do not change final gate
			ind = Math.floor(Math.random()*(@value.length-1))
			# if gate chosen find new index
			while(ind in gates_indices)
				ind = Math.floor(Math.random()*(@value.length-1))
		
			# change +- percentValue percent
			newValue[ind][0] = newValue[ind][0] + (Math.random()*percentValue*2 - percentValue)*newValue[ind][0]/100
			
		@createCopy(newValue)
		
	cross: (b) ->
		@createCopy(([(@value[i][0] + b.value[i][0])/2, @value[i][1]] for i in [0..@value.length-1]))

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