#importScripts 'evolutionAlgorithm.js'
importScripts 'optimizePoints.js'
importScripts 'solver.js'
importScripts 'gate.js'
importScripts 'localOptAlgorithm.js'
		
self.onmessage = (ev) ->
	start = Date.now()
	populationCount = 30
	vLen = 0.1 # 0.0000001
	hasLeftSidePollGates = ev.data.hasLeftSidePollGates
	gates = (new Gate(gate,hasLeftSidePollGates[i]) for gate,i in ev.data.gates)
	pop = new PointTurns(4,populationCount,vLen,gates)
	crossNr = 10

	mutateProb = 1
	lambda = 100
	bestsAndWorstInIterations = new Optimization(pop,mutateProb,lambda).compute()
	
	bestLocal = new LocalOptimization(pop.idvs[0].skier,ev.data.gates,vLen).compute()
	
	# only best!
	#skiers = (best.skier for best in pop.idvs)
	bestLocal.color = "red"
	skiers = [pop.idvs[0].skier,bestLocal]
	#skiers.push()
	
	duration = Date.now() - start
	postMessage {type: 'final', iterations:bestsAndWorstInIterations, bestTime: pop.idvs[0].fitness, duration:duration, skiers: ({time: skier.result, positions: skier.getPositions(), color: skier.color } for skier in skiers), points: ({val: a.value} for a in pop.idvs)}
