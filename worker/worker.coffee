importScripts 'solver.js'   
# be careful: in Chrome 1/0 equals Infinity (459?)
# worth noticing that sometimes, the number of positions is greater than number of original points!
	
testRun = (points) =>
	accuracy = 0.01
	skier = new Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])
	for point in points
		skier.moveStraightToPoint(point, accuracy)
	skier

self.onmessage = (ev) ->
	p1 = [[2.5,2.5],[5,5],[2.5,7.5],[0,10],[2.5,12.5],[5,15]]
	p2 = [[4, 2.5], [5,5],[4,7.5], [0,10],[1,12.5], [5,15]]
	skiers = [ testRun(p1), testRun(p2)]
	lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color} for skier in skiers)
	postMessage {type: 'final', skiers: lol}