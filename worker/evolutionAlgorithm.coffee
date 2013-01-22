
importScripts './underscore.js'
importScripts './solver.js'
importScripts './statistics.js'
importScripts './gauss.js'
###
_ = require('./underscore.js')
require('./solver.js')
require('./gauss.js')
require('./statistics.js')
###

K = 1
tau = (n) -> K/(Math.sqrt(2*n))
tau_prim = (n) -> K/(Math.sqrt(2*Math.sqrt(n)))

class Turns	
	constructor: (count,val,endPoint) ->
		propEnd = endPoint[1]/endPoint[0]
		x = Math.atan(propEnd)
		@idvs = (new Turn(val,Math.random()* (Math.PI/2 - Math.abs(x)) + Math.abs(x),endPoint) for i in [1..count])
		
class Individual
	constructor: (value) ->
		@setValue(value)
		
	setValue: (value)->
		@value = value
		# compute fitness
		@computeFitness()
		
	createCopy: (changedValue) ->
		new Individual(changedValue)
		
	computeFitness: () ->
		@fitness = Math.sin(@value)
	
	'''
	Create new individual which value varies +- percentValue% of value
	'''
	mutate: (percentValue) ->
		
		newValue = @value + (Math.random()*percentValue*2 - percentValue)*@value/100
		@createCopy(newValue)

	'''
	Cross this ind with ind b
	The new Individual has the average value of these two.
	'''
	cross: (b) ->
		@createCopy((@value + b.value)/2)

	
class Turn extends Individual
	constructor: (@length, alpha, @endPoint, @startPoint=[0,0]) ->
		@setValue(alpha)
		
	setValue: (value) ->
		@fitness = null
		@value = value
		@skier = new Skier(null, null, null, null, null, x0=@startPoint,v0=@findCoords())
		@computeFitness()
	
	computeFitness: () ->
		throw "THIS CODE SHOULD NOT BE USED"
		if @fitness
			return @fitness
		interval = 0.0001
		t = 0
		@min = 100000
		kappa = @computeKappa()

		curPos = @startPoint
		while ( !@isNear(curPos))
			@skier.move(t,t+interval,kappa,1)
			
			t+=interval
			
			curPos = @skier.getPositions()[0]
		#console.log "czas: ", t
		t-=interval
		@fitness = t
		
	'''
	Check if we are in the closest point to the endPoint
	It is the condition to stop simulation
	'''
	isNear: (x) ->
		
		rKw = Math.pow(x[0] - @endPoint[0], 2) + Math.pow(x[1] - @endPoint[1], 2) 
		
		if rKw < @min
			@min = rKw
			return false
		return true
		
	createCopy: (changedValue) ->
		new Turn(@length, changedValue, @endPoint)
	
	'''
	Compute new kappa basing on set points and velocity vector
	'''
	computeKappa: () ->
		[x1,y1] = @startPoint
		[x2,y2] = @endPoint
		[vx,vy] = @findCoords()
		
		x = (Math.pow((y2-y1),2)*vy - 2*vx*x1*(y2-y1) + (Math.pow(x2,2) - Math.pow(x1,2))*vy)/(2*(-vx*(y2-y1) + vy*(x2-x1)))
		y = (-vx*(Math.pow((y2-y1),2) + (Math.pow(x2,2) - Math.pow(x1,2))))/(2*(-vx*(y2-y1) + vy*(x2-x1))) + y1
		
		kappa = 1 / (Math.sqrt(Math.pow((x1-x),2)+Math.pow((y1-y),2)))
		kappa
	
	'''
	finds the coordinates from the length of the vector and 
	tan angle of inclination of the velocity vector
	'''
	findCoords: () ->
		coor = []
		vProp = Math.tan(@value)
		coor.push(@length/(Math.sqrt(1+vProp*vProp)))
		coor.push(vProp*@length/(Math.sqrt(1+vProp*vProp)))
		coor

class Optimization
	'''
	args: 
		initial population
		number of the elements to be crossed in each iteration
		mutationProb = 1/probability of the mutation of each element
		lambda is the size of temp population
	'''
	constructor: (@popul,@nrOfCrossed,@mutationProb,@lambda) ->
		@size = @popul.idvs.length
		@stats = new Stats()
		@tau = tau(@size)
		@tau_prim = tau_prim(@size)
	'''
	The core function which mainpulates the population to find the best individual
	'''
	compute: ->
		
		i = 0
		@popul.idvs = _.sortBy(@popul.idvs,'fitness')
		
		bestResults = while not @stop()
			temp_popul = @createTemp()
			
			# cross initial population
			crossedInd = @crossPop(temp_popul)
			
			# mutate initial population
			mutatedInd = @mutatePop(temp_popul)

			# add crossed and mutated inds to population
			for ind in crossedInd
				@popul.idvs.push(ind)
				#postMessage {type: 'intermediate', best:ind.skier.positions}
			for ind in mutatedInd
				@popul.idvs.push(ind)
				#postMessage {type: 'intermediate', best:ind.skier.positions, pts: ind.value}
				
			# sort population
			@popul.idvs = _.sortBy(@popul.idvs,'fitness')			
			
			# selection - choose the best ones
			@popul.idvs = @popul.idvs[0..(@size-1)]
			
			i+=1
			#@stats.feed(@popul.idvs)
			
			theBest = @popul.idvs[0].fitness
			theWorst = @popul.idvs[@size-1].fitness
			postMessage(type:'intermediate', best:@popul.idvs[0].skier.positions, pts: @popul.idvs[0].value )
			[theBest,theWorst]
		return bestResults
	
	'''
	Do nrOfCrossed crossings between random individuals
	'''
	crossPop: (temp) ->
		#postMessage({temp:temp})
		newInd = []
		if @nrOfCrossed < 1
			return newInd
		for it in [1..@nrOfCrossed]
			i = Math.floor(Math.random()*temp.length)
			j = Math.floor(Math.random()*temp.length)
			#postMessage({i:i,j:j})
			a = temp[i].cross(temp[j])
			newInd.push(a)
		newInd
	
	mutatePop: (temp) ->
		mutIds = []
		gaussAll = Math.nrand()
		for ind in temp
			# 1/mutationProb chance for mutation
			ifMut = Math.floor(Math.random()*@mutationProb)
			if ifMut%@mutationProb==0
				# mutate ind
				mutIds.push(ind.mutate(gaussAll, @tau, @tau_prim))
		mutIds
	
	'''
	Stoping condition
	'''
	stop: () ->
		theWorst = @popul.idvs[@size-1]
		theBest = @popul.idvs[0]
		# postMessage {type:"",b:theBest.fitness, w:theWorst.fitness, diff:(theBest.fitness - theWorst.fitness)/theBest.fitness }
		(Math.abs(theBest.fitness - theWorst.fitness)/theBest.fitness) < 0.00001
	
	'''
	create @lambda copies of the main population
	'''
	createTemp: () ->
		temp = []
		for i in [0..@lambda]
			ind = Math.floor(Math.random()*@size)
			tempInd = @popul.idvs[ind]
			c = tempInd.createCopy(tempInd.value[..])
			temp.push(c)
		temp
		
@Turns = Turns
@Optimization = Optimization
@Individual = Individual

'''
pop = new Turns(10,10,[4,5])
console.log "nowa populacja:"
console.log ([i.fitness,i.value] for i in pop.idvs.reverse())

new Optimization(pop,20,2).compute()
console.log ([i.fitness,i.value] for i in pop.idvs.reverse())
'''