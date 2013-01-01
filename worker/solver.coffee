###
this is a hack that enables the usage of this script in both: the browser via Web Workers or in Node.js
###
lib = {}
try
	importScripts './numeric.js'
	if numeric?
		lib.numeric = numeric
catch error
	lib.numeric = require("./numeric.js")
  
pi = Math.PI
sin = Math.sin
cos = Math.cos
sqrt = Math.sqrt
square = (x) => x*x
mag = ( [x,y]) => Math.sqrt(square(x) + square(y))
g = 9.80665 # standard acceleration of free fall
g = 9.81
B = 4 #  boundary value (in m/s) from with air drag becomes proportional to the square of the velocity
k1 = 0.05 # out of space driven value
# TODO only for test
k1 = 0

alfa = pi/12


class Utils
	###
	finds the coordinates from the length of the vector and 
	tan angle of inclination of the next velocity vector with the same length
	###
	this.findCoords = (endPoint, position, length) -> 
		vProp = (endPoint[1] - position[1])/(endPoint[0] - position[0])
		factor = 1
		if (endPoint[0] - position[0] < 0)
			factor = -1
		vx = factor * length/(Math.sqrt(1+vProp*vProp))
		vy = factor * vProp*length/(Math.sqrt(1+vProp*vProp))
		[vx, vy]
	
	###
	computes length of the vector
	###
	this.vectorLength = (vector) ->
		Math.sqrt( Math.pow(vector[0],2) + Math.pow(vector[1],2))
	
	# two dimensional vector distance in Kartezian metric
	this.vectorDistance = (vector1, vector2) ->
		[xEnd, yEnd] = vector1
		[xx,xy] = vector2
		Utils.vectorLength([ xEnd-xx, yEnd-xy])
		
	this.compute_sin_cos_beta = (v0) =>
		v0_length = mag(v0)
		eps = 0.00001
		if v0_length<=eps
			cos_beta=0.0
			sin_beta=1.0
		else
			cos_beta =  v0[0]/v0_length
			sin_beta = v0[1]/v0_length
		[sin_beta, cos_beta]
		
class Skier
	###
	C - drag coefficient, typical values (0.4 - 1)
	A - area of the skier exposed to the air
	###
	constructor: (@mi=0.05, @m=60, @C=0.6, @A=0.2, @solver=new Solver(), @x0=[0,0], @v0=[0,19]) ->
		this.roh = 1.32 # air density
		@k2 = 0.5 * @C * this.roh * @A
		@velocities = [v0]
		@positions = [x0]
		@result = 0
		@min = 10000
	
	###
	resets all params of the skier. It's like taking him back to the starting point, after he finifhed his race
	###
	reset : () ->
		@velocities = [@velocities[@velocities.length-1]]
		@positions = [@positions[@positions-1]]
		@result = 0
		

	###
	Move the skier to the endPoint. It changes the skier inner state. It is not confirmed that the skier really 
	managed to reach the proximity of that point
	###
	moveToPoint : (kappa, endPoint, accuracy = 0.01, sign_omega = 1) ->
		reachedDestination = false
		while !reachedDestination
			reachedDestination = @_move(kappa, endPoint, accuracy, sign_omega)
		
	###
	Move the skier to the endPoint going in the straight line (kappa ~ 0).  It changes the skier inner state. It is not confirmed that the skier really 
	managed to reach the proximity of that point
	###			
	moveStraightToPoint : ( endPoint, accuracy = 0.01, sign_omega = 1) ->
		reachedDestination = false
		kappa = 0 #0.0000001
		while !reachedDestination
			v =Utils.findCoords( endPoint, @positions[0], Utils.vectorLength(@velocities[0]))
			reachedDestination = @_moveWithArbitraryV(v, kappa, endPoint, accuracy, sign_omega)
	###
	Compute new kappa that is required so that the skier read the endPoint taking current velocity vector into account. It is not guaranted that the skier really 
	managed to reach the proximity of that point using computed kappa
	###
	computeKappa: (endPoint) ->
		[x1,y1] = @positions[0] # start point
		[x,y] = @getCircleCenter(endPoint)
		kappa = 1 / (Math.sqrt(Math.pow((x1-x),2)+Math.pow((y1-y),2)))
		kappa
	
	getCircleCenter: (endPoint) ->
		[x1,y1] = @positions[0] # start point
		[x2,y2] = endPoint
		[vx,vy] = @velocities[0]
		
		x = (Math.pow((y2-y1),2)*vy - 2*vx*x1*(y2-y1) + (Math.pow(x2,2) - Math.pow(x1,2))*vy)/(2*(-vx*(y2-y1) + vy*(x2-x1)))
		y = (-vx*(Math.pow((y2-y1),2) + (Math.pow(x2,2) - Math.pow(x1,2))))/(2*(-vx*(y2-y1) + vy*(x2-x1))) + y1
		[x,y]
	
	getPosition: () ->
		@positions[0]
	
	getPositions: () ->
		@positions
	
	getVelocities: () ->
		@velocities
		
	_isNotCloseEnought : (currPoint, endPoint, accuracy = 0.01) ->
		[xEnd, yEnd] = endPoint
		[xx,xy, _, _] = currPoint
		Utils.vectorDistance(currPoint, endPoint) > accuracy
		
	_doesHeReach :(start, actualEndPoint, wannaBeEndPoint) ->
		Utils.vectorDistance(start, actualEndPoint) > Utils.vectorDistance(start, wannaBeEndPoint)
	###
	Important method. It applies state change of the skier based on the computed result of one single step of the computation. It also decide when the skier reached the endPoint
	###
	_whatIsMyResult : (endPoint, result, accuracy) ->
		reachedDestination = true
		[xEnd, yEnd] = endPoint
		lastIndex = result.y.length-1
		lastRow = result.y[lastIndex]
		finalResult = lastRow
		startPosition = result.y[0]
		startTime = result.x[0]
		overTime = result.x[lastIndex]
		finalTime = overTime
		# check if the skeir can reach the endPoint in the computed step. If not, just move the skier to the most futher point
		if !(@_doesHeReach(startPosition, lastRow, endPoint))
			reachedDestination = false
		else
			# if he - out of the box is close enought based on the required accuracy,
			# we don't need to enter the loop to make find the closer positions

			# but if he if to far from the required EndPoint
			while @_isNotCloseEnought(finalResult, [xEnd, yEnd], accuracy)
				previousNewTime = middleTime
				middleTime = (startTime + overTime)/2
				if previousNewTime == middleTime
					# can't do it, something went wrong - our phisic model can't handle this
					throw "I cannot go there with required accuracy!"
				midResult = result.at([middleTime])[0]
				# is the intermediate result in the first half of the interval
				if @_doesHeReach(startPosition, midResult, endPoint)
					overTime = middleTime
				else
					startTime  = middleTime
				
				finalResult = midResult
				finalTime = middleTime
			
		[xx, xy, vx, vy] = finalResult
		@positions.unshift [xx, xy]
		@velocities.unshift [vx, vy]
		# update the result in a skier - how much time the movement really took
		@result = finalTime
		reachedDestination
	###
	just show the result, without any sideeffect and changing state of the skier
	###
	
	###
	Try to compute the appriopriate time steep for the move based on the velocity vector and endPoint. The idea is to make 
	a prediction of the time steep in which the skier would really manage to go
	from the current point to the endPoint.
	now, the reference is made based on the time requires to 
	go from currrent position  to endPosition with constant acceletarion multipied with
	our home made constant. Multiplication is needed, because there are additional friction and air resistant forces.
	Additional fallback is added, so that the interval is never less than a given threshold
	###
	_adaptSteep : (endPoint) ->
		vLen = Utils.vectorLength(@velocities[0])
		s = Utils.vectorDistance(@positions[0], endPoint)
		[_, cos_beta] = Utils.compute_sin_cos_beta(@velocities[0])
		a = g * Math.sin(alfa) * cos_beta
		optimalGiantConstant = 5
		result = optimalGiantConstant*(Math.sqrt(vLen*vLen+2*a*s) - vLen)/a
		threshold = 10
		# result can be NaN (division by zero)
		if not result or result < threshold
			result = threshold
		result
		
	moveDebug: (kappa, endPoint, sign_omega = 1) ->
		steep = @_adaptSteep(@velocities[0], endPoint)
		@solver.solve(@result,@result+steep,@positions[0], @velocities[0], kappa, sign_omega, this)
		
	_move: (kappa, endPoint, accuracy = 0.01, sign_omega = 1) ->
		steep = @_adaptSteep(endPoint)
		result = @solver.solve(@result,@result+steep,@positions[0], @velocities[0], kappa, sign_omega, this)
		@_whatIsMyResult(endPoint, result, accuracy)
		
	_moveWithArbitraryV: (v, kappa, endPoint, accuracy = 0.01, sign_omega = 1) ->
		steep = @_adaptSteep(endPoint)
		result = @solver.solve(@result,@result+steep,@positions[0], v, kappa, sign_omega, this)
		@_whatIsMyResult(endPoint, result, accuracy)
	
