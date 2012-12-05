#try

importScripts './underscore.js'
importScripts './solver.js'	
importScripts './evolutionAlgorithm.js'
evol = {}
evol.Individual = Individual
solver = {}
solver.Skier = Skier
"""
_ = require('./underscore.js')
solver = require('./solver.js')
evol = require('./evolutionAlgorithm.js')
"""
	
findCoords = (value,length) ->
	coor = []
	vProp = value
	
	coor.push(length/(Math.sqrt(1+vProp*vProp)))
	coor.push(vProp*length/(Math.sqrt(1+vProp*vProp)))
	coor


class PointTurns	
	constructor: (@del_x,count,val,@endPoint,@startPoint=[0,0]) ->
		propEnd = (@endPoint[1]-@startPoint[1])/(@endPoint[0] - @startPoint[0])
		x = Math.atan(propEnd)
		
		#CHECK!!!!!! sth wrong!!
		
		# znajdz punkty dla randomowych prêdkoœci i stwórz pierwsze obiekty populacji
		randomAngles = (Math.random()* (Math.PI/2 - Math.abs(x)) + Math.abs(x) for i in [1..count])
		
		#randomAngles = [Math.PI/2, Math.PI/2 - 0.2, Math.PI/4 + 0.25, Math.PI/4 + 0.3, Math.PI/4 + 0.4]
		
		@idvs = []
		for angle in randomAngles
			skier = new solver.Skier(0,null,0,0,null,x0=@startPoint,v0 = findCoords(angle,val))
			points = @getPoints(1/(skier.computeKappa(@endPoint)),skier.getCircleCenter(@endPoint))
			@idvs.push(new PointsSet(points,skier))
		
	getPoints: (R,center) ->
		#console.log "ko³o:", R,center
		cur_x = @startPoint[0] + @del_x
		# points = [@startPoint]
		points = []
		while cur_x < @endPoint[0]
			y = Math.sqrt(Math.pow(R,2)-Math.pow((center[0]-cur_x),2)) + center[1]
			points.push([cur_x,y])
			cur_x += @del_x
		points.push(@endPoint)
		#console.log "points:", points
		points

		
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
	
	computeFitness: () ->
		if @fitness
			return @fitness
		interval = 0.001
		t = 0
		@min = 100000

		for nextPos in @value
			@skier.moveStraightToPoint(interval, nextPos)
		#console.log "czas: ", t
		@fitness = @skier.result
		
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
			# do not change endPoint
			ind = Math.floor(Math.random()*(@value.length-1))
		
			newValue[ind][1] = newValue[ind][1] + (Math.random()*percentValue*2 - 	percentValue)*newValue[ind][1]/100
		
		@createCopy(newValue)
		
	cross: (b) ->
		@createCopy(([@value[i][0] ,(@value[i][1] + b.value[i][1])/2] for i in [0..@value.length-1]))

@PointTurns = PointTurns

'''
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
'''