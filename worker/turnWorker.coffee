#importScripts 'evolutionAlgorithm.js'
importScripts 'optimizePoints.js'
importScripts 'solver.js'

self.onmessage = (ev) ->
	start = Date.now()
	
	populationCount = 10
	vLen = 0.000001
	endPoint = [10,10]
	pop = new PointTurns(0.01,populationCount,vLen,endPoint)
	crossNr = 10
	mutateProb = 1
	bestsAndWorstInIterations = new Optimization(pop,crossNr,mutateProb).compute()
	
	brachSkier = new Skier(0,null,0,0,null,x0=[0,0],v0 = [vLen,0])
	brachSkier.positions = [[0,0]]
	r = 5.74071
	t_max = 2.41
	i_max = 1000
	for i in [1..i_max]
		t = i/i_max*t_max
		x = r*(t - Math.sin(t))
		y = r*(1 - Math.cos(t))
		#brachSkier.positions.push([x,y])
		brachSkier.moveStraightToPoint(0.001,[x,y],0.001)
	brachSkier.color = "red"

	skiers = (best.skier for best in pop.idvs)
	skiers.push brachSkier
	
	duration = Date.now() - start
	postMessage {type: 'final', iterations:bestsAndWorstInIterations, bestTime: pop.idvs[0].fitness, duration:duration, skiers: ({time: skier.result, positions: skier.getPositions(), color: skier.color } for skier in skiers), points: ({val: a.value} for a in pop.idvs)}
