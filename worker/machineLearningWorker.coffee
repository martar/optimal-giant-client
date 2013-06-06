importScripts 'solver.js'
importScripts 'gate.js'
importScripts 'machineLearning.js'

self.onmessage = (ev) ->
	start = Date.now()
	gates = (new Gate(gate,i%2) for gate,i in ev.data.gates)
	dx = 1
	dy = 2
	alfa = 0.1
	gamma = 0.8
	endPoint = ev.data.gates[ev.data.gates.length-1][0]
	env = new Environment(dx,dy,gates)
	MAX_EPISODES = 10000
	ml = new Learning(env, alfa, gamma, endPoint, MAX_EPISODES)
	result = ml.start()
	duration = Date.now() - start

	#postMessage {type: 'final', iterations:bestsAndWorstInIterations, bestTime: pop.idvs[0].fitness, duration:duration, skiers: ({time: skier.result, positions: skier.getPositions(), color: skier.color } for skier in skiers), points: ({val: a.value} for a in pop.idvs)}
	postMessage {type: 'final', skiers: ({time: skier.result, positions: skier.getPositions(), color: 'blue' } for skier in result) }
