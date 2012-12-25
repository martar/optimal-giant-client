importScripts 'solver.js'   

self.onmessage = (ev) ->
	accuracy = 0.01
	skier = new Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])
	points = [[1, 2], [4, 5], [8, 6], [11,8], [10,11], [8, 13], [6, 14], [4,15], [2,16], [1,17], [2, 18], [4, 19], [6,20], [8,21], [10, 23] ]
	for point in points
		skier.moveStraightToPoint(point, accuracy)
		
	positions = skier.positions.reverse()
	i = 0
	diffs = []
	len = skier.positions.length
	while (i <= len-2)
		[x2,y2] = positions[i+1]
		[x1,y1] = positions[i]
		diffs.push (y2-y1)/(x2-x1)
		i+=1
	values = []
	len = diffs.length
	i=0
	while (i <= len-2)
		values.push Math.abs(diffs[i+1] - diffs[i]).toFixed(5)
		i+=1
	skiers = []
	skiers.push skier
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color, diff: skier.positions[0]} for skier in skiers)
	postMessage {type: 'final', skiers: lol, trol: values}
