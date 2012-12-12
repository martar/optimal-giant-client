importScripts 'solver.js'   

vectorDistance = (vector) ->
	Math.sqrt( Math.pow(vector[0],2) + Math.pow(vector[1],2))

self.onmessage = (ev) ->
	vstart = [0,0.001]
	startPoint = [0,0]
	steep = 0.1
	endPoint = [10,10]
	accuracy = 0.1
	
	skier = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=vstart)
	skier.color = "red"
	kappa = skier.computeKappa(endPoint)
	skier.moveToPoint(steep, kappa, endPoint, accuracy)
	steepPositions = (x for x in skier.getPositions() by 100).reverse()
	

	skier2 = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=vstart)
	for pos in steepPositions
		skier2.moveStraightToPoint(steep, pos, accuracy)
	
	# straight line, so the start vector must have same both coordinates
	vcoord = vectorDistance(vstart)/1.42
	skier3 = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new OptimalGiant.Solver, @x0=startPoint, @v0=[vcoord,vcoord])
	kappa = 0.000001
	skier3.moveToPoint(steep, kappa, endPoint, accuracy)
	skier3.color = "blue"
	
	skiers = []
	skiers.push skier
	skiers.push skier2
	skiers.push skier3
	
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color, diff: skier.positions[0]} for skier in skiers)
	postMessage {skiers: lol}
