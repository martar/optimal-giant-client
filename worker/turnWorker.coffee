#importScripts 'evolutionAlgorithm.js'
importScripts 'optimizePoints.js'
importScripts 'solver.js'
		
self.onmessage = (ev) ->
	start = Date.now()
	populationCount = 20
	vLen = 0.1 # 0.0000001
	
	pop = new PointTurns(3,populationCount,vLen,ev.data.gates)
	crossNr = 6
	mutateProb = 1
	bestsAndWorstInIterations = new Optimization(pop,crossNr,mutateProb).compute()
	
	skiers = (best.skier for best in pop.idvs)
	
	duration = Date.now() - start
	postMessage {type: 'final', iterations:bestsAndWorstInIterations, bestTime: pop.idvs[0].fitness, duration:duration, skiers: ({time: skier.result, positions: skier.getPositions(), color: skier.color } for skier in skiers), points: ({val: a.value} for a in pop.idvs)}
