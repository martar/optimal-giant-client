importScripts 'evolutionAlgorithm.js'
                             
self.onmessage = (ev) ->
	start = Date.now()
	
	populationCount = 5
	vLen = 10
	endPoint = [4,5]
	pop = new Turns(populationCount, vLen, endPoint)
	crossNr = 10
	mutateProb = 3
	bests = new Optimization(pop,crossNr,mutateProb).compute()
	
	first = pop.idvs[0]
	skier1 = first.skier
	second = pop.idvs[1]
	skier2 = second.skier
	duration = Date.now() - start
	postMessage {v_alpha:first.value, time: first.fitness, skiers: [{positions: skier1.getPositions(), color: "red"},{positions: skier2.getPositions(), color: "blue"}]}
