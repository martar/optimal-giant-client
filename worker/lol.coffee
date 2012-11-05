solver = require './solver.js'                                                             
result = solver.OptimalGiant.solver(0,1)
skier = new solver.OptimalGiant.Skier
skier.move(0,1)
skier.move(1,2)
skier.move(2,3)
skier.move(3,4)
skier.move(4,5)
skier.move(5,6)
console.log skier.getPositions()  
console.log skier.getVelocities()