solver = require './solver.js'

x = [ 0, 0 ] 
v = [ 4, 5 ]

kappa = 0

interval = 0.0001
t = 0
skier = new solver.OptimalGiant.Skier(null, null, null, null, null, x0=x,v0=v)
result = new solver.OptimalGiant.Solver
while (! (Math.pow(x[0] - 4, 2) + Math.pow(x[1] - 5, 2)<0.01))
	sol = result.solve(t,t+interval,x,v,kappa,1,skier).y
	[xx, xy, vx, vy] =sol[sol.length-1]

	x = [xx, xy]
	v = [vx, vy]

	#console.log "x,v: ", x, v
	t += interval
console.log "x,v: ", x, v
console.log t