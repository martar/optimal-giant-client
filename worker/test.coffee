solver = require './solver.js'
evol = require './evolutionAlgorithm.js'
opti = require './optimizePoints.js'
###
steep = 0.04
accuracy = 0.1
skier = new solver.Skier(null, null, null, null, null, x0=[0,0], v0=[0.001,0])

points = [[1, 2], [4, 5], [8, 6], [11,8], [10,11], [8, 13]]
#[8,6], [9,11],[11,13],[14,11],
points2 = [ [8,17], [4,18]]
poi = [[0,6]]
for point in points
	skier.moveStraightToPoint(point, accuracy)

len = skier.positions.length
positions = skier.positions.reverse()
console.log positions
console.log skier.result
i = 0
diffs = []
while (i < len-2)
	[x2,y2] = positions[i+1]
	[x1,y1] = positions[i]
	diffs.push [(y2-y1)/(x2-x1), positions[i]]
	i+=1
#console.log "________________________"
#console.log diffs

len = diffs.length
i=0
while (i < len-2)
	console.log diffs[i+1][0] - diffs[i][0], diffs[i+1][1]
	i+=1
###
populationCount = 10
vLen = 0.000001
endPoint = [10,10]
pop = new opti.PointTurns(0.01,populationCount,vLen,endPoint)
crossNr = 10
mutateProb = 1
bestsAndWorstInIterations = new evol.Optimization(pop,crossNr,mutateProb).compute()
brachSkier = new solver.Skier(0,null,0,0,null,x0=[0,0],v0 = [vLen,0])
brachSkier.positions = [[0,0]]
r = 5.74071
t_max = 2.41
i_max = 1000
for i in [1..i_max]
	t = i/i_max*t_max
	x = r*(t - Math.sin(t))
	y = r*(1 - Math.cos(t))
	#brachSkier.positions.push([x,y])
	brachSkier.moveStraightToPoint([x,y],0.001)
brachSkier.color = "red"

skiers = (best.skier for best in pop.idvs)
skiers.push brachSkier
	