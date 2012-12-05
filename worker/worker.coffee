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
	while !skier.isNear(endPoint)
		skier.move(timeSteep, kappa, 1)

	(x for x in skier.getPositions() by granulation).reverse()

vectorDistance = (vector) ->
	Math.sqrt( Math.pow(vector[0],2) + Math.pow(vector[1],2))

self.onmessage = (ev) ->
	start = Date.now()
	vstart = [0,0.001]
	startPoint = [0,0]
	skier = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=vstart)
	steep = 0.001
	endPoint = [10,10]

	steepPositions = getCurveCoordinates(steep, endPoint, skier, 1000)
	skier2 = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=vstart)

	for pos in steepPositions
		skier2.moveStraightToPoint(pos, steep)
	
	# straight line, so the start vector must have same both coordinates
	vcoord = vectorDistance(vstart)/1.42
	skier3 = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=[vcoord,vcoord])
	kappa = 0.000001
	skier3.moveToPoint(endPoint, steep, kappa, 1)

	skier3.color = "blue"
	
	skiers = []
	skier.color = "red"
	skiers.push skier
	skiers.push skier2
	skiers.push skier3
	
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color, diff: skier.positions[0]} for skier in skiers)
	postMessage {skiers: lol}
