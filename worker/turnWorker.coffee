#importScripts 'evolutionAlgorithm.js'
importScripts 'optimizePoints.js'
importScripts 'solver.js'

self.onmessage = (ev) ->
	start = Date.now()
	
	populationCount = 10
	vLen = 0.1
	endPoint = [10,10]
	#pop = new Turns(populationCount, vLen, endPoint)
	pop = new PointTurns(2,populationCount,vLen,endPoint)
	crossNr = 5
	mutateProb = 5
	bests = new Optimization(pop,crossNr,mutateProb).compute()
	'''
	skier3 = new Skier(@mi=0, @m=60, @C=0, @A=0, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=[0,1])
	n = 0
	steep = 0.01
	t0 = 0
	kappa = skier2.computeKappa(endPoint)
	while !skier2.isNear(endPoint)
		t1 = t0+steep
		skier2.move(t0, t1, kappa, 1)
		t0 = t1
	t0 = t1-steep
	skier2.getPositions().pop()
	'''
	first = pop.idvs[0]
	skier1 = first.skier
	second = pop.idvs[1]
	skier2 = second.skier
	duration = Date.now() - start
	postMessage {v_alpha:first.value, time: first.fitness, skiers: [{positions: skier1.getPositions(), color: "red", velocities: skier1.getVelocities(), time:first.fitness},{positions: skier2.getPositions(), color: "blue", velocities: skier2.getVelocities(), time: second.fitness}]}
