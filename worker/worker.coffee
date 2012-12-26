importScripts 'solver.js'   
# be careful: in Chrome 1/0 equals Infinity (459?)
# worth noticing that sometimes, the number of positions is greater than number of original points!
###
from the given list of positions [ [x1,y1], ..]
it returns the list of values that describes the "sharpnes" of the given pont in relation to the neighbour points
###
diffs = (positions) =>
	i = 0
	diff = []
	while (i <= positions.length-2)
		[x2,y2] = positions[i+1]
		[x1,y1] = positions[i]
		diff.push (x2-x1)/(y2-y1)
		# diff.push (y2-y1)/(x2-x1)
		i+=1
	values = []
	i=0
	while (i <= diff.length-2)
		values.push diff[i+1] - diff[i]
		i+=1
	values
	
testRun = (points) =>
	accuracy = 0.01
	skier = new Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])
	for point in points
		skier.moveStraightToPoint(point, accuracy)
	skier.diffs = diffs(skier.positions.reverse())
	skier
	
self.onmessage = (ev) ->
	# points = [[4, 2], [6, 6], [6,7], [4, 11], [0,13] ]
	# points = [[4, 2], [6,6.5], [4, 11], [0,13] ]
	# points = [[5, 2], [0, 4], [5, 6], [0, 8], [5,10]]
	points = [[1, 2], [4, 5], [8, 6], [11,8], [10,11], [8, 13], [2,16], [1,17], [2, 18], [8,21], [10, 23] ]
	p1 = [[1,4], [3,8], [7,12], [15,14]]
	p2 = [[1,4], [3,8], [7,10], [15,10.5]]


	skiers = [testRun(p1), testRun(p2), testRun(points)]
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color, diff: skier.diffs} for skier in skiers)
	postMessage {type: 'final', skiers: lol}
