'''
this is a hack that enables the usage of this script in both: the browser via Web Workers or in Node.js
'''
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

B = 4 #  boundary value (in m/s) from with air drag becomes proportional to the square of the velocity
#k1 = 0.05 # out of space driven value
k1 = 0
alfa = pi/6

class Skier
	"""
	C - drag coefficient, typical values (0.4 - 1)
	A - area of the skier exposed to the air
	"""
	constructor: (@mi=0.05, @m=60, @C=0.6, @A=0.2, @solver=new Solver(), @x0=[0,0], @v0=[0,19]) ->
		this.roh = 1.32 # air density
		@k2 = 0.5 * @C * this.roh * @A
		@velocities = [v0]
		@positions = [x0]
		@result = 0
	
	'''
	Move the skier to the endPoint. It is not confirmed that the skier really 
	managed to reach the proximity of that point
	'''
	moveToPoint : (endPoint, steep, kappa, sign_omega = 1) ->
		t0 = @result
		reachedDestination = false
		while !reachedDestination
			t1 = t0+steep
			reachedDestination = @move(t0, t1, kappa, endPoint, sign_omega)
			t0 = t1
	
	moveToPointWithArbitraryV : (v, endPoint, steep, kappa, sign_omega = 1) ->
		t0 = @result
		reachedDestination = false
		while !reachedDestination
			t1 = t0+steep
			reachedDestination = @moveWithArbitraryV(v,t0, t1, kappa, endPoint, sign_omega)
			t0 = t1
			
	'''
	private method that updates the skier parameters based on the result Sol vector and the endPoint that he was asked to reach. 
	It scans the result vector and finds the time slot in which the skier really passed the endPoint
	Return whether the skier reached or overpassed the end point
	'''
	whatIsMyResult : (endPoint, result) ->
		[xEnd, yEnd] = endPoint
		lastIndex = result.y.length-1
		reachedDestination = false
		# TODO can do binary search
		for resultYSteep, index in result.y
			[xx, xy, vx, vy] =resultYSteep
			if (xx > xEnd or xy > yEnd)
				lastIndex = index
				reachedDestination = true
				break
		[xx, xy, vx, vy] =result.y[lastIndex]
		@positions.unshift [xx, xy]
		@velocities.unshift [vx, vy]
		# update the result in a skier - how much time the movement took
		@result = result.x[lastIndex]
		reachedDestination
		
	'''
	Move the skier between t0 and up to t1 time interval. If the endPoint was passed before t1, move the
	skier just up to that point. Return whether the skier reached or overpassed the end point
	'''
	move: (t0, t1, kappa, endPoint, sign_omega = 1) ->
		result = @solver.solve(t0,t1,@positions[0], @velocities[0], kappa, sign_omega, this)
		@whatIsMyResult(endPoint, result)

	moveWithArbitraryV: (v, t0, t1, kappa, endPoint, sign_omega = 1) ->
		result = @solver.solve(t0,t1,@positions[0], v, kappa, sign_omega, this)
		@whatIsMyResult(endPoint, result)
		
	'''
	Compute new kappa basing on set points and velocity vector
	'''
	computeKappa: (endPoint) ->
		[x1,y1] = @positions[0] # start point
		[x2,y2] = endPoint
		[vx,vy] = @velocities[0]
		
		x = (Math.pow((y2-y1),2)*vy - 2*vx*x1*(y2-y1) + (Math.pow(x2,2) - Math.pow(x1,2))*vy)/(2*(-vx*(y2-y1) + vy*(x2-x1)))
		y = (-vx*(Math.pow((y2-y1),2) + (Math.pow(x2,2) - Math.pow(x1,2))))/(2*(-vx*(y2-y1) + vy*(x2-x1))) + y1
		
		kappa = 1 / (Math.sqrt(Math.pow((x1-x),2)+Math.pow((y1-y),2)))
		kappa
	
	
	getPosition: () ->
		@positions[0]
	
	getPositions: () ->
		@positions
	
	getVelocities: () ->
		@velocities
	
class Solver
	compute_sin_cos_beta = (v0) =>
		v0_length = mag(v0)
		eps = 0.00001
		if v0_length<=eps
			cos_beta=0.0
			sin_beta=1.0
		else
			cos_beta =  v0[0]/v0_length
			sin_beta = v0[1]/v0_length
		[sin_beta, cos_beta]
	
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
    
	solve : (start=0, end=1, x0=[0,0], v0=[0,19], kappa=0.05, sign_omega=1, skier=new Skier(), endPoint) =>
		'''
		Air drag is proportional to the square of velocity
		when the velocity is grater than some boundary value: B.
		k1 and k2 factors control whether we take square or linear proportion
		'''
		v0_length = mag v0
		if v0_length <= B
			skier.k2 = 0
		else
			k1 = 0
		[sinus, cosinus] = compute_sin_cos_beta(v0)
		params = {kappa: kappa, skier: skier, sinus: sinus, cosinus: cosinus, sign_omega:sign_omega}
		result = lib.numeric.dopri(start,end,[x0[0], x0[1], v0[0], v0[1]], ((t,v) -> movementEquasion(t,v,params)))  
		result

root = exports ? this
root.OptimalGiant = {}
root.OptimalGiant.Solver = Solver

@Skier = Skier
	
'''
start = Date.now()                                                                    
steep = 0.001
t0 = 0
skier = new Skier(null, null, null, null, null, x0=[0,0], v0=[0,1])

endPoint = [1,4]
kappa = skier.computeKappa(endPoint)
skier.moveToPoint(endPoint, steep, kappa)
console.log skier.getPosition()
console.log skier.result
duration = Date.now() - start
'''
                 