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
		
self.onmessage = (ev) ->
	start = Date.now()
	vstart = [0.001,0]
	skier = new Skier(@mi=0, @m=60, @C=0, @A=0, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=vstart)
	n = 0
	steep = 0.01
	t0 = 0
	endPoint = [10,10]
	kappa = skier.computeKappa(endPoint)
	while !skier.isNear(endPoint)
		t1 = t0+steep
		skier.move(t0, t1, kappa, 1)
		t0 = t1
	skier.result = t0
	duration = Date.now() - start
	steepPositions = (x for x in skier.getPositions() by 40).reverse()
	skier2 = new Skier(@mi=0, @m=60, @C=0, @A=0, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=vstart)
	kappa = 0.000001
	t0 = 0

	for pos in steepPositions
		t1 = t0+steep
		v =findCoords( (pos[1] - skier2.getPositions()[0][1])/(pos[0] - skier2.getPositions()[0][0]), Math.sqrt( Math.pow(skier2.getVelocities()[0][0],2) + Math.pow(skier2.getVelocities()[0][1],2)))
		#v = skier2.getVelocities()[0]
		skier2.moveWithArbitraryV(v, t0, t1, kappa, 1)
		tt0 = 0
		while !skier2.isNear(pos)
			tt1 = tt0+steep
			skier2.move(tt0, tt1, kappa, 1)
			tt0 = tt1
		t0 = t1 + tt0
	skier2.result = t0
	
	skier3 = new Skier(@mi=0, @m=60, @C=0, @A=0, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=vstart)
	skier4 = new Skier(@mi=0, @m=60, @C=0, @A=0, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=vstart)

	s = Math.sqrt(Math.pow(endPoint[0],2) + Math.pow(endPoint[1],2))
	t_max = 2*Math.PI
	r = s/t_max
	a = Math.PI/4
	for i in [1..1000]
		t = i/1000*t_max
		x = r*(t - Math.sin(t))
		y = r*(1 - Math.cos(t))
		xp = x*Math.cos(a) - y*Math.sin(a)
		yp = x*Math.sin(a) + y*Math.cos(a)
		skier3.positions.push([x,y])
		skier4.positions.push([xp,yp])
		#s.positions.push([x,y])
	skier3.result = 0
	skier4.result = 0
	
	skiers = []
	skier.color = "yellow"
	skier3.color = 'blue'
	skier4.color = 'red'
	skiers.push skier
	skiers.push skier2
	skiers.push skier3
	skiers.push skier4
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color} for skier in skiers)
	lol2 = ({time: skier.result} for skier in skiers)
	postMessage {results: lol2, skiers: lol, pos: steepPositions.reverse()}
