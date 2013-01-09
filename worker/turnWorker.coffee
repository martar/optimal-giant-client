#importScripts 'evolutionAlgorithm.js'
importScripts 'optimizePoints.js'
importScripts 'solver.js'
importScripts 'gate.js'
		
self.onmessage = (ev) ->
	start = Date.now()
	populationCount = 30
	vLen = 0.1 # 0.0000001
	gates = (new Gate(gate,i%2) for gate,i in ev.data.gates)
	pop = new PointTurns(3,populationCount,vLen,gates)
	crossNr = 10

	mutateProb = 1
	bestsAndWorstInIterations = new Optimization(pop,crossNr,mutateProb).compute()
	
	skiers = (best.skier for best in pop.idvs)
	
	duration = Date.now() - start
	postMessage {type: 'final', iterations:bestsAndWorstInIterations, bestTime: pop.idvs[0].fitness, duration:duration, skiers: ({time: skier.result, positions: skier.getPositions(), color: skier.color } for skier in skiers), points: ({val: a.value} for a in pop.idvs)}