class Solver

    
	movementEquasion = (t,v, params) =>
		[_, _, vx, vy] = v
		[skier, kappa, sinus, cosinus, sign_omega] = [params.skier, params.kappa, params.sinus, params.cosinus, params.sign_omega]
		vl = mag [vx,vy]
		f_R = (square(vl))*Math.abs(kappa)
		f_r = f_R + sign_omega*g*sin(alfa)*cosinus
		if f_r < 0
			f_r = sign_omega*g*sin(alfa)*cosinus
			f_R = 0  
		N = sqrt ( square((g*cos(alfa))) + square((f_R)) )
		f = [ vx, vy, f_r*sinus*sign_omega- (skier.mi*N + k1/skier.m*vl + square(skier.k2/skier.m*vl))*cosinus, g*sin(alfa) - f_r*cosinus*sign_omega - (skier.mi*N + k1/skier.m*vl + skier.k2/skier.m*square(vl))*sinus]
    
	solve : (start=0, end=1, x0=[0,0], v0=[0,19], kappa=0.05, sign_omega=1, skier=new Skier()) =>
		###
		Air drag is proportional to the square of velocity
		when the velocity is grater than some boundary value: B.
		k1 and k2 factors control whether we take square or linear proportion
		###
		v0_length = mag v0
		if v0_length <= B
			skier.k2 = 0
		else
			k1 = 0
		[sinus, cosinus] = Utils.compute_sin_cos_beta(v0)
		params = {kappa: kappa, skier: skier, sinus: sinus, cosinus: cosinus, sign_omega:sign_omega}
		lib.numeric.dopri(start,end,[x0[0], x0[1], v0[0], v0[1]], (t,v) -> movementEquasion(t,v,params))  

root = exports ? this
root.OptimalGiant = {}
root.OptimalGiant.Solver = Solver

@Skier = Skier
	
###
vstart = [0,0.001]
startPoint = [0,0]
steep = 0.01
endPoint = [10,10]
accuracy = 0.1

skier = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new Solver, @x0=startPoint, @v0=vstart)
skier.color = "red"
kappa = skier.computeKappa(endPoint)
skier.moveToPoint(steep, kappa, endPoint, accuracy)
steepPositions = (x for x in skier.getPositions() by 1000).reverse()
###
