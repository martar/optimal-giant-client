importScripts 'solver.js'   

'''
finds the coordinates from the length of the vector and 
tan angle of inclination of the velocity vector
'''
findCoords = (vProp, length) -> 
	coor = []
	coor.push(length/(Math.sqrt(1+vProp*vProp)))
	coor.push(vProp*length/(Math.sqrt(1+vProp*vProp)))
	coor
		
getCurveCoordinates = (timeSteep, endPoint, skier, granulation) ->
	kappa = skier.computeKappa(endPoint)
	t0 = 0
	while !skier.isNear(endPoint)
		t1 = t0+timeSteep
		skier.move(t0, t1, kappa, 1)
		t0 = t1
	skier.result = t0
	(x for x in skier.getPositions() by granulation).reverse()

vectorDistance = (vector) ->
	Math.sqrt( Math.pow(vector[0],2) + Math.pow(vector[1],2))

self.onmessage = (ev) ->
	start = Date.now()
	vstart = [1,10]
	startPoint = [0,0]
	skier = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=vstart)
	steep = 0.001
	t0 = 0
	endPoint = [50,50]

	steepPositions = getCurveCoordinates(steep, endPoint, skier, 800)
	skier2 = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=vstart)
	kappa = 0.000001
	t0 = 0
	for pos in steepPositions
		t1 = t0+steep
		v =findCoords( (pos[1] - skier2.getPositions()[0][1])/(pos[0] - skier2.getPositions()[0][0]), vectorDistance(skier2.getVelocities()[0]))
		#v = skier2.getVelocities()[0]
		skier2.moveWithArbitraryV(v, t0, t1, kappa, 1)
		tt0 = 0
		while !skier2.isNear(pos)
			tt1 = tt0+steep
			skier2.move(tt0, tt1, kappa, 1)
			tt0 = tt1
		t0 = t1 + tt0
	skier2.result = t0
	
	# straight line, so the start vector must have same both coordinates
	vcoord = vectorDistance(vstart)/1.42
	skier3 = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=[vcoord,vcoord])
	steep = 0.01
	t0 = 0
	kappa = 0.00001
	while !skier3.isNear(endPoint)
		t1 = t0+steep
		skier3.move(t0, t1, kappa, 1)
		t0 = t1
	skier3.result = t0
	skier3.color = "blue"
	
	skiers = []
	skier.color = "red"
	skiers.push skier
	skiers.push skier2
	skiers.push skier3
	
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color} for skier in skiers)
	postMessage {skiers: lol}
