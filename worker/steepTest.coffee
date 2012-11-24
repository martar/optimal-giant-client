Solver = require './solver.js'   
'''
finds the coordinates from the length of the vector and 
tan angle of inclination of the velocity vector
'''
findCoords = (vProp, length) -> 
	coor = []
	coor.push(length/(Math.sqrt(1+vProp*vProp)))
	coor.push(vProp*length/(Math.sqrt(1+vProp*vProp)))
	coor	

skier = new Solver.Skier(@mi=0.05, @m=60, @C=0.6, @A=0.2, @solver=new Solver.OptimalGiant.Solver, @x0=[0,0], @v0=[1,2])
n = 0
steep = 0.01
t0 = 0
endPoint = [20,20]
kappa = skier.computeKappa(endPoint)
while !skier.isNear(endPoint)
	t1 = t0+steep
	skier.move(t0, t1, kappa, 1)
	t0 = t1
steepPositions = (x for x in skier.getPositions() by 10).reverse()
skier2 = new Solver.Skier(@mi=0.05, @m=60, @C=0.6, @A=0.2, @solver=new Solver.OptimalGiant.Solver, @x0=[0,0], @v0=[1,2])
kappa = 0
for pos in steepPositions
	t1 = t0+steep
	v =findCoords( (pos[1] - skier2.getPositions()[0][1])/(pos[0] - skier2.getPositions()[0][0]), 
				Math.sqrt( skier2.getVelocities()[0][0]^2 + skier2.getVelocities()[0][1]^2))
	skier2.moveWithArbitraryV(v, t0, t1, kappa, 1)
	console.log skier2.getPositions()[0]
	tt0 = 0
	# while !skier2.isNear(pos)
	#	tt1 = tt0+steep
	#	skier2.move(tt0, tt1, kappa, 1)
	#	tt0 = tt1
	t0 = t1 + tt0
skiers = []
skier.color = "yellow"
skiers.push skier
skiers.push skier2
lol = ({time: skier.result, positions: skier.getPositions(), color: skier.color} for skier in skiers)