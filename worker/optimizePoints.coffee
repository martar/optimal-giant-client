importScripts './underscore.js'
importScripts './solver.js'	
importScripts './evolutionAlgorithm.js'
importScripts './gauss.js'
importScripts './gate.js'
importScripts './punishments.js'

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

class PointTurns
	constructor: (@del_y,@count,@val,@gates,@startPoint=new Point(0,0)) ->
		@idvs = []
		@getInitialPop()
	
	getInitialPop: () ->
		# initial deviation
		for ind_i in [1..@count]
			#postMessage({ind:ind_i, c:@count})
			startPoint = null
			points = []
			cur_y = @del_y
			i = 0
			for gate in @gates
				if startPoint == null
					startPoint = @startPoint
				# set a range for random x's (it can be changed by mutation)
				if startPoint.x > gate.x
					x_range = [gate.x,startPoint.x]
				else
					x_range = [startPoint.x,gate.x]
				
				# randomize x's between gates each del_y
				while cur_y < gate.y
					rand_x = Math.random()*(x_range[1]-x_range[0])+x_range[0]
					points.push(new Point(rand_x,cur_y))					
					cur_y += @del_y
					i+=1
					#postMessage({i:i})
				cur_y = gate.y + @del_y
				# add gate and memorize its index (needed only in first iteration)
				points.push(gate.createCopy())
				startPoint = new Point(gate.x,gate.y)
				i+=1
			# v0 needs to have @val length, direction is not imported now
			skier = new solver.Skier(0,null,0,0,null,x0=[@startPoint.x,@startPoint.y],v0 = [0,@val])
			
			#postMessage({points:points})
			@idvs.push(new PointsSet(points,skier))
		
class PointsSet extends evol.Individual
	constructor: (points,@skier) ->
		@setValue(points)
		
	setValue: (value) ->
		@fitness = null
		@value = value
		if skier?
			pos = @skier.getPositions().reverse()[0]
			@skier.positions = [pos[0],pos[1]]
			vel = @skier.getVelocities().reverse()[0]
			@skier.velocities = [vel[0],vel[1]]
		@computeFitness()
	
	computeFitness: () ->
		if @fitness
			return @fitness
		interval = 0.1
		t = 0
		@min = 100000
		
		@fitness = Punishment.segmentVelocityCorrection(@skier,@value)
		#@decreaseVelocityPunishmentWithEgdeChangePunis()
		#@mySumPunishment()
		#@mySumPunishmentWithEgdeChangePunish()
		
	createCopy: (changedPoints) ->
		skierPos = @skier.getPositions()
		firstPos = skierPos[skierPos.length-1]
		skierVel = @skier.getVelocities()
		firstVel = skierVel[skierVel.length-1]
		
		new PointsSet(changedPoints, new solver.Skier(0, null, 0, 0, null, x0=[firstPos[0], firstPos[1]],v0=[firstVel[0],firstVel[1]]))
	
	'''
	mutate individual
	gaussAll - nrand value used for whole population in one iteration
	tau, tau_prim - parameters of evolutionary algorithm
	'''
	mutate: (gaussAll, tau, tau_prim) ->
		
		# deep copy
		newValue = (i.createCopy() for i in @value)
		
		for point in newValue
			gauss = Math.nrand()
			
			if not (point instanceof Gate)
				# mutate sigma
				point.dev = point.dev * Math.exp(tau_prim*gaussAll + tau*gauss)
				
				gauss = Math.nrand()			
				diff = point.dev*gauss
				old_value = point.x
				point.x += diff
				#c = point.correct()
				#postMessage({p:point.x,old:old_value,c:c,g:point.gate_x,diff:diff})
				
				# if the new value is not correct find another
				while not point.correct()
					gauss = Math.nrand()			
					diff = point.dev*gauss
					point.x = old_value + diff

		#postMessage({inds:inds})
		@createCopy(newValue)
		
	cross: (b) ->
		crossed_points = []
		for i in [0..@value.length-1]
			copy = @value[i].createCopy()
			copy.x = (@value[i].x + b.value[i].x)/2
			copy.dev = (@value[i].dev + b.value[i].dev)/2
			crossed_points.push copy
		@createCopy(crossed_points)

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